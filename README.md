## Drupal Development in the Cloud (AWS)

#### Generate SSH keys

```
mkdir keys
ssh-keygen -t rsa -b 4096 -C "key" -f keys/key
```

#### Create Infrastructure

```
cd terraform/instance
terraform init
terraform apply
```

#### Update the inventory files based on Terraform ouput

```
VM_IP=$(terraform output -raw ip)
// set VM_IP (terraform output -raw ip)
cd ../..
sed -i '' "s/VM_HOST/$VM_IP/" ansible/inventory/hosts.ini
```

#### Install relevant packages

```
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml
```

#### SSH into the server

```
ssh -i keys/key ubuntu@$VM_IP
```

#### Create an AMI from the previously created instance

```
VM_ID=$(terraform output -raw instance_id)
// set VM_IP (terraform output -raw instance_id)
sed -i '' "s/SOURCE_INSTANCE_ID/$VM_ID/" terraform/ami/ami.tf
cd terraform/ami
terraform init
terraform apply
VM_AMI=$(terraform output -raw ami)
// set VM_AMI (terraform output -raw ami)
cd ../..
sed -i '' "s/ami *= \"ami-.*\"/ami=\"$VM_AMI\"/" terraform/instance/instance.tf
cd terraform/instance
terraform apply
```

#### Docker permissions

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
