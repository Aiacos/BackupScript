## Setup Docker folder
cd
mkdir Docker

## Setup Ayon Ynput pipeline
cd Docker
git clone https://github.com/ynput/ayon-docker.git
cd ayon-docker

###############################sudo sed -i 's/ENABLE_SHARE=0/ENABLE_SHARE=1/g' /etc/speedify/speedify.conf

sudo docker compose up -d
sudo make setup
sudo docker pull ynput/ayon-ash:latest
sudo docker compose up --detach --build worker

cd


## Setup Kitsu
cd Docker

git clone https://github.com/EmberLightVFX/Kitsu-for-Docker.git
cd Kitsu-for-Docker

##

sudo docker compose up -d
