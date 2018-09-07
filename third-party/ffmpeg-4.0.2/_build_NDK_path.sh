#!/bin/bash

if [ -z "${ANDROID_NDK_ROOT}" ]; then
	echo    "=========================================================================================="
	echo -e "\033[31m Error: ANDROID_NDK_ROOT is NOT set!!! \033[0m"
	echo -e "\033[31m Please set it in ~/.bash_profile to point to your NDK root path, and restart the terminal!!! \033[0m"
	echo    "=========================================================================================="
	exit 1
fi

if [ -z "${ANDROID_NDK_VERSION}" ]; then
	ANDROID_NDK_VERSION=10
fi

if [ -z "${ANDROID_NDK64_ROOT}" ]; then
	ANDROID_NDK64_ROOT=$(dirname ${ANDROID_NDK_ROOT})/android-ndk-r10e
fi

if [ -z "${ANDROID_NDK64_VERSION}" ]; then
	ANDROID_NDK64_VERSION=10
fi

FFMPEG_VERSION=4.0.2
CUR_PATH=$(pwd)
OUTPUT=${CUR_PATH}/../ffmpeg-$FFMPEG_VERSION-dev-out

if [[ $(uname -s) = "Darwin" ]]; then
	OS_NAME=darwin
else
	OS_NAME=linux
fi

echo
echo    "=========================================================================================="
echo -e "\033[31m ANDROID_NDK_ROOT: ${ANDROID_NDK_ROOT} \033[0m"
echo -e "\033[31m ANDROID_NDK_VERSION: ${ANDROID_NDK_VERSION} \033[0m"
echo -e "\033[31m ANDROID_NDK64_ROOT: ${ANDROID_NDK64_ROOT} \033[0m"
echo -e "\033[31m ANDROID_NDK64_VERSION: ${ANDROID_NDK64_VERSION} \033[0m"
echo -e "\033[31m OUTPUT: ${OUTPUT} \033[0m"
echo    "=========================================================================================="
echo

if [[ "${ANDROID_NDK_VERSION}" = "8" ]]; then 
	GCCVER=4.4.3
	PREBUILT=${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-${GCCVER}/prebuilt/${OS_NAME}-x86
	PLATFORM=${ANDROID_NDK_ROOT}/platforms/android-9/arch-arm
	PREBUILTX86=${ANDROID_NDK_ROOT}/toolchains/x86-${GCCVER}/prebuilt/${OS_NAME}-x86
	PLATFORMX86=${ANDROID_NDK_ROOT}/platforms/android-9/arch-x86
elif [[ "${ANDROID_NDK_VERSION}" = "9" ]]; then
	GCCVER=4.8
	PREBUILT=${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-${GCCVER}/prebuilt/${OS_NAME}-x86_64
	PLATFORM=${ANDROID_NDK_ROOT}/platforms/android-9/arch-arm
	PREBUILTX86=${ANDROID_NDK_ROOT}/toolchains/x86-${GCCVER}/prebuilt/${OS_NAME}-x86_64
	PLATFORMX86=${ANDROID_NDK_ROOT}/platforms/android-9/arch-x86
elif [[ "${ANDROID_NDK_VERSION}" = "10" ]]; then
	GCCVER=4.9
	PREBUILT=${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-${GCCVER}/prebuilt/${OS_NAME}-x86_64
	PLATFORM=${ANDROID_NDK_ROOT}/platforms/android-9/arch-arm
	PREBUILTX86=${ANDROID_NDK_ROOT}/toolchains/x86-${GCCVER}/prebuilt/${OS_NAME}-x86_64
	PLATFORMX86=${ANDROID_NDK_ROOT}/platforms/android-9/arch-x86	
fi

if [[ "${ANDROID_NDK64_VERSION}" = "10" ]]; then
	GCCVER_ARCH64=4.9
	PREBUILT_ARM64=${ANDROID_NDK64_ROOT}/toolchains/aarch64-linux-android-${GCCVER_ARCH64}/prebuilt/${OS_NAME}-x86_64
	PLATFORM_ARM64=${ANDROID_NDK64_ROOT}/platforms/android-21/arch-arm64
	PREBUILT_X86_64=${ANDROID_NDK64_ROOT}/toolchains/x86_64-${GCCVER_ARCH64}/prebuilt/${OS_NAME}-x86_64
	PLATFORM_X86_64=${ANDROID_NDK64_ROOT}/platforms/android-21/arch-x86_64
fi

NDK_ARMv7_Bin_Path=${OUTPUT}/ffmpeg-bin-NDK_ARMv7
NDK_GCC_Bin_Path=${OUTPUT}/ffmpeg-bin-NDK_GCC
NDK_X86_Bin_Path=${OUTPUT}/ffmpeg-bin-NDK_x86
NDK_ARM64_Bin_Path={$OUTPUT}/ffmpeg-bin-NDK_ARM64
NDK_X86_64_Bin_Path={$OUTPUT}/ffmpeg-bin-NDK_X86_64
NDK_Obj_Path=${OUTPUT}/ffmpeg-obj

PLAYER_CORE_FFMPEG_PATH=${CUR_PATH}/../Core/jni/libFFmpeg-$FFMPEG_VERSION
PLAYER_CORE_OUTPUT_PATH=${CUR_PATH}/../Core/libs
PLAYER_CORE_SYMBOL_OUTPUT_PATH=${CUR_PATH}/../Core/obj
APP_OUTPUT_PATH=${CUR_PATH}/../Core/app_libs
