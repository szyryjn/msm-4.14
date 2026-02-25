#!/bin/bash

# Set kernel name
BUILD_FOR="A10/11"
DATE="$(TZ=Asia/India date +%Y%m%d)"
KERNEL_NAME="KSU-NEXT${BUILD_FOR}-${DATE}.zip"

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=wildmoon
export KBUILD_BUILD_USER="szyryjn"
git clone --depth=1 https://github.com/SpiceOS-Beta/android_prebuilts_clang_host_linux-x86_clang-7612306.git clang
git clone --depth=1 https://github.com/adithya2306/prebuilts_gcc_linux-x86_aarch64_aarch64-linaro-7.git los-4.9-64
git clone --depth=1 https://github.com/MayuriLabs/linaro_arm-linux-gnueabihf-7.5.git los-4.9-32

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 vendor/violet-perf_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-gnueabihf-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zipping()
{
rm -rf AnyKernel
git clone --depth=1 -b RMX2020-KSUN https://github.com/szyryjn/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb
cp out/arch/arm64/boot/dtbo.img AnyKernel
cd AnyKernel
zip -r9 "$KERNEL_NAME" *
}

compile
zupload