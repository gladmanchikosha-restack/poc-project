sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible —version

scp 

cd /opt

[jenkins-master]
13.245.198.187

[jenkins-master:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/opt/gladman-new.pem

[jenkins-slave]
13.247.64.187

[jenkins-slave:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/opt/gladman-new.pem

ansible -i hosts all -m ping

#Jenkins slave steps

