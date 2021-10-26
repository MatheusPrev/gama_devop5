pwd
cd single-master/terraform
/usr/local/bin/terraform output

ID_MAQUINA=$(/usr/local/bin/terraform output | grep id_ami | awk '{print $2;exit}')
echo "=================[$ID_MAQUINA]===============" 
cd ../

cd ami-terraform
/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -var="resource_id=${ID_MAQUINA/\",/}" -auto-approve 
/usr/local/bin/terraform output
