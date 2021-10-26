#cd /home/ubuntu/gama_devop5/single-master/ami-terraform
cd ami-terraform
/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -var="resource_id=${ID_MAQUINA/\",/}" -auto-approve
/usr/local/bin/terraform output
