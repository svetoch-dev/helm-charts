# Upgrade to v11
## Postgres
Important note on deprecated K8s Endpoints
We swithced `Postgres-operator` `kubernetes_use_configmaps` to `True`. For clusters with replicas you cannot easily switch from using Endpoints to ConfigMaps without risking a split-brain scenario because Patroni would read DCS-related facts from both these resources at the same time during a rotation. There are two possible migration paths:

1. Migrate in-place
This migration path requires steps to be deployed separately:

* Scale in all your database clusters to only one primary pod. This can be achivied with the max_instances config option set to '1'. A config change requires an operator pod restart. Make sure every Postgres cluster is scaled in to one pod before proceeding.
* Change the operator config again and enable kubenertes_use_configmaps. Check if extra ConfigMaps ('-config' and '-failover') are created. It will also trigger a pod rotation and, since there's only the primary left, it will cause downtime.
* Revert step 1, so all clusters are scaled out again.
(Optional) Remove all the Endpoints the Postgres Operator has managed before. But they do not cause eny harm if you leave them.
* If you do not want to migrate all your clusters at once you can try working with multiple Postgres Operators instances that use different configs but have a CONTROLLER_ID specified. By annotating the Postgres manifest with different controller ids, you could move a single cluster through the migration steps mentioned above.

2. Migrate via standby clusters
To reduce impact during the migration one can also do the following steps:

* Set up a second Postgres Operator (+ CONTROLLER_ID specified) running with ConfigMaps
* Create standby clusters to all Postgres resources (or one by one). The standbys would then be managed by the second operator using the annotation with the corresponding controller ID. Ideally, also copy all secrets of the source cluster beforehand to avoid connection issues later (see docs).
* Stop writes on the source cluster and promote the standby cluster. Downtime depends mostly on the deployment time of your app to point to the new database cluster.

## Redis
Redis was migrated from the Spotahome Redis Operator to the Opstree Redis Operator.
This migration replaces the operator, CRDs, Redis custom resources, and generated
Redis Services. Treat it as a Redis cluster replacement unless the application has a
tested data migration path.

1. Decide how Redis data will be handled before changing operators or CRDs.

If Redis is used only as cache, document that cache loss is acceptable for the
application. If Redis data must be preserved, create a backup or export from the old
cluster before stopping the old operator or switching applications. For example, use
an application-specific export, `redis-cli --rdb`, or another tested Redis migration
procedure.

2. Check that new Redis resources do not conflict with existing Spotahome resources.
   Render the downstream chart before applying it:

```bash
helm dependency update <chart>
helm template <release-name> <chart> -n <namespace>
```

Use these placeholders when checking rendered names:

* `<operator-release>` is the Helm release that installs the Redis Operator chart,
  for example `redis-gcp-int`.
* `<app-release>` is the Helm release that installs Redis as an application
  dependency, for example `argocd-gcp-int`.
* The downstream dependency should use the `redis-operated` chart with alias
  `redis`. With that alias, Redis resource names use `<app-release>-redis-*`.
  If the chart is rendered directly without alias, names use
  `<release-name>-redis-operated-*` instead.

Expected main Opstree operator resources in the operator namespace:

* `Deployment/<operator-release>-redis-operator`
* `ServiceAccount/<operator-release>-redis-operator`
* `ClusterRole/<operator-release>-redis-operator`
* `ClusterRoleBinding/<operator-release>-redis-operator`
* `PodMonitor/<operator-release>-redis-operator`

For example, with operator release `redis-gcp-int`:

* `Deployment/redis-gcp-int-redis-operator`
* `ServiceAccount/redis-gcp-int-redis-operator`
* `ClusterRole/redis-gcp-int-redis-operator`
* `ClusterRoleBinding/redis-gcp-int-redis-operator`
* `PodMonitor/redis-gcp-int-redis-operator`

Expected main Opstree Redis resources in the application namespace:

* `RedisReplication/<app-release>-redis-cluster`
* `RedisSentinel/<app-release>-redis-sentinel`
* `StatefulSet/<app-release>-redis-cluster`
* `StatefulSet/<app-release>-redis-sentinel-sentinel`
* `Pod/<app-release>-redis-cluster-0..N`
* `Pod/<app-release>-redis-sentinel-sentinel-0..N`
* `ServiceMonitor/<app-release>-redis-cluster`
* `ServiceMonitor/<app-release>-redis-sentinel`

For example, with application release `argocd-gcp-int`:

