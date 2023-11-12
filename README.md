# PG-DevOps-Project---Hotel-Side-Hospital

 

Introduction: 

 

Hotel-Side Hospital, a globally renowned hospital chain headquartered in Australia, is aiming to streamline its operation by setting up an infrastructure within the hotel premises. However, in order to maintain seamless functioning and scalability, they require fully managed virtual machines (VMs) on the Amazon Web Services (AWS) platform. The organization seeks an automated provisioned infrastructure solution that can enable them to effortlessly create new Amazon Elastic Kubernetes Service (EKS) clusters, whenever required, and promptly delete them when they are no longer needed. This will optimize resource allocation and enhance operational efficiency. 

 

Prerequisites: 

 

Skills used in the project and their usage in the industry are as below:  

• Terraform: It is an infrastructure-as-code tool that allows you to define and provision resources in a cloud environment. In this project, Terraform is used to define the infrastructure components and manage their lifecycle.  

• EKS: It is a managed Kubernetes service provided by AWS. In this project, an EKS cluster is created using Terraform, which provides a scalable and highly available environment for running containerized workloads.  

• EC2: EC2 instances are virtual servers provided by AWS. In this project, EC2 instances are provisioned using Terraform, which allows you to specify the desired instance types, operating systems, and other configurations. 

 

 

 

Repository Setup: 

Steps to initialize the Git repository. 

 

mkdir HSH		 

git init 

git remote add origin https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git 

 

git pull origin main 

 

 

Terraform Configuration: 

 

 

 

 

AWS CLI 

 

 

Terraform files: 

provider.tf 

 

 

provider "aws" { 

   

  region = "us-east-1" 

  

  

} 

 

 

2 -  

 

 

resource "aws_vpc" "hsh_vpc" { 

   

  cidr_block = "10.0.0.0/16" 

  

  enable_dns_support   = true 

  

  enable_dns_hostnames = true 

  

  

  

  tags = { 

  

    Name = "hsh_vpc" 

  

  } 

  

} 

 

 

3 - subnets.tf 

 

 

 

 

esource "aws_subnet" "hsh_public_subnet" { 

   

  vpc_id            = aws_vpc.hsh_vpc.id 

  

  cidr_block        = "10.0.1.0/24" 

  

  map_public_ip_on_launch = true 

  

  

  

  tags = { 

  

    Name = "hsh_public_subnet" 

  

  } 

  

} 

 

4 – routetable.tf 

 

 

resource "aws_route_table" "hsh_route_table" { 

   

  vpc_id = aws_vpc.hsh_vpc.id 

  

  

  

  route { 

  

    cidr_block = "0.0.0.0/0" 

  

    gateway_id = aws_internet_gateway.hsh_igw.id 

  

  } 

  

  

  

  tags = { 

  

    Name = "hsh_route_table" 

  

  } 

  

} 

 

5 - Route_table_association_with_public_subnets.tf 

 

 

 

resource "aws_route_table_association" "hsh_rta_public_subnet" { 

   

  subnet_id      = aws_subnet.hsh_public_subnet.id 

  

  route_table_id = aws_route_table.hsh_route_table.id 

  

} 

 

6 - internetgateway.tf 

 

 

 

resource "aws_internet_gateway" "hsh_igw" { 

   

  vpc_id = aws_vpc.hsh_vpc.id 

  

  

  

  tags = { 

  

    Name = "hsh_igw" 

  

  } 

  

} 

 

 

7 -  autoscaling.tf 

 

 

 

resource "aws_launch_configuration" "hsh_lc" { 

  

  name_prefix     = "hsh-lc-" 

  

  image_id        = "ami-0fc5d935ebf8bc3bc" 

  

  instance_type   = "t2.micro" 

  

  security_groups = [aws_security_group.hsh_sg.id] 

  

  

  

  lifecycle { 

  

    create_before_destroy = true 

  

  } 

  

} 

  

  

  

resource "aws_autoscaling_group" "hsh_asg" { 

  

  launch_configuration = aws_launch_configuration.hsh_lc.id 

  

  vpc_zone_identifier  = [aws_subnet.hsh_public_subnet.id] 

  

  max_size             = 3 

  

  min_size             = 1 

  

  desired_capacity     = 1 

  

  

  

  tag { 

  

    key                 = "Name" 

  

    value               = "hsh-instance" 

  

    propagate_at_launch = true 

  

  } 

  

} 

  

  

  

