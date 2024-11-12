# DEPLOYMENT OF WEB APPLICATION TO AMAZON EKS THROUGH JENKINS CICD AND TERRAFROM AS IaC

Original owner @thanosdrome

![Architecture](assets/architecture.png)

***Welcome to this step-by-step guide on deploying an EKS cluster and application with complete CI/CD!***

Are you looking to streamline your application delivery process and automate your infrastructure deployment? Look no further! In this project, I'll take you through the process of setting up an EKS cluster, deploying an application, and creating a CI/CD pipeline using Jenkins and Terraform.

We'll start with the basics and gradually dive deeper into the technical details, so you'll find this guide helpful whether you're a beginner or an experienced DevOps engineer. By the end of this article, you'll have a fully functional EKS cluster and a simple containerized application up and running, with a CI/CD pipeline that automates the entire process from code to production.

## Let's get started and explore the world of EKS, CI/CD, and automation

## **What we'll build**

We are going to build and deploy a lot of things. Here is the outline for our project:

**I. Setting up Jenkins Server with Terraform**

* Creating an EC2 instance with Terraform.

* Installing necessary tools: `Java, Jenkins, AWS CLI, Terraform CLI, Docker, Sonar, Helm, Trivy, Kubectl`.

* Configuring Jenkins server.

**II. Creating EKS Cluster with Terraform**

* Writing Terraform configuration files for `EKS` cluster creation in a private subnet.

* Deploying EKS cluster using Terraform.

**III. Deploying NGinx Application with Kubernetes**

* Writing Kubernetes manifest files `(YAML)` for the NGinx application.

* Deploying NGinx application to `EKS` cluster.

**IV. Automating Deployment with Jenkins CI/CD**

* Creating `Jenkins` pipeline for automating EKS cluster creation and Nginx application deployment.

* Integrating Terraform and Kubernetes with the Jenkins pipeline.

* Configuring continuous integration and deployment (CI/CD).

## **What we'll need**

To embark on our CI/CD adventure, we'll need a trusty toolkit:

**Terraform** — To create configuration files for the EC2 instance which will be used as a Jenkins server and EKS Cluster in a VPC.

**Shell Script —** To install command line tools in the EC2 instance.

**Jenkins file —** To create a pipeline in the Jenkins Server.

**Kubernetes Manifest files** — To create a simple NGINX application in the EKS cluster.

## **Prerequisites**

Before creating and working with the project, let's set up some dev tools first -

1. It's better to have an IDE to develop your project. I am using `Visual Studio Code` for the same. You can install it from the following link based on the operating system— [https://code.visualstudio.com/download](https://code.visualstudio.com/download)

