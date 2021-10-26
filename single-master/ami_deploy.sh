pwd
cd single-master/ami-terraform
/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -var="resource_id=${ID_MAQUINA/\",/}" -auto-approve
/usr/local/bin/terraform output
