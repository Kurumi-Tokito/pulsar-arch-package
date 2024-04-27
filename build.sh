#!/usr/bin/bash

set -e

dir="$(pwd)"
buildir="$(pwd)/build"
pkgdir="$buildir/pkg"
outdir="$buildir/out"

export PKGVER="1.116.0"

echo "Install & upgrading Build Packages"
sudo pacman -Sy  --noconfirm --needed base-devel gcc12 libxkbfile libsecret libx11 libxcrypt-compat jq git wget python-setuptools


mkdir -p "$buildir"
cd "$buildir" && echo "Entering BUILD DIR:$(pwd)" || exit 1

# Clone Source
git clone https://github.com/pulsar-edit/pulsar.git
cd pulsar && echo "Entering pulsar source:$(pwd)" || exit 1
git checkout "tags/v$pkgver"
git log --oneline -5 && sleep 5 #show last 5 commits
git submodule init && git submodule update
sed -i -e "s/[0-9]*-dev/`date -u +%Y%m%d%H`/g" package.json

cd "$buildir/pulsar" && echo "Entering pulsar source:$(pwd)" || exit 1
# instal nvm node manager
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh

# Install & Update node
nvm install
corepack enable
nvm use
yes | npx node-gyp install

# use gcc12 ## gcc13 produce errors
export CC=gcc-12
export CXX=g++-12

# Optimize flags
export CFLAGS=" -O3 -flto=auto -fuse-linker-plugin -mtune=generic -march=x86-64"
export CXXFLAGS="-O3 -flto=auto -fuse-linker-plugin -mtune=generic -march=x86-64"
export LDFLAGS+=" -Wl,--no-keep-memory"

cd "$buildir/pulsar" && echo "Entering pulsar source:$(pwd)" || exit 1

# Build
yarn install --parallel $(nproc --all)
yarn build
yarn build:apm --parallel $(nproc --all)
yarn dist tar.gz --parallel $(nproc --all)

echo -e "\n\nBuild Completed!"

# package
mkdir -p "$pkgdir"
cp "$buildir/pulsar/binaries/pulsar-$PKGVER.tar.gz" "pkgdir"
cp "$dir/pulsar.desktop" "$pkgdir"
cp "$dir/PKGBUILD" "$pkgdir"

cd "$pkgdir" && echo "Entering PKG-DIR: $(pwd)" || exit 1
makepkg -CL
cp "pulsar-$PKGVER-0-x86_64.pkg.tar.zst" "$outdir"

echo "Packaging Completed"
echo "Package: $(ls $outdir/*.zst)"
