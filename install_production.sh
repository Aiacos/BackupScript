## Kitsu
cd
mkdir Kitsu
cd Kitsu
git clone https://gitlab.com/mathbou/docker-cgwire.git
cd docker-cgwire

sudo bash build.sh

cd


## Ayon
cd
mkdir Ynput
cd Ynput
git clone https://github.com/ynput/ayon-docker.git
cd ayon-docker

sudo docker compose up -d
sudo make setup
sudo docker pull ynput/ayon-ash:latest
sudo docker compose up --detach --build worker

cd
