sudo yum update -y
sudo yum install -y openssl git java-1.8.0-openjdk

export DOCKERURL='https://storebits.docker.com/ee/trial/sub-b2b111b2-f32b-4030-a92f-6f94c298feb8'
sudo -E sh -c 'echo "$DOCKERURL/centos" > /etc/yum/vars/dockerurl'
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo -E yum-config-manager     --add-repo     "$DOCKERURL/centos/docker-ee.repo"
sudo yum -y install docker-ee
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
sudo usermod -aG docker vagrant

#docker compose install
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
