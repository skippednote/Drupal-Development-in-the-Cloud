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
VM_ID=$(terraform output -raw instance_id)
cd ../..
sed -i -e "s/VM_HOST/$VM_IP/" ansible/inventory/hosts.ini
sed -i -e "s/SOURCE_INSTANCE_ID/$VM_ID/" terraform/ami/ami.tf
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
cd terraform/ami
terraform init
terraform apply
VM_AMI=$(terraform output -raw ami)
cd ../..
sed -i -E "s/ami *= \"ami-.*\"/ami=\"$VM_AMI\"/" terraform/instance/instance.tf
cd terraform/instance
terraform apply
```
