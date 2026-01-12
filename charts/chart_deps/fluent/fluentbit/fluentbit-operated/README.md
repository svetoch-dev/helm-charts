# Updates for ArgoCD

When all fluentbit charts are updated (`../`) you must run:

`helm dependency update`


inside this chart's directory. This will regenerate the `charts/fluentbit-*.tgz` archive. Make sure to **commit the updated `.tgz` file** to version control.

> ⚠️ If this step is skipped, changes made to the `fluentbit-*` charts will **not** be reflected in this Helm chart.

This manual step is required because Helm does **not yet support recursive dependency updates**.
See: [helm/helm#30855](https://github.com/helm/helm/pull/30855)
