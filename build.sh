#!/usr/bin/bash

set -e

dir="$(pwd)"
buildir="$(pwd)/build"
pkgdir="$buildir/pkg"
outdir="$buildir/out"

setup() {
    echo "Install & upgrading Build Packages"
    pacman -Syuu --noconfirm --needed base-devel libxkbfile libsecret libx11 libxcrypt-compat jq git wget python-setuptools ccache

    # Get gcc12 from ArchLinux Archives
    wget -q https://archive.archlinux.org/packages/g/gcc12-libs/gcc12-libs-12.2.1-1-x86_64.pkg.tar.zst
    wget -q https://archive.archlinux.org/packages/g/gcc12/gcc12-12.2.1-1-x86_64.pkg.tar.zst
    pacman -U gcc12-libs-12.2.1-1-x86_64.pkg.tar.zst --noconfirm
    pacman -U gcc12-12.2.1-1-x86_64.pkg.tar.zst --noconfirm

    # Get nvm Node Manager
    wget -q https://github.com/Ivy-Tokito/aur-package-builder/releases/download/v0.39.7-1/nvm-0.39.7-1-any.pkg.tar.zst
    pacman -U nvm-0.39.7-1-any.pkg.tar.zst --noconfirm
    pacman -Syuu --noconfirm --needed

    # Source nvm
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    source /usr/share/nvm/nvm.sh
    source /usr/share/nvm/bash_completion
    source /usr/share/nvm/install-nvm-exec

    # create non-privileged user for makepkg
    groupadd sudo
    useradd -m user || true
    usermod -aG sudo user
    echo "## Allow user to execute any root command
    user ALL=(ALL) NOPASSWD: /usr/bin/pacman" >> "/etc/sudoers"
}

[[ $(command -v gcc-12) ]] || setup

mkdir -p "$buildir"
cd "$buildir" && echo "Entering BUILD DIR:$(pwd)" || exit 1

# Clone Source
git clone https://github.com/pulsar-edit/pulsar.git
cd pulsar && echo "Entering pulsar source:$(pwd)" || exit 1
git checkout "tags/v$PKGVER"
git log --oneline -5 && sleep 5 #show last 5 commits
git submodule init && git submodule update
sed -i -e "s/[0-9]*-dev/`date -u +%Y%m%d%H`/g" package.json

cd "$buildir/pulsar" && echo "Entering pulsar source:$(pwd)" || exit 1

# Install & Update node
nvm install
corepack enable
nvm use
yes | npx node-gyp install

# use gcc12 ## gcc13 produce errors
export CC=gcc-12
export CXX=g++-12

# Optimize flags
export CFLAGS=" -O3 -flto=auto -fuse-linker-plugin -mtune=generic -march=$ARCH"
export CXXFLAGS="-O3 -flto=auto -fuse-linker-plugin -mtune=generic -march=$ARCH"
export LDFLAGS+=" -Wl,--no-keep-memory"

# ccache
export USE_CCACHE=1 CCACHE_EXEC=$(which ccache)

cd "$buildir/pulsar" && echo "Entering pulsar source:$(pwd)" || exit 1

# Build
yarn install --parallel $(nproc --all)
yarn build
yarn build:apm --parallel $(nproc --all)
yarn dist tar.gz --parallel $(nproc --all)

echo -e "\n\nBuild Completed!"

# package
mkdir -p "$pkgdir"
cp "$buildir/pulsar/binaries/pulsar-$PKGVER.tar.gz" "$pkgdir"
cp "$dir/pulsar.desktop" "$pkgdir"
cp "$dir/PKGBUILD" "$pkgdir"

cd "$pkgdir" && echo "Entering PKG-DIR: $(pwd)" || exit 1

# Change Owners
chown -R user:user "$buildir"

sudo -u user bash <<EXC
makepkg -CL
EXC
echo "Packaging Completed!" 

mkdir -p /out/packages
find "$pkgdir" -type f -name "pulsar*.pkg*" -exec cp -v {} "/out/packages" \;

rm -rf "buildir"
