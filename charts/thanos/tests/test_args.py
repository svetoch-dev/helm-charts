"""Render regressions for the Bitnami-compatible argument defines.

Run with: python3 charts/thanos/tests/test_args.py (requires Helm and PyYAML).
"""

from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml


CHART = Path(__file__).resolve().parents[1]
SERVICES = ("query", "queryFrontend", "compactor", "storegateway", "ruler", "recieve")


def render(thanos_overrides=None, check=True, resource_overrides=None):
    values = {
        "global": {
            "company": {"name": "example"},
            "env": {"short_name": "test", "cloud": {"buckets": {"type": "gcs"}}},
        },
        **{name: {"enabled": True} for name in SERVICES},
    }
    values["ruler"]["common"] = {
        "thanos": {
            "config": "groups: []",
            "alertmanagers": ["http://alertmanager.example:9093"],
        },
    }
    for service, options in (thanos_overrides or {}).items():
        values[service].setdefault("common", {}).setdefault("thanos", {}).update(options)
    for service, options in (resource_overrides or {}).items():
        values[service].setdefault("common", {}).update(options)
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
    return {
        doc["spec"]["template"]["spec"]["containers"][0]["name"]:
            doc["spec"]["template"]["spec"]["containers"][0]
        for doc in yaml.safe_load_all(result.stdout)
        if doc and doc["kind"] in ("Deployment", "StatefulSet")
    }


