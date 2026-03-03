# Scripts
Various scripts

## pg_operator.alias
Bash functions that help connect to postgres operator clusters

### Usage

```
. scripts/pg_operator.alias
```

#### port-forward

```
CLUSTER=<cluster name> NAMESPACE=<namespace> pg_connect
```

* `<cluster name>` - name of postgres cluster full list of pg clusters you can get using the command 

```
kubectl get postgresql -A -o jsonpath="{ .items[*].metadata.name}"
```

* `<namespace>` - namespace where the cluster is installed

#### pg credentials

```
CLUSTER=<cluster name> NAMESPACE=<namespace> DB=<db> pg_creds
```

* `<cluster name>` - name of postgres cluster full list of pg clusters you can get using the command 

```
kubectl get postgresql -A -o jsonpath="{ .items[*].metadata.name}" 
```

* `<namespace>` - namespace where the credentials secrets are installed

* `<db>` - database to which to connect to

After executing this function

* PGPASSWORD
* PGHOST
* PGUSER
* PGDATABASE

env vars are populated

### Examples

```
$ CLUSTER=postgres-main NAMESPACE=postgres pg_connect
$ CLUSTER=postgres-main NAMESPACE=apps DB=apps pg_creds
```


## port_forward_redis_master.sh
Bash script that help connect to pod redis master (port 6379)

### Usage

```
scripts/port_forward_redis_master.sh namespace local_port_number
```

#### description

```
You should set the namespace for the redis application, if the namespace is not set, the script will try to use the 'NAMESPACE' environment variable, if it is not set, a request will be issued to set the variable.
You can specify the local port number by passing it after the namespace name, if you do not specify a port, the default will be used 6379.
The script checks for the presence of redis pods in setted namespace, determines which of the pods is master and which port is used. 
As a result, the script makes a forwarding of the user port 6379 to the pod and show redis password.
if you plane to work from another local machine, then you need to uncomment the code --address='0.0.0.0'
```

### Examples

```
$ scripts/port_forward_redis_master.sh
$ scripts/port_forward_redis_master.sh apps 6379
$ scripts/port_forward_redis_master.sh apps
$ bash scripts/port_forward_redis_master.sh

```