resource "aws_autoscaling_policy" "hsh_target_tracking" { 

  

  name                   = "hsh-cpu-target-tracking" 

  

  autoscaling_group_name = aws_autoscaling_group.hsh_asg.name 

  

  policy_type            = "TargetTrackingScaling" 

  

  estimated_instance_warmup = 200 

  

  

  

  target_tracking_configuration { 

  

    predefined_metric_specification { 

  

      predefined_metric_type = "ASGAverageCPUUtilization" 

  

    } 

  

    target_value = 30.0 

  

  } 

  

} 

 

 

 

git add .  

git commit -m "Initial commit or a description of changes"  

git push -u origin main 

 

 

Jenkins congiuration: 

 

Add terraform plugin: myterraform 

 

 

Create a credentials for AWS IAM 

 

 

 

Create a new pipeline that checkout the github repo and apply the terraform scripts: 

 

pipeline { 

    agent any 

    tools { 

       terraform 'myterraform' 

    } 

       

    stages { 

        stage('Checkout') { 

            steps { 

                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git']]]) 

            } 

        } 

        stage('Terraform init') { 

            steps { 

                sh 'terraform init' 

            } 

        } 

        stage('Terraform apply') { 

            steps { 

                withCredentials([[ 

                    $class: 'AmazonWebServicesCredentialsBinding',  

                    credentialsId: 'AWS' 

                ]]) { 

                    sh ''' 

                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID 

                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY 

                        export AWS_DEFAULT_REGION='us-east-1' 

                        terraform apply -auto-approve 

                    ''' 

                } 

            } 

        } 

    } 

}            

 

Build the terraform pipeline: 

 

 

 

 

 

Check the instance on AWS 

 

 

Check the Autoscaling group: 

 

 

CPU usage before installing stress utility: 

 

 

 

Installing stress utility on the instance (I used Ubuntu instance hence the difference in command) 

 

sudo apt update 

sudo apt install stress -y 

sudo stress --cpu 8 --verbose --timeout 3000s 

 

 

 

 

Check the status of the instances afterr the triger is applied (cpu > 20%) 

 

 

 

 

 

 

 

 

 

 

 

Now stop the stress utility 

 

 

 

 

 

After some time, the group returnes to the desired state of 1 instance 

 

 

 

 

 

 

 

 

 

 

 

 

The END 

Thank YOU Plesae check the GitHub repo for better readabilty 

https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git  

 

Introduction: 

 

Hotel-Side Hospital, a globally renowned hospital chain headquartered in Australia, is aiming to streamline its operation by setting up an infrastructure within the hotel premises. However, in order to maintain seamless functioning and scalability, they require fully managed virtual machines (VMs) on the Amazon Web Services (AWS) platform. The organization seeks an automated provisioned infrastructure solution that can enable them to effortlessly create new Amazon Elastic Kubernetes Service (EKS) clusters, whenever required, and promptly delete them when they are no longer needed. This will optimize resource allocation and enhance operational efficiency. 

 

Prerequisites: 

 

Skills used in the project and their usage in the industry are as below:  

• Terraform: It is an infrastructure-as-code tool that allows you to define and provision resources in a cloud environment. In this project, Terraform is used to define the infrastructure components and manage their lifecycle.  

• EKS: It is a managed Kubernetes service provided by AWS. In this project, an EKS cluster is created using Terraform, which provides a scalable and highly available environment for running containerized workloads.  

• EC2: EC2 instances are virtual servers provided by AWS. In this project, EC2 instances are provisioned using Terraform, which allows you to specify the desired instance types, operating systems, and other configurations. 

 

 

 

Repository Setup: 

Steps to initialize the Git repository. 

 

mkdir HSH		 

git init 

git remote add origin https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git 

 

git pull origin main 

 

 

Terraform Configuration: 

 

 

 

 

AWS CLI 

 

 

Terraform files: 

provider.tf 

 

 

provider "aws" { 

   

  region = "us-east-1" 

  

  

} 

 

 

2 -  

 

 

resource "aws_vpc" "hsh_vpc" { 

   

  cidr_block = "10.0.0.0/16" 

  

  enable_dns_support   = true 

  

  enable_dns_hostnames = true 

  

  

  

  tags = { 

  

    Name = "hsh_vpc" 

  

  } 

  

} 

 

 

3 - subnets.tf 

 

 

 

 

esource "aws_subnet" "hsh_public_subnet" { 

   

  vpc_id            = aws_vpc.hsh_vpc.id 

  

  cidr_block        = "10.0.1.0/24" 

  

  map_public_ip_on_launch = true 

  

  

  

  tags = { 

  

    Name = "hsh_public_subnet" 

  

  } 

  

} 

 

