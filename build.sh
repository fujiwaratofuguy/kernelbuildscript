SECONDS=0 # builtin bash timer
ZIPNAME="Kouki-Kernel-$(date '+%Y%m%d-%H%M').zip"
TC_DIR="$HOME/workfolder/proton-clang"
DEFCONFIG="vendor/RMX1911_defconfig"
AK3_DIR="$HOME/workfolder/Ak3"

export PATH="$TC_DIR/bin:$PATH"

if ! [ -d "$AK3_DIR" ]; then
echo "AnyKernel3 not found! Cloning to $TC_DIR..."
if ! git clone -q --depth=1 --single-branch https://github.com/osm0sis/AnyKernel3.git $AK3_DIR; then
echo "Cloning failed! Aborting..."
fi
fi

if ! [ -d "$TC_DIR" ]; then
echo "Proton clang not found! Cloning to $TC_DIR..."
if ! git clone -q --depth=1 --single-branch https://github.com/kdrag0n/proton-clang.git $TC_DIR; then
echo "Cloning failed! Aborting..."
fi
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
rm -rf out
fi

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CC=clang O=out ARCH=arm64 2>&1 | tee log_$(date '+%Y%m%d-%H%M').txt
if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "out/arch/arm64/boot/dtbo.img" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"

fi
cp out/arch/arm64/boot/Image.gz-dtb /$HOME/workfolder/Ak3
cp out/arch/arm64/boot/dtbo.img /$HOME/workfolder/Ak3
cd /$HOME/workfolder/Ak3
rm -f *.zip
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
echo -e "\n REMOVING Image.gz-dtb and dtbo.img in Anykernel folder\n"
rm -rf /$HOME/workfolder/AnyKernel3/Image.gz-dtb && rm -rf /$HOME/workfolder/Ak3/dtbo.img
echo -e "\n REMOVING Image.gz-dtb and dtbo.img in out folder\n"
cd /$HOME/workfolder/kernelsource/out/arch/arm64/boot
rm -rf Image.gz-dtb && rm -rf dtbo.img
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"
