pkgname="pulsar"
pkgver=""
pkgrel=0
pkgdesc="A community-led hyper-hackable text editor, built on electron"
arch=("x86_64")
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
options=('!ccache' '!lto')
source=(
  "git+https://github.com/pulsar-edit/pulsar.git#tag=v$pkgver"
	"pulsar-$pkgver.tar.gz"
)

sha256sums=(
  'SKIP'
  'SKIP'
)

prepare() {
  bsdtar xf "pulsar-$pkgver.tar.gz"
}

package() {
  # Pulsar-pkg
  mkdir "$pkgdir/opt"
  mv "$srcdir/pulsar-$pkgver"  "$pkgdir/opt/Pulsar"

  # pulsar.desktop
  mkdir -p "$pkgdir/usr/share/applications"
  cp ../pulsar.desktop "$pkgdir/usr/share/applications/pulsar.desktop"

  # Pulsar-Icons
  for icon in '384x384' '256x256' '128x128' '64x64' '48x48' '32x32' '24x24' '22x22' '16x16'; do
    mkdir -p "$pkgdir/usr/share/icons/hicolor/$icon/apps"
    cp -v "$srcdir/pulsar/resources/icons/$icon.png" "$pkgdir/usr/share/icons/hicolor/$icon/apps/pulsar.png"
  done

  # Cleanup specs. Remove if implemented upstream
  find "$pkgdir/opt/Pulsar/resources/app/ppm" -type d -name "spec" -exec rm -rf {} +
  find "$pkgdir/opt/Pulsar/resources/app.asar.unpacked" -type d -name "spec" -exec rm -rf {} +

  install -Dm644 "$pkgdir/opt/Pulsar/resources/pulsar.svg" -t "$pkgdir/usr/share/icons/hicolor/scalable/apps"

  install -Dm755 -d "$pkgdir/usr/bin"
  chmod +x "$pkgdir/opt/Pulsar/resources/pulsar.sh"

  ln -sf "/opt/Pulsar/resources/pulsar.sh" "$pkgdir/usr/bin/pulsar"
}
