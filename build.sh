#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

rm -rf build
mkdir build
cd build

curl https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.1.tar.xz -o libxml2-2.15.1.tar.xz
tar -xf libxml2-2.15.1.tar.xz
cd libxml2-2.15.1
./configure --disable-shared --enable-static
make -j$(nproc)
LIBXML2_DIR="$(pwd)"

cd ..

curl https://ftp.gnu.org/gnu/gettext/gettext-0.26.tar.gz -o gettext-0.26.tar.gz
tar -xf gettext-0.26.tar.gz
cd gettext-0.26
CPPFLAGS="-I${LIBXML2_DIR}/include" \
LDFLAGS="-L${LIBXML2_DIR}/.libs --static" \
./configure --disable-shared --enable-static
make -j$(nproc)

# every tool `django-admin makemessages` calls, plus msgfmt
cp gettext-tools/src/xgettext \
  gettext-tools/src/msguniq \
  gettext-tools/src/msgmerge \
  gettext-tools/src/msgattrib \
  gettext-tools/src/msgfmt \
  ../../x86_64-linux/

echo "Build complete. Verify with:"
echo "ldd build/gettext-0.26/gettext-tools/src/msgfmt"
