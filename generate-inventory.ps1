$ErrorActionPreference = "Stop"

# Read managed-node Private IPs from Terraform outputs

$output = terraform -chdir=terraform output -json managed_node_private_ips
$ips = $output | ConvertFrom-Json
$appIp = $ips.PSObject.Properties['app-ubuntu'].Value
# Generate Ansible inventory 

$inventory = @"
[web]
web-amazon ansible_host=$($ips.'web-amazon') ansible_user=ec2-user
web-ubuntu ansible_host=$($ips.'web-ubuntu') ansible_user=ubuntu

[application]
app-ubuntu ansible_host=$appIp ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
"@

# Save inventory in the ansible directory 
$inventory | Set-Content -Path "ansible/inventory/hosts" -Encoding ascii

Write-Host "Ansible inventory generated successfully."
Get-Content "ansible/inventory/hosts"
