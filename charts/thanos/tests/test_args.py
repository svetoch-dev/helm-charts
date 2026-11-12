"""Render regressions for the five supported Thanos services (Helm and PyYAML)."""

from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml


CHART = Path(__file__).resolve().parents[1]
SERVICES = ("query", "queryFrontend", "compactor", "storegateway", "ruler")


def render(thanos_overrides=None, check=True, resource_overrides=None, enabled=None):
    values = {
        "global": {
            "ingress": {"class": "example"},
            "pomerium": {"policy": {"default": "allow: []\n"}},
            "company": {"name": "example"},
            "env": {
                "short_name": "test", "cloud": {"buckets": {"type": "gcs"}},
                "dns": {"domain": "example.test"},
            },
        },
        **{name: {"enabled": True} for name in SERVICES},
    }
    values["ruler"]["common"] = {"thanos": {
        "config": "groups: []", "alertmanagers": ["http://alertmanager.example:9093"],
    }}
    for service, options in (thanos_overrides or {}).items():
        values[service].setdefault("common", {}).setdefault("thanos", {}).update(options)
    for service, options in (resource_overrides or {}).items():
        values[service].setdefault("common", {}).update(options)
    for service, flag in (enabled or {}).items():
        values.setdefault(service, {})["enabled"] = flag
    with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml") as fixture:
        yaml.safe_dump(values, fixture)
        fixture.flush()
        result = subprocess.run(
            ["helm", "template", "example", str(CHART), "--namespace", "example", "-f", fixture.name],
            capture_output=True, text=True,
        )
    if not check:
        return result
    if result.returncode:
        raise AssertionError(result.stderr)
    docs = [doc for doc in yaml.safe_load_all(result.stdout) if doc]
    identities = [(d["apiVersion"], d["kind"], d["metadata"].get("namespace"), d["metadata"]["name"]) for d in docs]
    if len(identities) != len(set(identities)):
        raise AssertionError("Rendered duplicate resource identities")
    return docs


def workloads(docs):
    return [d for d in docs if d["kind"] in ("Deployment", "StatefulSet")]


def containers(docs):
    return {c["name"]: c for d in workloads(docs) for c in d["spec"]["template"]["spec"]["containers"]}


