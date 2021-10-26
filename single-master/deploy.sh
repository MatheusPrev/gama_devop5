
cd single-master/terraform
/usr/local/bin/terraform init
/usr/local/bin/terraform fmt
/usr/local/bin/terraform apply -auto-approve




echo "[ec2-jenkins]" > ../ansible/hosts # cria arquivo
echo "$(/usr/local/bin/terraform output | grep public_dns | awk '{print $2;exit}')" | sed -e "s/\",//g" >> ../ansible/hosts

echo "Aguardando criação de maquinas ..."
sleep 10 # 30 segundos

cd ../
pwd


cd ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key ~/.ssh/id_rsa

cd ../
pwd
cd terraform
/usr/local/bin/terraform output

echo $"Agora somente abrir a URL: http://$(/usr/local/bin/terraform output | grep public_dns | awk '{print $2;exit}'):8080" | sed -e "s/\",//g"

ID_MAQUINA=$(/usr/local/bin/terraform output | grep id_ami | awk '{print $2;exit}')
echo ${ID_MAQUINA/\",/}
