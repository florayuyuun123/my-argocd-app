# Step 1: Prepare GitHub Repo
## Push code to git repository
* cd to the directory on your local machine
* run git init
* run git status
* run git remote -v (this displays the origin you are in)
* run git remote add alias_name eg.(flora) then your repo url
* run git remote -v to Verify
* run git push -u <alias_name> main

# Prepare the EC2 Instance in AWS management console.
* Launch an Ubuntu EC2 Instance:
 - Choose an instance type with at least 2 vCPUs and 2 GB of RAM (recommended t3.medium).
 - Select Ubuntu 22.04 or 24.04 as the AMI.
 - Open the following ports in the Security Group:

80: for internet access, 443: for https access, 22: For SSH access, 8080: To access ArgoCD UI.

 - Connect to the EC2 Instance via SSH:

``` 
ssh -i <your-key-pair.pem> ubuntu@<ec2-instance-public-ip>
```

Update System Packages:

```
sudo apt-get update && sudo apt-get upgrade -y
```

### it is a good practice not to work as a root user and therefore there is need to create a user

 - create a user

```
sudo adduser <your_username>
```

 - disable user password

```
sudo passwd -d <your_username>
```

 - add user to sudoers group

```
sudo usermod -aG sudo <your_username>
```

 - Configure the host.
run the following command. In the edditor, replace the IP address of the host with your desired host name.

```
sudo /etc/hosts
```

OR

```
sudo hostnamectl set-hostname <chose a hostname, e.g controle plane>
```

 - To impliment the changes, run this command:

```
exec bash 
```

 - Suitch user

``` 
sudo su - <your_username>
```

## Install AWS CLI on your Ubuntu EC2 instance:

    ```
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version
    ```

* Alternatively, run the commands to download and Install AWS CLI v2 one after ther other.
 - Download the AWS CLI v2 Installer:

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

 - Verify the File Download (Optional)
You can use ls to check if the file awscliv2.zip exists and has a reasonable file size (approximately 35-40 MB):

```
ls -lh awscliv2.zip
```

 - Install unzip

``` 
sudo apt install unzip
```

 - Unzip the Installer. Now unzip the file:

```
unzip awscliv2.zip
```

 - Run the Installer. Once unzipped, run the installer:

```
sudo ./aws/install
```

 - Verify the Installation. After installation, confirm the version:

```
aws --version
```

## Configure AWS
aws configure
Enter:
Region: us-west-2
Access Key ID/Secret Key: Use your AWS credentials.
Default Output: json.

## Install Docker
* Install Docker using apt: This is the most common way to install Docker on Ubuntu.

```
sudo apt update
sudo apt install docker.io -y
```

 - Verify Docker Installation: After installation, check that Docker is installed correctly by running:

```
docker --version
```

 - Enable and start the Docker service:

```  
sudo systemctl enable docker
sudo systemctl start docker
```

 - Once Docker is installed and running, try the original ECR login command:

```
aws ecr get-login-password --region <your
_region> | docker login --username AWS --password-stdin <your_ecr_repo_URI> 
```

 - Add User to Docker Group: Run the following command to add your user ($USER) to the docker group:

```
sudo usermod -aG docker $USER
```

* Restart Your Session:
After adding your user to the Docker group, you need to restart your session for the changes to take effect. You can either log out of the server and log back in or use the following command:

```
newgrp docker
```

* Install pass (Linux Password Store):

```
sudo apt install pass -y
```

 - Set Up docker-credential-pass: Install and configure the credential helper by following Docker’s documentation. After setup, configure Docker to use it:

``` 
git clone https://github.com/docker/docker-credential-helpers.git
```

* Install make
First, install make so you can build the credential helper:

```
sudo apt update
sudo apt install make -y
```

* Install go (if Not Already Installed)
Since the credential helpers are written in Go, you’ll need Go installed as well. If it’s not already installed, you can install it with the following command

```
sudo apt install golang-go -y
```

 - Rebuild the Credential Helper
Once make and go are installed, navigate back to the docker-credential-helpers directory and build the pass credential helper:

```
cd docker-credential-helpers
```

```
make pass
```

 - Move the Built Credential Helper to /usr/local/bin
After the build is successful, move the docker-credential-pass binary to a directory in your PATH, such as /usr/local/bin: run the following command to find the path.

```
find . -name "docker-credential-pass"
```

```
sudo mv ./bin/docker-credential-pass /usr/local/bin/
```

```
ls -l /usr/local/bin/docker-credential-pass
```

 - Verify the Installation.
To confirm that docker-credential-pass was installed successfully, check its version or path:

```
docker-credential-pass --help
```

 - Configure Docker to Use the Credential Store: Update the Docker configuration to use pass as the credential store by adding the following in ~/.docker/config.json:

```
nano ~/.docker/config.json
```

```
{
  "credsStore": "pass"
}
```

## Install kubectl (Kubernetes CLI to manage clusters):

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