class ArgumentTests(unittest.TestCase):
    def test_five_distinct_services(self):
        actual = containers(render())
        self.assertEqual({name: c["args"][0] for name, c in actual.items()}, {
            "query": "query", "query-frontend": "query-frontend", "compactor": "compact",
            "storegateway": "store", "ruler": "rule",
        })

    def test_compactor_options_mount_and_wait(self):
        container = containers(render({"compactor": {
            "logLevel": "debug", "logFormat": "logfmt", "dataDir": "/compact/data",
            "retentionResolutionRaw": "7d", "retentionResolution5m": "14d",
            "retentionResolution1h": "30d", "consistencyDelay": "15m", "concurrency": 0,
            "extraFlags": ["--delete-delay=72h"], "cronJob": {"enabled": True},
        }}))["compactor"]
        self.assertEqual(container["args"], [
            "compact", "--log.level=debug", "--log.format=logfmt",
            "--http-address=0.0.0.0:10902", "--data-dir=/compact/data",
            "--retention.resolution-raw=7d", "--retention.resolution-5m=14d",
            "--retention.resolution-1h=30d", "--consistency-delay=15m", "--compact.concurrency=0",
            "--objstore.config-file=/conf/objstore.yml", "--delete-delay=72h",
        ])
        self.assertIn({"name": "data", "mountPath": "/compact/data"}, container["volumeMounts"])
        self.assertEqual(containers(render())["compactor"]["args"][-1], "--wait")

    def test_custom_args_and_command_bypass_each_builder(self):
        actual = containers(render(resource_overrides={
            s: {"args": ["--help"], "command": ["thanos"]} for s in SERVICES
        }))
        self.assertEqual(len(actual), 5)
        for container in actual.values():
            self.assertEqual(container["args"], ["--help"])
            self.assertEqual(container["command"], ["thanos"])

    def test_query_endpoints_labels_and_templated_flags(self):
        args = containers(render({"query": {
            "replicaLabel": ["replica", "copy"], "stores": ["store-one:10901", "store-two:10901"],
            "extraFlags": ["--query.timeout={{ .Release.Name }}"],
        }}))["query"]["args"]
        for flag in ("--query.replica-label=replica", "--query.replica-label=copy",
                     "--endpoint=store-one:10901", "--endpoint=store-two:10901", "--query.timeout=example"):
            self.assertIn(flag, args)
        args = containers(render({"query": {"replicaLabel": "copy"}}))["query"]["args"]
        self.assertIn("--query.replica-label=copy", args)

    def test_frontend_service_url_and_extra_flags(self):
        args = containers(render({"queryFrontend": {"extraFlags": ["--query-range.split-interval=12h"]}}))["query-frontend"]["args"]
        self.assertIn("--query-frontend.downstream-url=http://example-thanos-query:9090", args)
        self.assertIn("--query-range.split-interval=12h", args)

    def test_ruler_options_urls_and_mount(self):
        ruler = containers(render({"ruler": {
            "dataPath": "/ruler/data", "evalInterval": "5m", "queries": ["http://query.example:9090"],
            "alertmanagers": ["http://alerts-one.example:9093", "http://alerts-two.example:9093"],
            "clusterName": "example", "ruleFile": "/conf/rules/custom.yml",
        }}))["ruler"]
        for flag in ("--alertmanagers.url=http://alerts-one.example:9093",
                     "--alertmanagers.url=http://alerts-two.example:9093", "--eval-interval=5m",
                     "--query=http://query.example:9090", "--alert.query-url=https://tq.example.test",
                     '--label=ruler_cluster="example"', "--rule-file=/conf/rules/custom.yml"):
            self.assertIn(flag, ruler["args"])
        self.assertIn({"name": "data", "mountPath": "/ruler/data"}, ruler["volumeMounts"])
        ruler = containers(render({"ruler": {"queryURL": "https://{{ .Release.Name }}.example.test"}}))["ruler"]
        self.assertIn("--alert.query-url=https://example.example.test", ruler["args"])

    def test_listener_service_probe_monitor_and_policy_alignment(self):
        docs = render()
        for workload in workloads(docs):
            name = workload["metadata"]["name"]
            template = workload["spec"]["template"]
            container = template["spec"]["containers"][0]
            ports = {p["name"]: p["containerPort"] for p in container["ports"]}
            self.assertEqual(ports["http"], 10902)
            self.assertIn("--http-address=0.0.0.0:10902", container["args"])
            for probe in ("livenessProbe", "readinessProbe"):
                self.assertEqual(container[probe]["httpGet"]["port"], "http")
            service = next(d for d in docs if d["kind"] == "Service" and d["metadata"]["name"] == name)
            for key, value in service["spec"]["selector"].items():
                self.assertEqual(template["metadata"]["labels"][key], value)
            http = next(p for p in service["spec"]["ports"] if p["name"] == "http")
            self.assertEqual((http["port"], http["targetPort"]), (9090, "http"))
            policy = next(d for d in docs if d["kind"] == "NetworkPolicy" and d["metadata"]["name"] == name)
            allowed = [p["port"] for rule in policy["spec"]["ingress"] for p in rule.get("ports", [])]
            self.assertIn(10902, allowed)
            monitor = next(d for d in docs if d["kind"] == "ServiceMonitor" and d["metadata"]["name"] == name)
            self.assertEqual(monitor["spec"]["endpoints"][0]["port"], "http")

    def test_dependencies_can_be_enabled_individually_and_disabled(self):
        for service in SERVICES:
            with self.subTest(service=service):
                docs = render(enabled={s: s == service for s in SERVICES})
                self.assertEqual(len(workloads(docs)), 1)
        docs = render(enabled={**dict.fromkeys(SERVICES, False), "recieve": True})
        self.assertEqual([d["kind"] for d in docs], ["Secret"])

    def test_service_ingresses(self):
        overrides = {s: {"ingress": {"enabled": True}} for s in ("query", "storegateway")}
        docs = render(resource_overrides=overrides)
        ingresses = {d["metadata"]["name"]: d for d in docs if d["kind"] == "Ingress"}
        self.assertEqual(set(ingresses), {"example-thanos-query", "example-thanos-storegateway-grpc"})
        for name, service, port, host, ingress_class, secret in (
            ("example-thanos-query", "query", 9090, "tq.example.test", "example", "tq-tls"),
            ("example-thanos-storegateway-grpc", "storegateway", 10901,
             "thanos-store.example.test", "konghq", "thanos-store-tls"),
        ):
            ingress = ingresses[name]
            self.assertEqual(ingress["metadata"]["namespace"], "example")
            self.assertEqual(ingress["spec"]["ingressClassName"], ingress_class)
            self.assertEqual(ingress["spec"]["tls"], [{"hosts": [host], "secretName": secret}])
            rule = ingress["spec"]["rules"][0]
            self.assertEqual(rule["host"], host)
            self.assertEqual(rule["http"]["paths"], [{
                "path": "/", "pathType": "ImplementationSpecific",
                "backend": {"service": {"name": "example-thanos-" + service, "port": {"number": port}}},
            }])
        annotations = ingresses["example-thanos-query"]["metadata"]["annotations"]
        self.assertEqual(yaml.safe_load(annotations["ingress.pomerium.io/policy"]), {"allow": []})
        self.assertEqual(annotations["cert-manager.io/cluster-issuer"], "letsencrypt-pomerium")
        annotations = ingresses["example-thanos-storegateway-grpc"]["metadata"]["annotations"]
        self.assertEqual(annotations["konghq.com/protocols"], "grpc,grpcs")
        self.assertEqual(annotations["konghq.com/plugins"], "thanos-store-main-ip-restriction")
        self.assertFalse(any(d["kind"] == "Ingress" for d in render()))
        disabled = render(resource_overrides=overrides, enabled={"query": False, "storegateway": False})
        self.assertFalse(any(d["kind"] == "Ingress" for d in disabled))

    def test_ruler_configuration_validation(self):
        for options in ({"config": ""}, {"alertmanagers": []}):
            with self.subTest(options=options):
                result = render({"ruler": options}, check=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("is required", result.stderr)


if __name__ == "__main__":
    unittest.main()
