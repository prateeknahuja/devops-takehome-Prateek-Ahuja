
Please follow the step by step instructions below to create a Regional cluster in GKE that hosts the Qledger app and a postgresql database. 


##############################
Prerequisites
##############################

	1. To run the qledger app on GKE, you need a Google Cloud Platform account. If you don't have a GCP account, create one now. Using the instructions on the link below
		
		https://cloud.google.com/apis/docs/getting-started

		##### NOTE: If you are creating the account for the first time, you will have to enter the credit card information. 
		Google provides a free credit of $300 USD which you can use to replicate the setup for the qledger app.


	2. A system with Docker installed and connected to docker hub. 



##############################
Setting up GCP
##############################

In addition to a GCP account, follow the instructions below to setup the GCP:

    
    1. GCP organizes resources into projects. Create a GCP project in the GCP console. You'll need the Project ID later. You can see a list of your projects in the cloud resource manager. 
	    Refer to the below link for instructions to create a project in GCP:
		    https://cloud.google.com/resource-manager/docs/creating-managing-projects#console
			
			
			** For simplicity sake, name the project koho-demo

    
    2. On the Google cloud platform, make sure you have the Compute engine api and Kubernetes Engine api installed. The instructions to install the apis are also at the link above.
        NOTE: Make sure the project you're using for this demo is selected
		- On the GCP console, search API and services.
		- Click library, and then search for Kubernetes Engine Api
		- Click enable
		- Then do the same for the Compute Engine API

    3. A GCP service account key: Terraform will access your GCP account by using a service account key. Create one now in the console. When creating the key, use the following settings:
        - Select the project you created in the previous step.
        - Under "Service account", select "New service account".
        - You can give it any name you like but for simplicity sake, name the service account koho-sa
        - For the Role, choose "Project -> Owner".  (Make sure the role is selected as Owner otherwise you wont be able to created RBAC policy)
        - Leave the "Key Type" as JSON.
        - Once the service account is created, click "..." (vertical dots) next to the service account you just created. 
            Click 'Create key', select the key type as json and save the key file to provisioning directory on the root of the project.
			
			**** NOTE: Make sure you place it in the provisioning directory at the root of the project. 
    
    4. Also make sure the Billing is setup and enabled. This is required to run the apis we enabled in step 2. 


########################################
Connect to GKE (via Docker container)
########################################

1. Make sure that the service account key json file is placed into the ~/provisioning directory. 
   **** Rename the file to sa.json ****
   
   NOTE:  When the docker container for gke connect start, the provisioning files will be baked into the container image. 
          (For service account, this technique is only used in the current scenario. Ideally this sa.json file should be kept securely 
          in some kind of vault and can be injected into the container at the startup time as an environment variable.)


2. Open the variables.auto.tfvars file in the provisioning directory and enter the below values for the project you created in the GCP account.
    *  project id 
    *  region 
    *  cluster name
    *  Number of nodes you need to provision in the cluster. Set this to 2 which means 2 nodes in every zone. 
       NOTE: By default the nodes are configured to be preemptible nodes. (to save the cost) 


3. In the root of the project, you will find the file env.txt. This file stores additional info for connecting to GCP. 
   We use this file as environment file while starting the gkeconnect container. All the values from this file can then be used as environment variables inside the container. 
   
   Enter the below info in the file
    * gcp_svc_act_email -   Enter the full email of the service account for ex. koho-sa@koho-demo.iam.gserviceaccount.com. You can find this on the GCP console. 
    * project_id -  Enter the GCP project id.
    * cluster_name -  Enter the name of the cluster that you will be creating on the GKE. This project is tested in us-east1
    * region - Enter the region in which the cluster is created. 

    NOTE: Do not enter the values inside double quotes "". Refer to the current file and enter the values like that.
          Also, make sure you enter the same values as you entered in the variables.auto.tfvars file in step2. 



3. Open a command prompt. And run the setupEnv.bat script located at the root directory of the project as shown below. 
		setupEnv.bat
		
   NOTE: If you are on linux or mac. Rename this file to extension .sh and then run it like ./setup.sh
   

   This will create a docker base image for connecting to gke on your local machine with all the required manifests and provisioning files. 


4. Now run gkeconnect.bat which will start a gkeconnect container. 
   Note: If you are on linux or mac. Rename this file to extension .sh and then run it. 
   
   Once this script runs successfully, you will land at the root, inside the gkeconnect container




###################################################
Provision GKE Regional Cluster Using Terraform
###################################################
**context - Inside the gkeconnect container

*** NOTE : Below instructions are for creating a GKE cluster on the GCP. 
            This is a one time setup. If the cluster is created already skip to the next stage of deploying the apps. 

1. Go to /webapps/provisioning directory using below command. 
    cd /webapps/provisioning

2. Run the below command to initialize the terraform.
    terraform init

3. Then apply the configuration on the GKE cluster using below command
    terraform apply

    This will prompt to confirm. Type 'yes' and press enter.
    Note: This may take some time, as it will create a GKE cluster.

4. Once it finishes successfully, check the cluster configuration on the GCP console. The cluster should have 2 nodes per zone in the region.



###################################################
Connect to the GKE Cluster 
###################################################

1. In order to connect to the GKE Cluster. We need to authenticate using the sa.json file. Run below command as it is to authenticate
    
        gcloud auth activate-service-account $gcp_svc_act_email --key-file=/webapps/provisioning/sa.json --project=$project_id

        Note: The values for the $gcp_svc_act_email and $project_id come from the environment variables that you specified in the env.txt. 


2. Connect the kubectl to the GKE cluster. This step will upadate the local kubeconfig file with the connection details of GKE cluster. Use the below command 
    
        gcloud container clusters get-credentials $cluster_name --region=$region


3. Test the connection by running 
    kubectl get nodes




###################################################
Deploy the applications to the kubernetes cluster
###################################################
If you haven't connected to the GKE cluster already, use the section above to connect the kubectl with the GKE cluster. 

1. Inside the same container image, go to the manifests directory
    cd /webapps/manifests

2. Run the script deployApp.sh 
    ./deployApp.sh

    This will create the below kubernetes resources
    
        - Deployment of Qledger app which spins up 3 pods of the qledger app. 
    
        - Load Balancer Service to expose the qledger app deployment on port 8080. 
            You can use the external ip of this service to communicate with the app. 
    
        - Deployment of Postgres sql with 1 pod. 
        - Cluster Ip service to expose the deploment on port 5432 inside the cluster.

		
		
		
NOTES:

1. Since the application runs on kubernetes in a multi region it enables the high availability for the qledger app. 
	If a pod goes down, the deployment controller will spin up a new pod automatically. 
	If a node goes down in one zone, The new pods gets scheduled in the available nodes on the other zones in the region. 

2. For Postgres database, I am currently using the Persistent volume and Persistent volume claim which will make sure the data is retained even if the pod goes down. 
	If the Pod goes down, the deployment controller will schedule another pod for database and still point to the same Persistent volume so that the data is retained. 
	
	
	IMPORTANT : Currently the persistent volume is using the hostpath as a volume type. Hostpath is available as long as the node is available.


	

