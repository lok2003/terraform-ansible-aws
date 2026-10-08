# Terraform + Ansible AWS Lab

A hands-on DevOps project that uses **Terraform to provision AWS infrastructure** and **Ansible to configure and manage EC2 servers**.

The project demonstrates a real-world workflow:

```text
Terraform
   │
   ▼
AWS Infrastructure
   │
   ├── VPC
   ├── Subnets
   ├── Security Groups
   ├── IAM
   └── Control Node (EC2 Instances)
          │
          ▼
    Ansible Managed Node
          │
          ├── web01
          ├── web02
          └── app01
```

---

# Project Goals

* Provision AWS infrastructure using Terraform
* Create an Ansible control node
* Create private and public EC2 servers
* Use AWS Systems Manager for private instances
* Configure SSH between the Ansible control node and managed servers
* Manage servers using Ansible inventory
* Install and configure Nginx using Ansible playbooks
* Build a foundation for Terraform + Ansible + CI/CD

---

# Technologies

* AWS
* Terraform
* Ansible
* EC2
* VPC
* IAM
* Security Groups
* AWS Systems Manager
* SSH
* Nginx
* Git & GitHub

---

# Architecture

```text
                         AWS
                          │
                    ┌─────┴─────┐
                    │    VPC    │
                    │ 10.0.0.0/16
                    └─────┬─────┘
                          │
              ┌───────────┴───────────┐
              │                       │
        Public Subnet            Private Subnet
              │                       │
              │                       │
        ┌─────┴─────┐                 |
        │           │                 │         
      web01       web02             app01
        │           │               │
        └─────┬─────┘               │
              │                     │ 
              │                     │ 
              └────────┬────────────┘
                       │
                Ansible Control
                     Node
```

### Server Roles

| Server       | Role                 | Network |
| ------------ | -------------------- | ------- |
| Control Node | Ansible Control Node | Public  |
| web01        | Web Server           | Public  |
| web02        | Web Server           | Public  |
| app01        | Application Server   | Private |

---

# Repository Structure

```text
terraform-ansible-aws-lab/
│
├── README.md
├── .gitignore
│
├── terraform/
│   ├── main.tf
│   ├── variable.tf
│   ├── output.tf
│   │
│   ├── control_node/
│   ├── managed_node/
│   ├── iam/
│   ├── sg/
│   └── vpc/
│
└── ansible/
    |
    │
    ├── inventory/
    │   └── hosts.example
    │
    └── playbooks/
        └── nginx.yaml
```

---

# Prerequisites

Install:

* AWS CLI
* Terraform
* Ansible
* Git
* AWS Session Manager Plugin

Configure AWS CLI:

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

# Part 1 — Terraform

Go to the Terraform directory:

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

Format Terraform files:

```bash
terraform fmt -recursive
```

Review the infrastructure:

```bash
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

Confirm:

```text
yes
```

---

# Terraform Outputs

After deployment:

```bash
terraform output
```

Useful outputs include:

```bash
terraform output server_private_ips
```

```bash
terraform output server_public_ips
```

```bash
terraform output server_instance_ids
```

---

# Part 2 — AWS Systems Manager

AWS Systems Manager allows access to EC2 instances without requiring a public IP.

Check managed instances:

```bash
aws ssm describe-instance-information
```

Start a session using an instance ID:

```bash
aws ssm start-session --target <INSTANCE_ID>
```

Example:

```bash
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx
```

---

# Find Instance ID Using Private IP

If you know the private IP but don't know the instance ID:

```bash
aws ec2 describe-instances \
  --filters "Name=private-ip-address,Values=<PRIVATE_IP>" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text
```

Example:

```bash
aws ec2 describe-instances \
  --filters "Name=private-ip-address,Values=10.0.3.225" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text
```

Then:

```bash
aws ssm start-session --target <INSTANCE_ID>
```

---

# Install Session Manager Plugin

If this command:

```bash
aws ssm start-session --target <INSTANCE_ID>
```

returns an error that the Session Manager Plugin is not installed, install it.

### Windows

Using Winget:

```powershell
winget install Amazon.SessionManagerPlugin
```

Verify:

```powershell
session-manager-plugin
```

Then retry:

```powershell
aws ssm start-session --target <INSTANCE_ID>
```

---

# Part 3 — SSH Configuration

The Ansible control node connects to the managed servers using SSH.

Generate an SSH key on the control node:

```bash
ssh-keygen -t ed25519
```

The public key is:

```text
~/.ssh/id_ed25519.pub
```

Copy the **public key only** to the managed server:

```text
/home/ubuntu/.ssh/authorized_keys
```

Never copy the private key:

```text
~/.ssh/id_ed25519
```

---

# Test SSH

From the Ansible control node:

```bash
ssh ubuntu@<PRIVATE_IP>
```

Example:

```bash
ssh ubuntu@10.0.3.225
```

---

# Part 4 — Ansible

Go to the Ansible directory:

```bash
cd ../ansible
```

Create the inventory:

```bash
mkdir -p inventory
nano inventory/hosts
```

Example:

```ini
[web]
web01 ansible_host=<WEB01_PRIVATE_IP>
web02 ansible_host=<WEB02_PRIVATE_IP>

[application]
app01 ansible_host=<APP01_PRIVATE_IP>

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

The real `hosts` file should not be committed to GitHub.

Use:

```text
inventory/hosts.example
```

for the public repository.

---

# Test Ansible Connectivity

```bash
ansible -i inventory/hosts all -m ping
```

Expected:

```text
web01 | SUCCESS
web02 | SUCCESS
app01 | SUCCESS
```

---

# Ansible Playbook

The project uses a playbook to configure the web servers.

Example:

```yaml
---
- name: Configure Web Servers
  hosts: web
  become: true

  tasks:

    - name: Install Nginx
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: true

    - name: Ensure Nginx is running
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
```

Run the playbook:

```bash
ansible-playbook \
  -i inventory/hosts \
  playbooks/nginx.yaml
```

---

# Verify Nginx

Check the Nginx service:

```bash
ansible -i inventory/hosts web \
  -m ansible.builtin.command \
  -a "systemctl is-active nginx"
```

Expected:

```text
active
```

---

# Terraform → Ansible Workflow

The complete workflow is:

```text
1. Terraform Init
        │
        ▼
2. Terraform Plan
        │
        ▼
3. Terraform Apply
        │
        ▼
4. AWS Infrastructure Created
        │
        ▼
5. Obtain EC2 Private IPs
        │
        ▼
6. Configure SSH
        │
        ▼
7. Create Ansible Inventory
        │
        ▼
8. Ansible Ping
        │
        ▼
9. Run Ansible Playbooks
        │
        ▼
10. Servers Configured
```

---

# Security

Do not commit sensitive information to GitHub.

Never commit:

```text
*.pem
*.key
id_rsa
id_ed25519
.aws/
*.tfstate
*.tfvars
.env
```

Do not commit:

* AWS access keys
* AWS secret keys
* SSH private keys
* passwords
* production credentials
* real environment-specific inventory

Use:

```text
inventory/hosts.example
```

instead of committing the real inventory.

---

# Cleanup

When the lab is no longer required:

```bash
cd terraform
terraform destroy
```

Confirm:

```text
yes
```

This removes the AWS resources created by Terraform.


This project is intended as a hands-on DevOps learning and portfolio project.
