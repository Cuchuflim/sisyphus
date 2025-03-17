#!/bin/bash

# Install git
sudo apt install git -y
sudo apt install -y python3 python3-venv python3-pip 

# Install dependencies and flutter-pi
git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git engine-binaries
cd engine-binaries && sudo ./install.sh
sudo apt install cmake libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev ttf-mscorefonts-installer fontconfig libsystemd-dev libinput-dev libudev-dev  libxkbcommon-dev -y
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-alsa -y
sudo fc-cache
cd /home/ssm-user && git clone --recursive https://github.com/ardera/flutter-pi
cd flutter-pi && sudo mkdir build
cd build && sudo cmake ..
sudo make -j`nproc`
sudo make install

# Download bundle
sudo mkdir /home/ssm-user/bundle
aws s3 cp s3://{repo}/flutterbundle.zip /home/ssm-user/bundle/flutterbundle.zip
unzip /home/ssm-user/bundle/flutterbundle.zip -d /home/ssm-user/flutterapp
sudo rm -rf /home/ssm-user/bundle

# Download .service
aws s3 cp s3://{repo}/services/flutter-start.service /lib/systemd/system

# activate service
sudo systemctl daemon-reload
sudo systemctl enable flutter-start.service

sudo reboot