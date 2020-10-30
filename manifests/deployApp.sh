#Update the local kubeconfig with the credentials and endpoint info to connect to the GKE cluster. 
if [ ! -z "$" ] then
gcloud container clusters get-credentials $cluster_name --region=$region
fi

#Create cluster role binding to make service account the admin of the cluster
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

#Create the Portworx resources. I have already created a portworx storage. The below portworx.yaml is the yaml for the storage i created. 
# kubectl create -f portworx.yaml

#Create the storage class and Persistent Volume Claim to be used by the postgres sql
kubectl create -f storage.yaml

#Create the postgresql deployment
kubectl create -f postgresql.yaml

#Create the qledger deployment
kubectl create -f qledger.yaml
