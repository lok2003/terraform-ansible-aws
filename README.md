# Terraform + Ansible AWS Lab

This project demonstrates how to provision AWS EC2 instances using **Terraform** and configure web servers using **Ansible**.

## Architecture

* **Terraform:** Creates AWS infrastructure, including EC2 instances and supporting resources.
* **Ansible:** Configures Ubuntu and Amazon Linux servers.
* **Nginx:** Installs and runs the web server.
* **Ansible Roles:** Organize tasks, variables, and handlers into reusable components.
* **AWS Systems Manager (SSM):** Provides access to EC2 instances without requiring a direct SSH connection from your local machine.

## Repository Structure

```text
terraform-ansible-aws/
├── README.md
├── .gitignore
├── [terraform](terraform/)
│   ├── main.tf
│   ├── variable.tf
│   ├── output.tf
│   ├── control_node/
│   ├── managed_node/
│   ├── iam/
│   ├── sg/
│   └── vpc/
└── ansible/
    ├── hosts
    ├── nginx.yaml
    └── roles/
        └── nginx/
            ├── defaults/
            │   └── main.yaml
            ├── files/
            ├── handlers/
            │   └── main.yaml
            ├── tasks/
            │   └── main.yaml
            └── templates/
```

## 1. [Terraform](terraform/) 
Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the planned changes:

```bash
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

Review the instance IP addresses and other configured outputs:

```bash
terraform output
```

**Note:** Run Terraform commands from the directory containing the relevant root configuration. If your Terraform configuration uses separate root modules, initialize and apply each required module from its own directory.

## 2. AWS SSM — Access EC2 Instances

Use AWS Systems Manager Session Manager to connect to instances that have the required IAM permissions, SSM Agent, and network connectivity.

Start a session using the EC2 instance ID:

```bash
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx
```

Replace the example instance ID with your actual EC2 instance ID.

For an Ubuntu managed node, prepare the SSH authorized keys file if SSH access from the Ansible control node is required.

```bash
sudo mkdir -p /home/ubuntu/.ssh
sudo touch /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
```

Add the **Ansible control node's public SSH key** to:

```text
/home/ubuntu/.ssh/authorized_keys
```

Verify the permissions and file:

```bash
sudo ls -la /home/ubuntu/.ssh
sudo cat /home/ubuntu/.ssh/authorized_keys
```

For Amazon Linux, use the appropriate default login user, commonly `ec2-user`, and its home directory.

**Security:** Keep private keys out of Git. Use SSM and SSH permissions according to your security requirements.

## 3. [Ansible](ansible/) — Configure Managed Servers

Navigate to the Ansible directory on your control node:

```bash
cd ~/ansible
```

### [Inventory](ansible/inventory/hosts.example)

The inventory file identifies the managed servers and their SSH connection details.



Update the inventory with the current private IP addresses of your Terraform-created EC2 instances.

Check connectivity:

```bash
ansible -i hosts all -m ping
```

Check hostnames:

```bash
ansible -i hosts all -m command -a "hostname"
```

## 4.[Ansible Nginx Role](ansible/roles/nginx/)

The Nginx role installs Nginx and `unzip`, starts and enables the service, downloads and deploys a website template, and removes temporary files.

### Supported operating systems

The role uses Ansible facts to select the correct package manager and web root:

* **Ubuntu:** Uses `apt` and `/var/www/html/`
* **Amazon Linux:** Uses `dnf` and `/usr/share/nginx/html/`

### Run the playbook

```bash
ansible-playbook -i hosts nginx.yaml
```

### Run specific tasks using tags

Install Nginx:

```bash
ansible-playbook -i hosts nginx.yaml --tags nginx_install
```

Deploy the website:

```bash
ansible-playbook -i hosts nginx.yaml --tags website_deploy
```

Clean up temporary download and extraction files:

```bash
ansible-playbook -i hosts nginx.yaml --tags cleanup
```

List available tags:

```bash
ansible-playbook -i hosts nginx.yaml --list-tags
```

**Important:** The website deployment tag must include its download and extraction prerequisites so the template files are available when deployment runs.

## 5. Verify the Website

Check the Nginx service:

```bash
ansible -i hosts web -b -m command -a "systemctl is-active nginx"
```

Verify the deployed HTML title:

```bash
ansible -i hosts web -b -m shell -a 'curl -s http://localhost | grep -m1 "<title>"'
```

You should see the expected website title from the deployed template on each web server.

## Workflow

1. Provision the AWS infrastructure using Terraform.
2. Retrieve the EC2 instance details.
3. Configure the Ansible inventory with the correct private IP addresses.
4. Verify Ansible connectivity.
5. Run the Nginx role.
6. Verify Nginx and the deployed website.

## Cleanup

When you no longer need the lab, review the resources before destroying them:

```bash
terraform plan -destroy
terraform destroy
```

Run these commands from the appropriate Terraform root directory. Destroying resources may remove running instances and associated infrastructure.