2. Install the CLI tools — [**AWS-CLI**](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), and [**Terraform-CLI**](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

3. Make sure you have an AWS Free Tier Account. And then create a user in IAM Console and finally create an `Access Key ID` and `Secret Access Key` in AWS Console for that user. You need to download these keys and then export those credentials in your terminal as follows —

```yaml
export AWS_ACCESS_KEY_ID=<Copy this from the credentials file downloaded>
export AWS_SECRET_ACCESS_KEY=<Copy this from the credentials file downloaded>
```

## **Stage 1: Configure and Build Jenkins Server**

The first thing we have to do is to create a new key pair for login into the EC2 instance and create an S3 bucket for storing terraform state files. This is the only manual step we are doing.

So, in the AWS management console go to "`EC2`" and select "`Key pairs`" in the listed overview of your resources, and then select "Create key pair" at the top right corner. You need to download these key pairs so that you can use them later for logging into the `EC2 instance`.

![None](/assets/keypair.JPG)

Create Key pairs for the EC2 instance

Next, let's create a `S3` bucket to store the terraform remote states. You can go ahead and do this manually. I have an existing s3 bucket used as remote backend in a CICD pipeline created using AWS Developer Tools.[AWS-CICD](https://github.com/chimezdev/palm-cicd-repo.git). So we will simply import that existing terraform configuration as follow.
In the ***backend.tf***
```yaml
data "terraform_remote_state" "aws-cicd" {
    backend = "s3"

    config = {
      bucket = "palm-terraform-remote-state"
      key = "palm-cicd/terraform.tfstate"
      region = "eu-west-1"
    }
}
```
You will see how we will make use of any resources from the state file when needed.


![None](./assets/state_bucket.JPG)

Create an S3 bucket to store terraform remote state

Now, let's start writing terraform configuration for our `EC2 instance` which will be used as a `Jenkins` server. So, we will create the instance first and then we will install the necessary tools like `jenkins` etc via a build script.

Here are the Terraform configuration files -
The rest of the ***backend.tf*** file

> *backend.tf*
```yaml
provider "aws" {
    region = var.aws_region  
}

terraform {
    required_providers {
    aws = {
        source = "hashcorp/aws"
        version = ">=5.25.0"
    }
  }
    backend "s3" {
        bucket = "palm-terraform-remote-state"
        key = "eks-jenkins/terraform.tfstate"
        dynamodb_table = "palm-terraform-locks"
        kms_key_id     = "arn:aws:kms:eu-west-1:038462750799:key/fbfc32d6-539b-4c81-bf58-d5db169b5322"
        region = "eu-west-1"
    }
}
```
Notice the ***kms key*** and ***dynamodb table***. They were created manually. The key is for encrypting the state file while is for terraform state LOCKING.

See the rest of the configuration files
> *data.tf*
see ***data.tf*** file

> *main.tf*
See the file ***jenkins-server/tf-aws-ec2/main.tf***
We'll be using publicly available modules for creating different services instead of resources
[None]https://registry.terraform.io/browse/modules?provider=aws

> *install\_build\_tools.sh*
- see the file **scripts/install_build_tools.sh**

Points to note before running `terraform apply`.

* Use the correct key pair name in the EC2 instance module `(main.tf)` and it must exist before creating the instance.

* Use the correct bucket name in the configuration for the `remote` backend `S3` in the`backend.tf`

* You need to use `user_data = file("scripts/install_build_tools.sh")` depending on your root module in the EC2 module to specify the script to be executed after EC2 instance creation.

* Make sure the script ***install_build_tools.sh*** is executable. Run `chmod +x install_build_tools.sh`

Let's run `terraform apply` and create this. Please make sure to run `terraform init` if you are doing this for the first time. Also, double-check your current working directory where you are running the `terraform cli` commands.

terraform apply

![None](./assets/terra_apply.JPG)

terraform apply

Give it some time before you go to the AWS `EC2 console` and check the instance status. Even though the instance is running, it may still be installing the tools.

![None](./assets/jenkins_server.JPG)

Jenkins Build Server Created

Now, let's log in to the Jenkins server and verify if all the tools have been installed correctly or not.

So, let's select the `EC2 instance` and click on connect. You can simply connect using the **EC2 Instance connect**

![None](./assets/ssh-connect.JPG)

successfully connected to the EC2 instance

We can now verify the versions of all the tools installed. Let's copy and paste the below commands.

```yaml
jenkins --version
docker --version
docker ps
terraform --version
kubectl version
aws --version
trivy --version
helm version
```

Here is the output.

![None](./assets/connect.JPG)

Tools version installed in the Jenkins Server (EC2 instance)

Let's configure the Jenkins in the `EC2 instance`. So, copy the EC2 instance's `public IP address` and paste it into the browser by adding the `8080` port which we have provided in the security group settings for Jenkins.

![None](https://miro.medium.com/v2/resize:fit:700/1*Bt6OahGi8b2IAFlGwCVFWg.png)

Now, copy the administrator password from the below path and paste and continue.

![None](./assets/jenkins_pass.JPG)

Copy the Admin password

You will get the below screen. Click on `Install Suggested Plugins`**.**

![None](https://miro.medium.com/v2/resize:fit:700/1*vnCFQYNgDPJJLglYwnLzNg.png)

Install Suggested Plugin

![None](https://miro.medium.com/v2/resize:fit:700/1*RfhmnX1hkFU9xbAPujUFDQ.png)

Plugin Installing

Once all the plugins are installed, you will be presented with the following screen. Here, you can continue as an admin (click on `skip and continue as admin`) **or** create a new user and password then click `Save and Continue`.

![None](https://miro.medium.com/v2/resize:fit:700/1*Z-7qzQUX6bnhmDNDR6hiiQ.png)

Create First Admin User
Click on `Save and Finish` and then on the next page `Start using Jenkins.`

![None](https://miro.medium.com/v2/resize:fit:700/1*Uo3DOsOqggAgKN0zMy-88Q.png)

Finally, you will get the below **Jenkins Dashboard**. At this point, we are ready with our Jenkins server. We'll configure the pipeline later.

![None](https://miro.medium.com/v2/resize:fit:700/1*Zz-Y3-aeoU68uJloXESBDA.png)

Jenkins Dashboard

## **Stage 2: Create Terraform configuration files for creating the EKS Cluster**

### **Task 1: Create Terraform configuration files**

Moving on, let's start writing terraform configurations for the `EKS` `cluster` in a `private` `subnet`.

We'll use the same bucket but a different key/folder for the`terraform remote state` file.

> *backend.tf*
See **tf-aws-eks**

### **Task 2: Validate the terraform configuration files**

Although we are going to create the AWS EKS infrastructure via the Jenkins pipeline, we first need to validate the configuration files that we have created in the previous step.

So, let's move to `tf-aws-eks` directory, initialize our working directory, and then run `terraform plan` and `validate`.

```yaml
terraform init
```

![None](https://miro.medium.com/v2/resize:fit:700/1*a_O63x-NhkNGxAZN6r2ZfA.png)


```yaml
terraform validate
```

![None](./assets/validate.JPG)

terraform validate

```yaml
terraform plan 
```

![None](./assets/plan.JPG)

terraform plan

Configuration files are all validated and `terraform plan` is running fine which means we are ready to run the `terraform apply` in the Jenkins pipeline.

## **Stage 3: Configure Jenkins pipeline**

Let's proceed to the Jenkins URL again and start configuring the pipeline.

Click on "**Create a Job**", type "**eks-cicd-pipeline**" and select **pipeline** then **OK**.

![None](https://miro.medium.com/v2/resize:fit:700/1*Oda0yhe97pFGS0KK3fSx3A.png)

Create a Jon -&gt; Pipeline

On the next screen, provide "**description**", move to the bottom, and click on "**Save**".

![None](https://miro.medium.com/v2/resize:fit:700/1*hISQdOBWcbmmQOil-9fUCg.png)

Pipeline created

Since we are going to run `terraform` commands in the pipeline, which will talk to our `AWS` environment, we need to provide/store `AccessKey` and `SecretAccessKey` somewhere in the vault so that the pipeline can use that.

Jenkins provides a facility to store `secret` `credentials` in the vault.

So, head on to the **Dashboard -&gt; Manage Jenkins -&gt; Credentials -&gt; System -&gt; Global credentials (unrestricted)**

![None](https://miro.medium.com/v2/resize:fit:700/1*CDjcLYFWD5-oHn1FDQJMkg.png)

Create Secret text for AWS\_ACESS\_KEY\_ID

![None](https://miro.medium.com/v2/resize:fit:700/1*xsRdOW5ogwepGdQnDXthBw.png)

Create Secret text for AWS\_SECRET\_ACCESS\_KEY

![None](https://miro.medium.com/v2/resize:fit:700/1*vaqriyuj6Xf_nX5ZWK0Ngw.png)

Access Keys created

You need to install one plugin to see the stage view in the pipeline.

Go to **Dashboard -&gt; Manage Jenkins -&gt; Plugins -&gt; Available plugins**

and select **Pipeline: Stage View** and click on **Install**.

![None](https://miro.medium.com/v2/resize:fit:700/1*TDLR35Lkpiw6spDRZUh4Vg.png)

Install Plugin — Pipeline: Stage View

Finally, let's start configuring our pipeline. Go to your `Dashboard` and click on `Configure` →

![None](https://miro.medium.com/v2/resize:fit:700/1*FPtHRKzBkUsX4GfsgUNJ9A.png)
Configure Pipeline

Now move to the bottom and start typing pipeline script using `stages` and `tasks`. You can also take help from `Pipeline Syntax` —

![None](https://miro.medium.com/v2/resize:fit:700/1*5ACTAU6ObbGjgPzSwhYTsg.png)

However, I have included the pipeline code in Jenkinsfile as below. Let's observe a few things here —

* We need to provide AWS credential variables that we added already in Jenkins.

* We need to provide `Github` location for the code with the current branch. Since this repository is public, we don't have to specify the `GitHub` `token` or `credentials` to access git.

> *Jenkinsfile*
See **Jenkinsfile** in this repository to see the complete pipeline script
We have also added parameters and condition.

![None](https://miro.medium.com/v2/resize:fit:700/1*zMb3pq3XWjXgezvAqRZLgQ.png)
Adding parameter

Copy the code into pipeline editor, Save and run the pipeline by clicking on `Build with Parameters` —

![None](https://miro.medium.com/v2/resize:fit:700/1*QC9TpFvH4iiN-VjV1g7BDg.png)

Build with Parameters

![None](https://miro.medium.com/v2/resize:fit:700/1*lZMJ4aqDvjoUUe3FPvzCOQ.png)

Pipeline running

We need to wait at least 15 mins for the pipeline to be finished.

![None](https://miro.medium.com/v2/resize:fit:700/1*h7_BGs_-V4Nl6XE-77KkOw.png)

Pipeline Success

Let's verify the EKS cluster in the AWS Console.

![None](https://miro.medium.com/v2/resize:fit:700/1*2CSkbFUD-BBDPhgFexNgKQ.png)

EKS Cluster — Created


Check the logs by clicking on `#4` and then `console output`. We can see that the pipeline is successful and `terraform plan` got executed by showing `58 resources to add.`

![None](https://miro.medium.com/v2/resize:fit:700/1*CCB_3dDoah1MoGiu0nVlIA.png)

Console Output

## **Stage 4: Adding Kubernetes manifest files for the Nginx Application**

We have come to the last stage where we are going to **deploy** a simple Kubernetes application to the cluster. Ideally, in a production scenario, there will be different pipelines for the infrastructure (EKS Cluster) and the application, and again if the application is 2-tier or 3-tier, there will be separate pipelines for each tier to maintain microservices architecture.

We are going to create a simple Nginx application that we are going to access via the `LoadBalancer` endpoint. Hence, let's create 2 manifest files — `deployment.yaml` and `service.yaml` put in the directory ***/manifest***

> *deployment.yaml*

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

> *service.yaml*

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
```

Also add another stage in the Jenkins pipeline to apply manifest files using `kubectl` utility that we installed in the EC2 instance (Jenkins Server) initially.

> *Jenkinsfile*

```yaml
stage('Deploying Nginx Application') {
    when {
        expression { params.action == 'apply' }  // Run only if 'apply' is selected
    }
    steps {
        script{
            dir('manifest') {
                sh 'aws eks update-kubeconfig --name palm-eks-cluster'
                sh '''
                if ! kubectl get namespace eks-nginx-app > /dev/null 2>&1; then
                    kubectl create namespace eks-nginx-app
                else
                    echo "Namespace eks-nginx-app already exists."
                fi
                '''
                sh 'kubectl apply -f deployment.yaml -n eks-nginx-app'
                sh 'kubectl apply -f service.yaml -n eks-nginx-app'
            }
        }
    }
}
```
If you have included the above in the initial run, then just proceed to the next step

Create an access entry.

![None](https://miro.medium.com/v2/resize:fit:700/1*Nvb-_eo083g0ofmJHE5hWg.png)

EKS Cluster — Create access entry

Now, select the admin/root user or assumed role ARN.

![None](https://miro.medium.com/v2/resize:fit:700/1*AbXMy9LEOK-fV3yyqyD5Eg.png)

EKS Cluster — Select IAM principal ARN

Next, select the policy/permission. Please select `AmazonEKSClusterAdminPolicy` then click `Next` and `Create`.

![None](https://miro.medium.com/v2/resize:fit:700/1*E3JyOnu5S1KeZrwv93S7dA.png)

Select permission — AmazonEKSClusterAdminPolicy

![None](https://miro.medium.com/v2/resize:fit:700/1*HYanUZFYT49qUj74g5S9aA.png)

Access Entry created

Let's rerun the pipeline and check the status. This time our pipeline will be successful.

![None](https://miro.medium.com/v2/resize:fit:700/1*sidSsXZA5Dimkt3Y7h3Q7w.png)

eks-cicd-pipeline successful

Let's validate the resources in the AWS EKS console -

![None](https://miro.medium.com/v2/resize:fit:700/1*GeOW0hRgPV4_UzfzBdx8ug.png)

nginx deployment is running

![None](https://miro.medium.com/v2/resize:fit:700/1*Nme3g6oi-BXvnPzIoWyXlg.png)

nginx service is running

Now copy the load balancer URL and hit it in the browser. We'll be able to access the application.

![None](https://miro.medium.com/v2/resize:fit:700/1*77SNLMebV0ZKie_B5kbDjA.png)

Nginx application is running in the browser

## **Stage 5: Teardown resources**

Finally, we have come to the end of this guide. We have to destroy our resources to save on the cost. Deleting applications and destroying `EKS` cluster can be done via the Jenkins pipeline by just selecting the `action` `destroy` while doing `Build with Parameters`.

![None](https://miro.medium.com/v2/resize:fit:700/1*tfHYn5CDEMHBtZu0GAKt5w.png)

Action — destroy

![None](https://miro.medium.com/v2/resize:fit:700/1*4g2-XjFXG64-3DlyahHh7w.png)

Destroy Pipeline

EKS Cluster — Deleted

Let's also delete the `Jenkins` `Server` by running `terraform destroy` via local CLI.

![None](https://miro.medium.com/v2/resize:fit:700/1*PuiabpzGbA3LVqBAIk_f_g.png)

terraform destroy

![None](https://miro.medium.com/v2/resize:fit:700/1*o9-geEAOtcv0YzfZ_4KJKg.png)

terraform destroy completed

Please recheck your AWS Console manually to see if there is any resource remaining for example — EC2 key pair and S3 bucket and delete them manually.

## **Conclusion**

We have successfully implemented a robust and automated infrastructure provisioning and deployment pipeline using `Terraform`, `EKS`, and `Jenkins`. We have not only designed and implemented a scalable and efficient CI/CD pipeline but also deployed a simple **Nginx** application in the EKS cluster. However, this is not the end but the beginning of creating complex production CI/CD applications.
