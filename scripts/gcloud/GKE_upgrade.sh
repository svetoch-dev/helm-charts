#!/bin/bash
if [[ ! -z $* ]]; then
	project=$1
	gcloud config set project $project
	kube_context=$(kubectl config get-contexts | grep $project | awk '{print $(NF-2)}')
	kubectl config use-context $kube_context
	#gcloud auth application-default set-quota-project $project
fi
container_clusters_list=$(gcloud container clusters list)
echo "$container_clusters_list"
location=$(echo "$container_clusters_list" | awk 'NR==2{print $2}')
cluster=$(echo "$container_clusters_list" | awk 'NR==2{print $1}')
master_version=$(echo "$container_clusters_list" | awk 'NR==2{print $3}')
node_version=$(echo "$container_clusters_list" | awk 'NR==2{print $6}')
valid_versions=$(gcloud container get-server-config --flatten="channels" --filter="channels.channel=REGULAR" --format="yaml(channels.channel,channels.validVersions)" --location=$location | awk 'FNR>3 {print $2}')
echo "valid versions in REGULAR channel: "
echo "$valid_versions"
read -p "enter what you want to update, master or nodes: " entity
if [[ "$entity" == "master" ]]; then
	echo "your master version is $master_version"
	read -p "enter the version to upgrade the master of a cluster: " user_master_version
	gcloud container clusters upgrade $cluster --cluster-version=$user_master_version --master --location=$location
elif [[ "$entity" == "nodes" ]]; then
	gcloud config set container/cluster $cluster
	node_pools=($(gcloud container node-pools list --cluster $cluster --location $location | awk 'FNR>1 {print $1} {ORS=" "}'))
	for node_pool in ${node_pools[@]}; do
		pdbs=($(kubectl get pdb -A | grep postgres | awk '{ORS=" "} {print $1,$2}'))
		for index in ${!pdbs[@]}; do
			remainder=$(($index % 2))
			if [[ ("$remainder" -ne "0") && ("$index" -ne "0") ]]; then
				echo "it is necessary to delete pdb ${pdbs[$index]} in namespace ${pdbs[$(($index-1))]}"
				read -p "Do you want to continue (Y/n)? " delete_yes
				if [[ ("$delete_yes" == "yes") || ("$delete_yes" == "y") || ("$delete_yes" == "Y") ]]; then
					kubectl delete pdb ${pdbs[$index]} -n ${pdbs[$(($index-1))]}
				else
					exit 1
				fi
			fi
		done
		echo "upgrading node-pool $node_pool"
		gcloud container clusters upgrade $cluster --cluster-version=$master_version --location=$location --node-pool=$node_pool
	done
	pg_operators=($(kubectl get pods -A | grep postgres | grep operator | awk '{ORS=" "} {print $1,$2}'))
	for operator_index in ${!pg_operators[@]}; do
		operator_remainder=$(($operator_index % 2))
		if [[ ("$operator_remainder" -ne "0") && ("$operator_index" -ne "0") ]]; then
			kubectl delete pod ${pg_operators[$operator_index]} -n ${pg_operators[$(($operator_index-1))]}
		fi
	done
else
	echo "an incorrect value was entered"
fi
