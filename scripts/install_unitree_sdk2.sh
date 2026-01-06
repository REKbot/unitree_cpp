#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  git \
  libasio-dev \
  libeigen3-dev \
  libssl-dev \
  libtinyxml2-dev

if ! ldconfig -p | grep -q ddsc; then
  rm -rf /tmp/cyclonedds
  git clone --depth 1 https://github.com/eclipse-cyclonedds/cyclonedds.git /tmp/cyclonedds
  cmake -S /tmp/cyclonedds -B /tmp/cyclonedds/build -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
  cmake --build /tmp/cyclonedds/build -j"$(nproc)"
  sudo cmake --install /tmp/cyclonedds/build
fi

rm -rf /tmp/unitree_sdk2
git clone --depth 1 https://github.com/unitreerobotics/unitree_sdk2.git /tmp/unitree_sdk2
cmake -S /tmp/unitree_sdk2 -B /tmp/unitree_sdk2/build -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build /tmp/unitree_sdk2/build -j"$(nproc)"
sudo cmake --install /tmp/unitree_sdk2/build
