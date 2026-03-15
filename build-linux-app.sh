#!/usr/bin/env bash

set -xe

system_arch="$(uname -m)"

sw_version="1.0.2"

appimagetool_version="1.9.1"
appimagetool_filename="appimagetool-$system_arch.AppImage"
appimagetool_baseurl="https://github.com/AppImage/appimagetool/releases/download/$appimagetool_version"

runtime_version="20251108"
runtime_filename="runtime-$system_arch"
runtime_baseurl="https://github.com/AppImage/type2-runtime/releases/download/$runtime_version"

# Shared libraries as of Ubuntu 22.04
required_libs=(
	libbsd.so.0
	libdecor-0.so.0
	libmd.so.0
	libSDL2-2.0.so.0
	libXss.so.1
)

cmake -S . -B build
cmake --build build -j "$(nproc)"
chmod 0644 build/Data

mkdir -p RecklessDrivin.AppDir/usr/{bin,lib,share/{applications,assets}}

cp -a build/Data RecklessDrivin.AppDir/usr/share/assets/
cp -a build/RecklessDrivin RecklessDrivin.AppDir/usr/bin/
cp -a packaging/linux/{AppRun,RecklessDrivin.desktop} RecklessDrivin.AppDir/
cp -a packaging/linux/Icon_128x128.png RecklessDrivin.AppDir/RecklessDrivin.png
cp -a packaging/linux/RecklessDrivin.desktop RecklessDrivin.AppDir/usr/share/applications/

for lib in "${required_libs[@]}"; do
	cp -a -L "/lib/$system_arch-linux-gnu/$lib" RecklessDrivin.AppDir/usr/lib/
done

if [ ! -f "$appimagetool_filename" ]; then
	curl -sSf -L -O "$appimagetool_baseurl/$appimagetool_filename"
	chmod +x "$appimagetool_filename"
	echo "f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158  $appimagetool_filename" | shasum -a 256 -c
fi

if [ ! -f "$runtime_filename" ]; then
	curl -sSf -L -O "$runtime_baseurl/$runtime_filename"
	chmod +x "$runtime_filename"
	echo "00cbdfcf917cc6c0ff6d3347d59e0ca1f7f45a6df1a428a0d6d8a78664d87444  $runtime_filename" | shasum -a 256 -c
fi

./"$appimagetool_filename" --no-appstream --runtime-file "runtime-$system_arch" RecklessDrivin.AppDir "RecklessDrivin-$sw_version-linux-$system_arch.AppImage"

rm -r RecklessDrivin.AppDir
