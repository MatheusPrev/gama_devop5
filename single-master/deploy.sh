#cd /home/ubuntu/gama_devop5/single-master/terraform
cd single-master/terraform
/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -auto-approve

cd ../
pwd

#echo $"[ec2-jenkins]" >> /home/ubuntu/gama_devop5/single-master/ansible/hosts # cria arquivo
echo $"[ec2-jenkins]" > ansible/hosts # cria arquivo
#echo "$(/usr/local/bin/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> /home/ubuntu/gama_devop5/single-master/ansible/hosts # captura output faz split de espaco e replace de ",
echo "$(/usr/local/bin/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> ansible/hosts

echo "Aguardando criação de maquinas ..."
sleep 30 # 30 segundos

#cd /home/ubuntu/gama_devop5/single-master/ansible
cd single-master/ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key ~/.ssh/id_rsa

#cd /home/ubuntu/gama_devop5/single-master/terraform
cd single-master/terraform
/usr/local/bin/terraform output

echo $"Agora somente abrir a URL: http://$(/usr/local/bin/terraform output | grep public_dns | awk '{print $2;exit}'):8080" | sed -e "s/\",//g"

ID_MAQUINA=$(/usr/local/bin/terraform output | grep id | awk '{print $2;exit}')
echo ${ID_MAQUINA/\",/}

#cd /home/ubuntu/gama_devop5/single-master/ami-terraform
cd single-master/ami-terraform

/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -var="resource_id=${ID_MAQUINA/\",/}" -auto-approve 
#/usr/local/bin/terraform apply -var="resource_id=i-062b0b80ee1469f44" -auto-approve 
/usr/local/bin/terraform output
