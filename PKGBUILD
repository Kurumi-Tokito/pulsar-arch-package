pkgname="pulsar"
pkgver=""
pkgrel=0
pkgdesc="A community-led hyper-hackable text editor, built on electron"
arch=("")
url="https://github.com/pulsar-edit/pulsar"
license=("MIT")
makedepends=('git' 'wget' 'gcc12' 'libxkbfile' 'libsecret' 'libx11' 'libxcrypt-compat' 'python-setuptools')
optdepends=(
  "ctags: symbol indexing support"
  "git: Git and GitHub integration"
  "hunspell: spell check integration"
)
provides=("pulsar")
conflicts=('pulsar' 'pulsar-bin')
options=('ccache' 'lto' '!strip' '!debug')

source=("pulsar-$pkgver.tar.gz")
sha256sums=('SKIP')

prepare() {
  bsdtar xf "pulsar-$pkgver.tar.gz"
}

package() {
  # Pulsar-pkg
  mkdir -p "$pkgdir/usr/lib"
  mv "$srcdir/pulsar-$pkgver"  "$pkgdir/usr/lib/pulsar"

  # Pulsar.desktop
  mkdir -p "$pkgdir/usr/share/applications"
  cp ../pulsar.desktop "$pkgdir/usr/share/applications/pulsar.desktop"

  # Pulsar-Icons
  for i in 16 22 32 48 64 128 256 384; do
    mkdir -p "$pkgdir/usr/share/icons/hicolor/${i}x${i}/apps"
    curl -o "$pkgdir/usr/share/icons/hicolor/${i}x${i}/apps/pulsar.png" \
      https://raw.githubusercontent.com/pulsar-edit/pulsar/master/resources/icons/${i}x${i}.png
  done

  # Cleanup specs. Remove if implemented upstream
  find "$pkgdir/usr/lib/pulsar/resources/app/ppm" -depth -name "spec" -exec rm -rf {} +
  find "$pkgdir/usr/lib/pulsar/resources/app.asar.unpacked" -depth -name "spec" -exec rm -rf {} +

  install -Dm644 "$pkgdir/usr/lib/pulsar/resources/pulsar.svg" -t "$pkgdir/usr/share/icons/hicolor/scalable/apps"

  install -Dm755 -d "$pkgdir/usr/bin"
  chmod +x "$pkgdir/usr/lib/pulsar/resources/pulsar.sh"

  ln -sf "/usr/lib/pulsar/resources/pulsar.sh" "$pkgdir/usr/bin/pulsar"
}