4 – routetable.tf 

 

 

resource "aws_route_table" "hsh_route_table" { 

   

  vpc_id = aws_vpc.hsh_vpc.id 

  

  

  

  route { 

  

    cidr_block = "0.0.0.0/0" 

  

    gateway_id = aws_internet_gateway.hsh_igw.id 

  

  } 

  

  

  

  tags = { 

  

    Name = "hsh_route_table" 

  

  } 

  

} 

 

5 - Route_table_association_with_public_subnets.tf 

 

 

 

resource "aws_route_table_association" "hsh_rta_public_subnet" { 

   

  subnet_id      = aws_subnet.hsh_public_subnet.id 

  

  route_table_id = aws_route_table.hsh_route_table.id 

  

} 

 

6 - internetgateway.tf 

 

 

 

resource "aws_internet_gateway" "hsh_igw" { 

   

  vpc_id = aws_vpc.hsh_vpc.id 

  

  

  

  tags = { 

  

    Name = "hsh_igw" 

  

  } 

  

} 

 

 

7 -  autoscaling.tf 

 

 

 

resource "aws_launch_configuration" "hsh_lc" { 

  

  name_prefix     = "hsh-lc-" 

  

  image_id        = "ami-0fc5d935ebf8bc3bc" 

  

  instance_type   = "t2.micro" 

  

  security_groups = [aws_security_group.hsh_sg.id] 

  

  

  

  lifecycle { 

  

    create_before_destroy = true 

  

  } 

  

} 

  

  

  

resource "aws_autoscaling_group" "hsh_asg" { 

  

  launch_configuration = aws_launch_configuration.hsh_lc.id 

  

  vpc_zone_identifier  = [aws_subnet.hsh_public_subnet.id] 

  

  max_size             = 3 

  

  min_size             = 1 

  

  desired_capacity     = 1 

  

  

  

  tag { 

  

    key                 = "Name" 

  

    value               = "hsh-instance" 

  

    propagate_at_launch = true 

  

  } 

  

} 

  

  

  

resource "aws_autoscaling_policy" "hsh_target_tracking" { 

  

  name                   = "hsh-cpu-target-tracking" 

  

  autoscaling_group_name = aws_autoscaling_group.hsh_asg.name 

  

  policy_type            = "TargetTrackingScaling" 

  

  estimated_instance_warmup = 200 

  

  

  

  target_tracking_configuration { 

  

    predefined_metric_specification { 

  

      predefined_metric_type = "ASGAverageCPUUtilization" 

  

    } 

  

    target_value = 30.0 

  

  } 

  

} 

 

 

 

git add .  

git commit -m "Initial commit or a description of changes"  

git push -u origin main 

 

 

Jenkins congiuration: 

 

Add terraform plugin: myterraform 

 

 

Create a credentials for AWS IAM 

 

 

 

Create a new pipeline that checkout the github repo and apply the terraform scripts: 

 

pipeline { 

    agent any 

    tools { 

       terraform 'myterraform' 

    } 

       

    stages { 

        stage('Checkout') { 

            steps { 

                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git']]]) 

            } 

        } 

        stage('Terraform init') { 

            steps { 

                sh 'terraform init' 

            } 

        } 

        stage('Terraform apply') { 

            steps { 

                withCredentials([[ 

                    $class: 'AmazonWebServicesCredentialsBinding',  

                    credentialsId: 'AWS' 

                ]]) { 

                    sh ''' 

                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID 

                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY 

                        export AWS_DEFAULT_REGION='us-east-1' 

                        terraform apply -auto-approve 

                    ''' 

                } 

            } 

        } 

    } 

}            

 

Build the terraform pipeline: 

 

 

 

 

 

Check the instance on AWS 

 

 

Check the Autoscaling group: 

 

 

CPU usage before installing stress utility: 

 

 

 

Installing stress utility on the instance (I used Ubuntu instance hence the difference in command) 

 

sudo apt update 

sudo apt install stress -y 

sudo stress --cpu 8 --verbose --timeout 3000s 

 

 

 

 

Check the status of the instances afterr the triger is applied (cpu > 20%) 

 

 

 

 

 

 

 

 

 

 

 

Now stop the stress utility 

 

 

 

 

 

After some time, the group returnes to the desired state of 1 instance 

 

 

 

 

 

 

 

 

 

 

 

 

The END 

Thank YOU 
