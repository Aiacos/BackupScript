## Maya Installe Script
# Variables
### maya_version = 2022
# Dipendencies
sudo dnf install mesa-libGLw -y
sudo dnf install mesa-libGLU -y
sudo dnf install libXp -y
sudo dnf install libXmu -y
sudo dnf install libXt -y
sudo dnf install libXi -y
sudo dnf install libXext -y
sudo dnf install libX11 -y
sudo dnf install libXinerama -y
sudo dnf install libXau -y
sudo dnf install libxcb -y
sudo dnf install libXScrnSaver -y
sudo dnf install gamin -y
sudo dnf install audiofile -y
sudo dnf install audiofile-devel -y
sudo dnf install e2fsprogs-libs -y
sudo dnf install libxkbcommon-x11 -y
sudo dnf install xorg-x11-fonts-ISO8859-1-100dpi -y
sudo dnf install xorg-x11-fonts-ISO8859-1-75dpi -y
sudo dnf install liberation-mono-fonts -y
sudo dnf install liberation-fonts-common -y
sudo dnf install liberation-sans-fonts -y
sudo dnf install liberation-serif-fonts -y
sudo dnf install ncurses-compat-libs -y
sudo dnf install compat-openssl10 -y
sudo dnf install libpng15 -y
sudo dnf install libnsl -y
sudo dnf install nss -y
sudo dnf install glibc -y
sudo dnf install zlib -y
sudo dnf install libSM -y
sudo dnf install libICE -y

# Download Maya .rpm
mkdir -p ~/Downloads/maya_build
cd ~/Downloads/maya_build

wget https://rpmfind.net/linux/centos/8-stream/AppStream/x86_64/os/Packages/compat-openssl10-1.0.2o-4.el8.x86_64.rpm
sudo dnf install compat-openssl10-1.0.2o-4.el8.x86_64.rpm -y

wget https://up.autodesk.com/2023/PLC0000036/CA2DD799-0513-3E69-927A-F50C976E1FCC/AdskLicensingInstaller-12.2.0.17.tar.gz
tar xvf AdskLicensingInstaller-12.2.0.17.tar.gz
cd /adsklicensinginstaller
sudo dnf install -y adlmapps26-26.0.7-0.x86_64.rpm adskflexnetclient-11.18.0-0.x86_64.rpm adsklicensing12.2.0.17-0-0.x86_64.rpm

cd ..
wget https://dds.autodesk.com/NetSWDLD/2022/MAYA/C6122BA7-C730-31C1-BBA8-315D8E96B8A8/ESD/Autodesk_Maya_2022_4_ML_Linux_64bit.tgz
tar xvf Autodesk_Maya_2022_4_ML_Linux_64bit.tgz
