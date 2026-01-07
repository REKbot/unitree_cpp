#!/usr/bin/env bash
set -euo pipefail

SUDO=""
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

install_packages_deb() {
  ${SUDO} apt-get update
  ${SUDO} apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libasio-dev \
    libeigen3-dev \
    libssl-dev \
    libtinyxml2-dev
}

install_packages_rpm() {
  ${SUDO} yum install -y \
    git \
    make \
    gcc \
    gcc-c++ \
    openssl-devel \
    eigen3-devel \
    tinyxml2-devel
  if command -v cmake3 >/dev/null 2>&1; then
    ${SUDO} yum install -y cmake3
  else
    ${SUDO} yum install -y cmake
  fi
}

install_packages_dnf() {
  ${SUDO} dnf install -y \
    git \
    make \
    gcc \
    gcc-c++ \
    openssl-devel \
    eigen3-devel \
    tinyxml2-devel \
    cmake
}

if command -v apt-get >/dev/null 2>&1; then
  install_packages_deb
elif command -v dnf >/dev/null 2>&1; then
  install_packages_dnf
elif command -v yum >/dev/null 2>&1; then
  install_packages_rpm
else
  echo "No supported package manager found." >&2
  exit 1
fi

cmake_cmd="$(command -v cmake || command -v cmake3)"
if [ -z "${cmake_cmd}" ]; then
  echo "cmake not found after package install." >&2
  exit 1
fi

if ! ldconfig -p 2>/dev/null | grep -q ddsc; then
  rm -rf /tmp/cyclonedds
  git clone --depth 1 https://github.com/eclipse-cyclonedds/cyclonedds.git /tmp/cyclonedds
  "${cmake_cmd}" -S /tmp/cyclonedds -B /tmp/cyclonedds/build -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
  "${cmake_cmd}" --build /tmp/cyclonedds/build -j"$(nproc)"
  ${SUDO} "${cmake_cmd}" --install /tmp/cyclonedds/build
fi

rm -rf /tmp/unitree_sdk2
git clone --depth 1 https://github.com/unitreerobotics/unitree_sdk2.git /tmp/unitree_sdk2
"${cmake_cmd}" -S /tmp/unitree_sdk2 -B /tmp/unitree_sdk2/build -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_EXAMPLES=OFF
"${cmake_cmd}" --build /tmp/unitree_sdk2/build -j"$(nproc)"
${SUDO} "${cmake_cmd}" --install /tmp/unitree_sdk2/build