## Install eksctl (to create EKS clusters easily): OPTIONAL

    ```
    curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
    tar -xzf eksctl_Linux_amd64.tar.gz
    sudo mv eksctl /usr/local/bin/
    eksctl version
    ```

## Install ArgoCD CLI:

```
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
argocd version
```

### Other Installations
* Install Node.js and npm:

```
sudo apt-get install nodejs npm

```
* Verify the installation:

```
node -v
npm -v
```

* Install Snyk
Once Node.jsand npm are installed, you can install Snyk using npm:

Install Snyk globally:

```
npm install -g snyk
```

* Verify the installation:

```
snyk -v
```

* Authenticate Snyk
To use Snyk, you'll need to authenticate using your Snyk token:

```
snyk auth <YOUR_SNYK_TOKEN>
```

# Step 2: Create an EKS Cluster
Why?
You need a Kubernetes cluster to run ArgoCD and deploy applications.

```
aws eks create-cluster \
    --name flo-argo-cluster \
    --region us-west-2 \
    --role-arn arn:aws:iam::642588679360:role/flora-iamrole-nodegroup \
    --resources-vpc-config subnetIds=subnet-0545b32161e7a077a,subnet-07ab1fe52e2842780,securityGroupIds=sg-0fc0dcbf7d563f051
```

### Create an IAM role with the following managed permisions and attach to the cluster during cluster creation.
AmazonEKSNetworkingPolicy
AmazonEKSLoadBalancingPolicy
AmazonEKSComputePolicy
AmazonEKSClusterPolicy
AmazonEKSBlockStoragePolicy
AmazonEC2ContainerRegistryFullAccess

### Verify the cluster is running:

```
kubectl get nodes
```

### Create Node Group

```
aws eks create-nodegroup \
    --cluster-name flo-argo-cluster \
    --nodegroup-name flo-nodegroup \
    --node-role arn:aws:iam::642588679360:role/flora-AmazonEKSAutoClusterRole \
    --subnets subnet-0545b32161e7a077a subnet-07ab1fe52e2842780 \
    --scaling-config minSize=1,maxSize=1,desiredSize=1 \
    --instance-types t3.medium \
    --disk-size 20 \
    --region us-west-2
```

### Create an IAM role with the following managed permisions and attach to the nodegroup during nodegroup creation.

    AmazonEC2ContainerRegistryReadOnly
    AmazonEKS_CNI_Policy
    AmazonEKSWorkerNodePolicy

### Create an ec2 inline policy (json) and add the following permissions. This will aid the nodes to join the cluster.

```
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "eks:DescribeCluster",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "*"
    }
  ]
}
```

### Confirm the node group status:

```
aws eks describe-nodegroup --cluster-name flo-argo-cluster --nodegroup-name flo-nodegroup --region us-west-2
```

### Verify nodes are added to the cluster

```
kubectl get nodes
```

```
eksctl get nodegroup --cluster flo-argo-cluster --region us-west-2
```

### Update kubeconfig (connect kubectl to your EKS cluster):

```
aws eks --region us-west-2 update-kubeconfig --name my-cluster
```

* The JSON Web Token (JWT) is used for authentication when making API calls to your EKS cluster. This token is typically generated by the Kubernetes API server and is used to authenticate service accounts.

```
kubectl create serviceaccount infinisys-account -n infinisys-webapp
```

* Create a Role and RoleBinding:
If needed, create a Role and RoleBinding to give the service account the necessary permissions. For example, to give the service account access to list pods.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: my-namespace
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: my-namespace
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: my-namespace
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
```
* Retrieve the Token:
Retrieve the token associated with the service account. Replace my-namespace and my-service-account with your values.

```
kubectl get secret $(kubectl get serviceaccount my-service-account -n my-namespace -o jsonpath="{.secrets[0].name}") -n my-namespace -o jsonpath="{.data.token}" | base64 --decode
```

* This command will output the token in plain text, which you can then use in your kubeconfig file.

### Check the cluster status

```
aws eks describe-cluster --name <cluster_name> --region <region>
```

### Check the node group status:

```
aws eks describe-nodegroup \
    --cluster-name <cluster_name> \
    --nodegroup-name nodegroup_name \
    --region <region>
```

```
aws eks describe-nodegroup --cluster-name <cluster_name> --nodegroup-name <nodegroup_name> --region <region> --query "nodegroup.status"
```

### Delete cluster

```
eksctl delete cluster --name <cluster_name> --region <region>
```

### Verify nodes in the cluster:

```
kubectl get nodes
```

### Investigate the Node Group incase of Failure

```
aws eks describe-nodegroup \
    --cluster-name <cluster_name> \
    --nodegroup-name nodegroup_name \
    --region <region> \
    --query "nodegroup.statusReason"
```

### Delete the failed node group if need be.

```
aws eks delete-nodegroup \
    --cluster-name <cluster_name> \
    --nodegroup-name nodegroup_name \
    --region <region>