class ArgumentTests(unittest.TestCase):
    def test_compactor_controls_ports_mounts_and_wait(self):
        container = render({"compactor": {
            "logLevel": "debug", "logFormat": "logfmt",
            "containerPorts": {"http": 12000}, "dataDir": "/compact/data",
            "retentionResolutionRaw": "7d", "retentionResolution5m": "14d",
            "retentionResolution1h": "30d", "consistencyDelay": "15m", "concurrency": 0,
            "extraFlags": ["--delete-delay=72h"],
            "cronJob": {"enabled": True},
        }})["compactor"]
        self.assertEqual(container["args"], [
            "compact", "--log.level=debug", "--log.format=logfmt",
            "--http-address=0.0.0.0:12000", "--data-dir=/compact/data",
            "--retention.resolution-raw=7d", "--retention.resolution-5m=14d",
            "--retention.resolution-1h=30d", "--consistency-delay=15m", "--compact.concurrency=0",
            "--objstore.config-file=/conf/objstore.yml",
            "--delete-delay=72h",
        ])
        self.assertEqual(container["ports"][0]["containerPort"], 12000)
        self.assertIn({"name": "data", "mountPath": "/compact/data"}, container["volumeMounts"])
        self.assertEqual(render()["compactor"]["args"][-1], "--wait")

    def test_custom_args_and_command_bypass_each_builder(self):
        containers = render(resource_overrides={s: {"args": ["--help"], "command": ["thanos"]} for s in SERVICES})
        self.assertEqual(len(containers), 6)
        for container in containers.values():
            self.assertEqual(container["args"], ["--help"])
            self.assertEqual(container["command"], ["thanos"])

    def test_query_discovery_labels_and_tls_key_mapping(self):
        args = render({"query": {
            "replicaLabel": ["replica", "copy"], "existingSDConfigmap": "sd-config",
            "dnsDiscovery": {"enabled": True, "sidecarsService": "prometheus", "sidecarsNamespace": "example"},
            "storegateway": {"enabled": True, "useEndpointGroup": True, "sharded": {
                "enabled": True, "hashPartitioning": {"shards": 2},
                "timePartitioning": [{"min": "-24h"}, {"max": "-24h"}],
            }},
            "grpc": {"server": {"tls": {"enabled": True, "existingSecret": {
                "keyMapping": {"tls-cert": "server.crt", "tls-key": "server.key", "ca-cert": "ca.crt"},
            }}}},
        }})["query"]["args"]
        self.assertIn("--query.replica-label=copy", args)
        self.assertIn("--store.sd-files=/conf/sd/servicediscovery.yml", args)
        self.assertIn("--endpoint=dnssrv+_grpc._tcp.prometheus.example.svc.cluster.local", args)
        self.assertEqual(len([a for a in args if a.startswith("--endpoint-group=")]), 4)
        self.assertIn("--grpc-server-tls-cert=/certs/server/server.crt", args)
        self.assertIn("--grpc-server-tls-client-ca=/certs/server/ca.crt", args)

    def test_query_urls_use_local_service_ports_and_ingress(self):
        containers = render(
            {"ruler": {"query": {"service": {"ports": {"http": 8080}}}}},
            resource_overrides={"query": {"service": {"ports": [{"name": "http", "port": 19090, "targetPort": "http"}]}}},
        )
        self.assertIn("--alert.query-url=http://example-thanos-query.example.svc.cluster.local:19090", containers["query"]["args"])
        self.assertIn("--alert.query-url=http://example-thanos-query.example.svc.cluster.local:8080", containers["ruler"]["args"])
        frontend = {"enabled": True, "ingress": {
            "enabled": True, "hostname": "{{ .Release.Name }}.example.test",
            "overrideAlertQueryURL": True, "tls": True,
        }}
        containers = render({s: {"queryFrontend": frontend} for s in ("query", "ruler")})
        for service in ("query", "ruler"):
            self.assertIn("--alert.query-url=https://example.example.test", containers[service]["args"])

    def test_frontend_store_and_ruler_options(self):
        containers = render({
            "queryFrontend": {"https": {"enabled": True}, "config": "{}"},
            "storegateway": {"indexCacheConfig": "{}", "bucketCacheConfig": "{}", "existingConfigmap": "cache"},
            "ruler": {"dataPath": "/ruler/data", "evalInterval": "5m", "queries": ["http://query.example:9090"],
                      "alertmanagers": [], "alertmanagersConfig": {"alertmanagers": []}},
        })
        for container in containers.values():
            self.assertFalse(any(arg.startswith("--http.config=") for arg in container["args"]))
        self.assertIn("--query-frontend.downstream-url=https://example-thanos-query:9090", containers["query-frontend"]["args"])
        self.assertIn("--query-range.response-cache-config-file=/conf/cache/config.yml", containers["query-frontend"]["args"])
        self.assertIn("--index-cache.config-file=/conf/cache/index-cache.yml", containers["storegateway"]["args"])
        self.assertIn("--store.caching-bucket.config-file=/conf/cache/bucket-cache.yml", containers["storegateway"]["args"])
        self.assertIn("--index-cache.config-file=/conf/cache/config.yml", containers["storegateway"]["args"])
        ruler = containers["ruler"]
        self.assertIn("--alertmanagers.config-file=/conf/alertmanagers/alertmanagers_config.yml", ruler["args"])
        self.assertIn("--eval-interval=5m", ruler["args"])
        self.assertIn("--query=http://query.example:9090", ruler["args"])
        self.assertIn({"name": "data", "mountPath": "/ruler/data"}, ruler["volumeMounts"])

    def test_receive_ports_path_replication_and_object_store_condition(self):
        receive = render({"recieve": {
            "containerPorts": {"http": 19092, "grpc": 19091, "remote": 19292, "capnproto": 19392},
            "tsdbPath": "/receive/data", "tsdbRetention": "30d", "replicationProtocol": "grpc",
            "replicationFactor": 3, "service": {"additionalHeadless": True},
        }})["receive"]
        self.assertIn("--receive.local-endpoint=$(NAME).example-thanos-receive-headless.$(NAMESPACE).svc.cluster.local:19091", receive["args"])
        self.assertIn("--receive.replication-factor=3", receive["args"])
        self.assertIn("--receive.replication-protocol=grpc", receive["args"])
        self.assertIn("--tsdb.retention=30d", receive["args"])
        self.assertIn({"name": "data", "mountPath": "/receive/data"}, receive["volumeMounts"])
        self.assertEqual(next(p["containerPort"] for p in receive["ports"] if p["name"] == "remote-write"), 19292)
        args = render({"recieve": {"objstoreConfig": "", "existingObjstoreSecret": "", "mode": "router-ingestor"}})["receive"]["args"]
        self.assertFalse(any(a.startswith("--objstore.config=") or a.startswith("--receive.hashrings-file=") for a in args))

    def test_ruler_configuration_validation(self):
        for options in ({"config": ""}, {"alertmanagers": [], "alertmanagersConfig": {}}):
            with self.subTest(options=options):
                result = render({"ruler": options}, check=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("is required", result.stderr)
        result = render({"ruler": {"alertmanagersConfig": {"alertmanagers": []}}}, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("mutually exclusive", result.stderr)


if __name__ == "__main__":
    unittest.main()