* `RedisReplication/argocd-gcp-int-redis-cluster`
* `RedisSentinel/argocd-gcp-int-redis-sentinel`
* `StatefulSet/argocd-gcp-int-redis-cluster`
* `StatefulSet/argocd-gcp-int-redis-sentinel-sentinel`
* `Pod/argocd-gcp-int-redis-cluster-0..N`
* `Pod/argocd-gcp-int-redis-sentinel-sentinel-0..N`
* `ServiceMonitor/argocd-gcp-int-redis-cluster`
* `ServiceMonitor/argocd-gcp-int-redis-sentinel`

Expected main Opstree Services created by the operator:

* `Service/<app-release>-redis-cluster`
* `Service/<app-release>-redis-cluster-additional`
* `Service/<app-release>-redis-cluster-headless`
* `Service/<app-release>-redis-cluster-master`
* `Service/<app-release>-redis-cluster-metrics`
* `Service/<app-release>-redis-cluster-replica`
* `Service/<app-release>-redis-sentinel-sentinel`
* `Service/<app-release>-redis-sentinel-sentinel-additional`
* `Service/<app-release>-redis-sentinel-sentinel-headless`
* `Service/<app-release>-redis-sentinel-sentinel-metrics`

For example, with application release `argocd-gcp-int`:

* `Service/argocd-gcp-int-redis-cluster`
* `Service/argocd-gcp-int-redis-cluster-additional`
* `Service/argocd-gcp-int-redis-cluster-headless`
* `Service/argocd-gcp-int-redis-cluster-master`
* `Service/argocd-gcp-int-redis-cluster-metrics`
* `Service/argocd-gcp-int-redis-cluster-replica`
* `Service/argocd-gcp-int-redis-sentinel-sentinel`
* `Service/argocd-gcp-int-redis-sentinel-sentinel-additional`
* `Service/argocd-gcp-int-redis-sentinel-sentinel-headless`
* `Service/argocd-gcp-int-redis-sentinel-sentinel-metrics`

Applications that connect directly to Redis should use the Redis master Service:

* `Service/<app-release>-redis-cluster-master`

Old Spotahome resources usually have different prefixes, for example `rfr-*`,
`rfs-*`, and `rfrm-*`. If any old and new resource names overlap in the target
namespace, stop and override the new chart names before applying.

3. Replace Redis Operator CRDs.

Install the Opstree Redis Operator CRDs before applying new Redis resources.
Do not delete the old Spotahome CRDs before old Spotahome Redis resources are
removed. Kubernetes needs the old CRDs to manage and delete existing old custom
resources cleanly.

4. Remove the old Spotahome Redis Operator and deploy the new Opstree Redis
   Operator.

Stop the old operator first, then install and sync the new operator chart. Verify
that the new operator pod is running before creating Redis custom resources.

5. Create the new Redis clusters.

Enable the new Redis chart in downstream values and keep only overrides that differ
from this chart's defaults. Do not copy old Spotahome values such as:

```yaml
redis:
  auth:
    secretPath: redis
  redisServiceMonitor: {}
  sentinelServiceMonitor: {}
```

Create `RedisSentinel` only after `RedisReplication` is created and healthy. The
sentinel resource references the replication resource by name, so applying both at
the same time can fail or reconcile incorrectly if the replication cluster is not
ready yet.

After sync, verify that the new `RedisReplication`, `RedisSentinel`, Redis pods, and
Redis Services are created and healthy.

6. Migrate data and switch applications to the new Redis clusters.

There is no automatic migration from Spotahome Redis to Opstree Redis in this chart.
Choose one of these paths per application:

* If Redis is used only as cache, accept cache loss and switch the application to
  the new Redis master Service.
* If Redis data must be preserved, migrate it explicitly before switching traffic,
  for example with an application-specific export/import, `redis-cli --rdb`, or a
  controlled key copy process.

Applications that connect directly to Redis should use:

* `REDIS_HOST=<app-release>-redis-cluster-master`
* `REDIS_PORT=6379`
* `REDIS_PASSWORD` from the Redis password Secret

Applications that use Sentinel must be pointed to the new Opstree Sentinel Service.
Do not point `REDIS_SENTINEL_HOST` to the Redis master Service.

The Sentinel Service name is based on the Redis sentinel name:

* `Service/<app-release>-redis-sentinel-sentinel`

Typical Sentinel client settings:

* `REDIS_SENTINEL_HOST=<app-release>-redis-sentinel-sentinel`
* `REDIS_SENTINEL_PORT=26379`
* `REDIS_SENTINEL_NAME=mymaster`
* `REDIS_SENTINEL_PASSWORD` from the Redis password Secret

7. Remove old Redis resources manually.

After applications are switched and verified, delete the old Spotahome Redis custom
resources and generated objects. Then delete the old Spotahome CRDs manually when no
old Redis resources remain.