```

### The error indicates that kubectl is unable to connect to the Kubernetes API server because it’s trying to access a local server (localhost:8080) instead of the EKS cluster's API endpoint. This typically happens when the kubeconfig is not correctly set up or is pointing to the wrong cluster 

* Verify kubeconfig Setup
  - Ensure your kubeconfig file is correctly configured to point to your EKS cluster.
  - Update kubeconfig for Your EKS Cluster: Use the following AWS CLI command to generate the proper kubeconfig:

```
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

 - Check kubeconfig Location: The updated kubeconfig is typically stored in ~/.kube/config. Verify it:

```
cat ~/.kube/config
```

# step 3: Install ArgoCD:

```
kubectl create namespace argocd
```

```
 kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
 ```

* Verify the ArgoCD Installation:
  - After installation, you can check the status of ArgoCD pods to ensure everything is running:

```        
kubectl get pods -n argocd
```
* Option 1: Change Service Type to LoadBalancer
  - This option makes ArgoCD accessible from outside the cluster by assigning a public IP address.
  - Change the Service Type:
  - Update the argocd-server service to use LoadBalancer type:
        
```        
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

  - Check for External IP:
  - After a few moments, Kubernetes will allocate an external IP address to the argocd-server service. You can check the status with:

```        
kubectl get svc argocd-server -n argocd
```

  - Once an external IP appears in the EXTERNAL-IP column, you can access ArgoCD at https://<external-ip>.
  - NOTE: This approach may incur additional costs if using cloud load balancers.
        
* Option 2: Use Port Forwarding (Recommended for Quick Access)
  - If you only need temporary access, port forwarding is a secure and cost-effective way to access the ArgoCD UI.
  - Run Port Forwarding:
  - Run the following command on your EC2 instance (or wherever you have access to kubectl):

```       
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Access ArgoCD UI

Open the URL in Your Browser:
Go to the following URL in your browser: replace the following URL with that of your on external-IP

https://a6ba9acf0aaaf45688787039fdb779de-2124910579.us-east-1.elb.amazonaws.com

* Log in to ArgoCD:
  - The default ArgoCD username is admin.
  - To get the initial password, run:

```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
Replace the following with your own password and longin to the argocd UI
Passwd: ws15tEtt-wcBZ3OK

# Take note of the following after installing argocd.

* Update PATH if Necessary
If /usr/local/bin is not in your PATH, add it by updating your shell configuration file (e.g., .bashrc, .zshrc, or .profile):
Open the configuration file in a text editor:

```
nano ~/.bashrc
```

Add the following line:

```
export PATH=$PATH:/usr/local/bin
```

Reload the configuration:

```
source ~/.bashrc
```

```
argocd login <ARGOCD_EXTERNAL_IP OR SERVER> --username <USERNAME> --password <PASSWORD>
```

Add github repo to argocd

```
argocd repo add https://github.com/ms-solutions-projects/infinisys-webapp.git --username florayuyuun123 --password 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 --type git
```

Create argocd app

```
argocd app create infinisys-webapp \
  --repo <github_repo_url> \
  --path config/k8s/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated
```

Run your original command to sync the application:

```
argocd app sync infinisys-webapp \
  --grpc-web \
  --insecure \
  --server <Argocd_External_IP> \
  --timeout 300
```

Add github repo to argocd 

```
argocd repo add <argocd_repo_name> \
  --username <your-github-username> \
  --password <your-personal-access-token> \
  --type git
```


* NOTE THIS ERROR: account 'admin' does not have apiKey capability
  - This error occurs because API tokens (API keys) are disabled for the admin account in ArgoCD. To fix this, you need to enable API key capabilities for the admin account.

* Step 1: Enable API Tokens for Admin and Edit the ArgoCD ConfigMap

```
kubectl edit configmap argocd-cm -n argocd
```

Find the accounts.admin section and enable API key capability:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  accounts.admin: apiKey, login
```

Save and exit the editor.

* Step 2: Restart ArgoCD Server. After modifying the ConfigMap, restart the ArgoCD server to apply changes:

```
kubectl rollout restart deployment argocd-server -n argocd
```

* Step 3: Generate the API Token. Once ArgoCD restarts, try generating the token again:

```
argocd account generate-token --account admin
```
If successful, copy and store the token securely.

* Step 4: Use API Token in GitHub Actions incase you dont want to use argocd password. Add the token as a GitHub Secret (ARGOCD_TOKEN).
Modify the GitHub Actions workflow to use the token:

```
- name: Authenticate to ArgoCD
  run: |
    argocd login ${{ secrets.ARGOCD_SERVER }} \
      --username admin \
      --password ${{ secrets.ARGOCD_TOKEN }} \
      --grpc-web \
      --insecure
```

Get the ECR Login Password

aws ecr get-login-password --region us-west-2
This will return a long password (token) that is valid for 12 hours.
On your argocd UI, click on "pod"; copy image (e.g 642588679360.dkr.ecr.us-west-2.amazonaws.com/flo-ecr-repo:latest) and 
Use These Credentials in the Login Prompt
Username: AWS
Password: (Paste the token from step 1)

Then, click Sign In.
