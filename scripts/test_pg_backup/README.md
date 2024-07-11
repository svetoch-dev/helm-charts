# Usage

Fill in the fields uid and timestamp for quick testing of PG backup, in file test_'product'.yaml

To create a PG_clone, use the command:
kubectl apply -f test_chents.yaml -n chents
or
kubectl apply -f test_vaults.yaml -n vaults

After testing, use this command to delete PG_clone:
kubectl delete -f test_chents.yaml
or
kubectl delete -f test_vaults.yaml

