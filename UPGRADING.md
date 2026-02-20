# Upgrade to v11
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
