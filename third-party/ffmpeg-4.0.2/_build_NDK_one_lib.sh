#!/bin/bash 
################################################################################
# Print the help message.
################################################################################
if [[ ("$1" != "x86"
		&& "$1" != "x86_debug"
		&& "$1" != "gcc"
		&& "$1" != "gcc_debug"
		&& "$1" != "neon"
		&& "$1" != "neon_debug"
		&& "$1" != "arm64"
		&& "$1" != "arm64_debug")
	|| ("$2" != "min"
		&& "$2" != "full") ]]; then
	echo "=========================================================================================="
	echo "Usage: $0 <x86|x86_debug|gcc|gcc_debug|neon|neon_debug|arm64|arm64_debug> <min|full> [rebuild] [strip]"
	echo "Example:"
	echo "1. $0 gcc min rebuild strip"
	echo "    -- Output: rebuild libTxCodec.so, a pure c version for ARM platform, with debug symbols stripped."
	echo "2  $0 neon_debug min rebuild"
	echo "    -- Output: rebuild libTxCodec_neon_obj.so, an ARM neon asm version, with full debug symbols."
	echo "3. $0 neon min"
	echo "    -- Output: incrementally build libTxCodec_neon.so, an ARM neon asm version."
	echo "4. $0 neon full"
	echo "    -- Output: incrementally build libTxCodec_neon.so, an ARM neon asm version with full format support."
	echo "=========================================================================================="
	exit 1
fi

################################################################################
# @param $1 - result of execution
# @param $2 - operation type that caused the error
################################################################################
check_result() {
	if [[ $1 != 0 ]]; then
		echo    "=========================================================================================="
		echo -e "\033[31m Error: Failed to ${2}!!! \033[0m"
		echo    "=========================================================================================="
		cd -
		exit 1
	fi
}

################################################################################
# @param $1 - message to print.
################################################################################
print_message() {
	echo    "=========================================================================================="
	echo -e "\033[31m ${1} \033[0m"
	echo    "=========================================================================================="
}

################################################################################
# Setup the configuration and output path.
# The building will be performed in ${NDK_Obj_Path}
################################################################################
echo
echo
print_message "===== Start to build: ${1} ===="
source _build_NDK_path.sh
if [[ "$2" = "full" ]]; then
	source _build_FFmpeg_CodecParam_full.sh
	BUILD_CONFIG_TYPE="full"
else
	source _build_FFmpeg_CodecParam_min.sh
	BUILD_CONFIG_TYPE="min"
fi

NDK_Obj_Path=${NDK_Obj_Path}-${BUILD_CONFIG_TYPE}-${1}
mkdir -p ${NDK_Obj_Path}
FFMPEG_SRC_DIR=$(pwd)
cd ${NDK_Obj_Path}

PLAYER_CORE_FFMPEG_PATH=${PLAYER_CORE_FFMPEG_PATH}-${BUILD_CONFIG_TYPE}
PLAYER_CORE_OUTPUT_PATH=${PLAYER_CORE_OUTPUT_PATH}-${BUILD_CONFIG_TYPE}
PLAYER_CORE_SYMBOL_OUTPUT_PATH=${PLAYER_CORE_SYMBOL_OUTPUT_PATH}-${BUILD_CONFIG_TYPE}

################################################################################
# Set the common ffmpeg configurations for different platforms.
################################################################################
FFMPEG_CONFIG_COMMON_X86=(
	--cross-prefix=${PREBUILTX86}/bin/i686-linux-android-
	--enable-cross-compile
	--target-os=linux
	--sysroot=${PLATFORMX86}
	--arch=x86
	--disable-asm
	--disable-mmx
	--disable-mmxext
	--disable-sse
	--disable-sse2
	--disable-sse3
	--disable-ssse3
	--disable-sse4
	--disable-sse42
	--disable-yasm
	--prefix=${NDK_X86_Bin_Path}
	--extra-cflags="-O3 -DANDROID -fpic ${EXTERNAL_LIBS_HEADER_X86} -DBUILD_CONFIG_TYPE=${BUILD_CONFIG_TYPE}"
	--extra-ldflags="-L${PLATFORMX86}/usr/lib ${EXTERNAL_LIBS_X86}"
	--pkg-config="${FFMPEG_SRC_DIR}/../ffmpeg-external-libs/pkg-config-android-x86"
	)

FFMPEG_CONFIG_COMMON_GCC=(
	--cross-prefix=${PREBUILT}/bin/arm-linux-androideabi-
	--enable-cross-compile
	--target-os=linux
	--sysroot=${PLATFORM}
	--arch=arm
	--disable-asm
	--disable-neon
	--prefix=${NDK_GCC_Bin_Path}
	--extra-cflags="-O3 -DANDROID -fpic -Wimplicit-function-declaration ${EXTERNAL_LIBS_HEADER_GCC}  -DBUILD_CONFIG_TYPE=${BUILD_CONFIG_TYPE}"
	--extra-ldflags="-L${PLATFORM}/usr/lib ${EXTERNAL_LIBS_GCC}"
	--pkg-config="${FFMPEG_SRC_DIR}/../ffmpeg-external-libs/pkg-config-android-arm"
	)

FFMPEG_CONFIG_COMMON_NEON=(
	--cross-prefix=${PREBUILT}/bin/arm-linux-androideabi-
	--enable-cross-compile
	--target-os=linux
	--sysroot=${PLATFORM}
	--cpu=cortex-a9
	--arch=arm
	--enable-asm
	--enable-neon
	--prefix=${NDK_ARMv7_Bin_Path}
	--extra-cflags="-O3 -DANDROID -fpic -mfloat-abi=softfp -mfpu=neon -Wimplicit-function-declaration ${EXTERNAL_LIBS_HEADER_NEON}  -DBUILD_CONFIG_TYPE=${BUILD_CONFIG_TYPE}"
	--extra-ldflags="-L${PLATFORM}/usr/lib ${EXTERNAL_LIBS_NEON}"
	--pkg-config="${FFMPEG_SRC_DIR}/../ffmpeg-external-libs/pkg-config-android-arm"
	)

FFMPEG_CONFIG_COMMON_ARM64=(
	--cross-prefix=${PREBUILT_ARM64}/bin/aarch64-linux-android-
	--enable-cross-compile
	--target-os=linux
	--sysroot=${PLATFORM_ARM64}
	--cpu=cortex-a53
	--arch=arm64
        --enable-neon
	--prefix=${NDK_ARM64_Bin_Path}
	--extra-cflags="-O3 -DANDROID -fpic -Wimplicit-function-declaration ${EXTERNAL_LIBS_HEADER_ARM64}"
	--extra-ldflags="-L${PLATFORM_ARM64}/usr/lib ${EXTERNAL_LIBS_ARM64}"
	--pkg-config="${FFMPEG_SRC_DIR}/../ffmpeg-external-libs/pkg-config-android-arm64"
	)

################################################################################
# Set variables according to the platform specified by the user.
################################################################################
if [[ "x86" = "$1" || "x86_debug" = "$1" ]]; then
	if [[ "x86" = "$1" ]]; then
		SO_NAME=libTxCodec_x86.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_X86[@]}" --disable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	else
		SO_NAME=libTxCodec_x86_obj.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_X86[@]}" --enable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_SYMBOL_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	fi
	EXTERNAL_LIBS=${EXTERNAL_LIBS_X86}
	PLAYER_CORE_FFMPEG_LIB_PATH=${PLAYER_CORE_FFMPEG_PATH}/libX86
	SO_PATH=${NDK_X86_Bin_Path}
	PLATFORM_PATH=${PLATFORMX86}
	if [[  "${ANDROID_NDK_VERSION}" = "10" ]]; then
		EXTRA_LD_FLAGS="-z noexecstack -ldl"
	else
		EXTRA_LD_FLAGS="-z,noexecstack --warn-once"
	fi

	LIB_GCC=${PREBUILTX86}/lib/gcc/i686-linux-android/${GCCVER}/libgcc.a
	ANDROID_AR=${PREBUILTX86}/bin/i686-linux-android-ar
	ANDROID_LD=${PREBUILTX86}/bin/i686-linux-android-ld
	ANDROID_STRIP=${PREBUILTX86}/bin/i686-linux-android-strip
elif [[ "gcc" = "$1" || "gcc_debug" = "$1" ]]; then
	if [[ "gcc" = "$1" ]]; then
		SO_NAME=libTxCodec.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_GCC[@]}" --disable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	else
		SO_NAME=libTxCodec_obj.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_GCC[@]}" --enable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_SYMBOL_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	fi
	EXTERNAL_LIBS=${EXTERNAL_LIBS_GCC}
	PLAYER_CORE_FFMPEG_LIB_PATH=${PLAYER_CORE_FFMPEG_PATH}/libGCC
	SO_PATH=${NDK_GCC_Bin_Path}
	PLATFORM_PATH=${PLATFORM}
	if [[  "${ANDROID_NDK_VERSION}" = "10" ]]; then
		EXTRA_LD_FLAGS="-z noexecstack"
	else
		EXTRA_LD_FLAGS="-z,noexecstack --warn-once"
	fi
	LIB_GCC=${PREBUILT}/lib/gcc/arm-linux-androideabi/${GCCVER}/libgcc.a
	ANDROID_AR=${PREBUILT}/bin/arm-linux-androideabi-ar
	ANDROID_LD=${PREBUILT}/bin/arm-linux-androideabi-ld
	ANDROID_STRIP=${PREBUILT}/bin/arm-linux-androideabi-strip
elif [[ "neon" = "$1" || "neon_debug" = "$1" ]]; then
	if [[ "neon" = "$1" ]]; then
		SO_NAME=libTxCodec_neon.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_NEON[@]}" --disable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=${APP_OUTPUT_PATH}/${SO_NAME}
	else
		SO_NAME=libTxCodec_neon_obj.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_NEON[@]}" --enable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_SYMBOL_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	fi
	EXTERNAL_LIBS=${EXTERNAL_LIBS_NEON}
	PLAYER_CORE_FFMPEG_LIB_PATH=${PLAYER_CORE_FFMPEG_PATH}/libARMv7
	SO_PATH=${NDK_ARMv7_Bin_Path}
	PLATFORM_PATH=${PLATFORM}
	if [[  "${ANDROID_NDK_VERSION}" = "10" ]]; then
		EXTRA_LD_FLAGS="-z noexecstack"
	else
		EXTRA_LD_FLAGS="-z,noexecstack --warn-once"
	fi
	LIB_GCC=${PREBUILT}/lib/gcc/arm-linux-androideabi/${GCCVER}/libgcc.a
	ANDROID_AR=${PREBUILT}/bin/arm-linux-androideabi-ar
	ANDROID_LD=${PREBUILT}/bin/arm-linux-androideabi-ld
	ANDROID_STRIP=${PREBUILT}/bin/arm-linux-androideabi-strip
elif [[ "arm64" = "$1" || "arm64_debug" = "$1" ]]; then
	if [[ "arm64" = "$1" ]]; then
		SO_NAME=libTxCodec_arm64.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_ARM64[@]}" --disable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	else
		SO_NAME=libTxCodec_arm64_obj.so
		FFMPEG_CONFIG=( "${FFMPEG_CONFIG_COMMON_ARM64[@]}" --enable-debug )
		PLAYER_CORE_OUTPUT_FULL_PATH=${PLAYER_CORE_SYMBOL_OUTPUT_PATH}
		APP_OUTPUT_FULL_PATH=""
	fi
	EXTERNAL_LIBS=${EXTERNAL_LIBS_ARM64}
	PLAYER_CORE_FFMPEG_LIB_PATH=${PLAYER_CORE_FFMPEG_PATH}/libARM64
	SO_PATH=${NDK_ARM64_Bin_Path}
	PLATFORM_PATH=${PLATFORM_ARM64}
	if [[  "${ANDROID_NDK_VERSION}" = "10" ]]; then
		EXTRA_LD_FLAGS="-z noexecstack"
	else
		EXTRA_LD_FLAGS="-z,noexecstack --warn-once"
	fi
	#LIB_GCC=${PREBUILT_ARM64}/lib/gcc/aarch64-linux-android/${GCCVER}/libgcc.a
	ANDROID_AR=${PREBUILT_ARM64}/bin/aarch64-linux-android-ar
	ANDROID_LD=${PREBUILT_ARM64}/bin/aarch64-linux-android-ld
	ANDROID_STRIP=${PREBUILT_ARM64}/bin/aarch64-linux-android-strip
fi

################################################################################
# Start building...
################################################################################
if [[ "rebuild" = "$3" ]]; then
	print_message "==== Start to clean ..."
	make distclean
	print_message "**** Clean done! ****"

	print_message "==== Start to configure ..."
	${FFMPEG_SRC_DIR}/configure "${FFMPEG_CONFIG[@]}" ${FFmpeg_CodecParam}
	check_result $? "configure"
	print_message "**** Configure done! ****"
fi

print_message "==== Start to make ..."
make -j32
check_result $? "make"
print_message "**** Make done! Start to install ..."
make install
cp -f ./config.h ${SO_PATH}/config.h
print_message "**** Install done! Start to link ..."

################################################
## remove the object that cause naming conflict
################################################
#${ANDROID_AR} d libavcodec/libavcodec.a inverse.o

################################################
## Link all static libraries to a single so.
################################################
#${ANDROID_LD} \
#	-rpath-link=${PLATFORM_PATH}/usr/lib -L${PLATFORM_PATH}/usr/lib -L${SO_PATH}/lib  \
#	-shared -nostdlib -Bsymbolic --whole-archive --no-undefined ${EXTRA_LD_FLAGS} \
#	${FFMPEG_OUTPUT_LIBS} \
#	-lc -lm -lz --dynamic-linker=/system/bin/linker \
#	${EXTERNAL_LIBS} \
#	${LIB_GCC} \
#	-soname ${SO_NAME} \
#	-o ${SO_PATH}/${SO_NAME}

#check_result $? "link"
#print_message "**** Link done! ****"

#if [[ "strip" = "$4" ]]; then
#	print_message "==== Start to strip ..."
#	${ANDROID_STRIP} --strip-debug -x ${SO_PATH}/${SO_NAME}
#	print_message "**** Strip done! ****"
#fi

################################################################################
# Copy outputs to the destinations. 
# Due to historica reasons, the destinations are a little over-complicated.
# 1. The include. This this necessary for building PlayerCore. Only copying when
#    rebuild to avoid PlayerCore to be rebuilt every time during development.
# 2. The library, the 1st destination is for PlayerCore building.
# 3. The library, the 2nd destination is for PlayerCore general output.
# 4. The library, the 3rd destination is for the whole APK.
################################################################################
#print_message "== Copying ${SO_PATH}/include to ${PLAYER_CORE_FFMPEG_PATH}/include"
#if [[ ! -d ${PLAYER_CORE_FFMPEG_PATH}/include ]]; then 
#	mkdir -p ${PLAYER_CORE_FFMPEG_PATH}/include
#fi
#cp -fR ${SO_PATH}/include/* ${PLAYER_CORE_FFMPEG_PATH}/include
#
#print_message "== Copying ${SO_PATH}/${SO_NAME} to ${PLAYER_CORE_FFMPEG_LIB_PATH}"
#if [[ ! -f ${PLAYER_CORE_FFMPEG_LIB_PATH} && ! -d ${PLAYER_CORE_FFMPEG_LIB_PATH} ]]; then 
#	mkdir -p ${PLAYER_CORE_FFMPEG_LIB_PATH}
#fi
#cp -f  ${SO_PATH}/${SO_NAME} ${PLAYER_CORE_FFMPEG_LIB_PATH}
#
##We don't need the *.a files currently, so comment it out
##print_message "== Copying ${SO_PATH}/lib/* to ${PLAYER_CORE_FFMPEG_LIB_PATH}"
##cp -Rf  ${SO_PATH}/lib/* ${PLAYER_CORE_FFMPEG_LIB_PATH}
#
#print_message "== Copying ${SO_PATH}/config.h to ${PLAYER_CORE_FFMPEG_LIB_PATH}/inc"
#if [[ ! -d ${PLAYER_CORE_FFMPEG_LIB_PATH}/inc ]]; then 
#	mkdir -p ${PLAYER_CORE_FFMPEG_LIB_PATH}/inc
#fi
#cp -f  ${SO_PATH}/config.h  ${PLAYER_CORE_FFMPEG_LIB_PATH}/inc
#
#print_message "== Copying ${SO_PATH}/${SO_NAME} to ${PLAYER_CORE_OUTPUT_FULL_PATH}"
#if [[ ! -f ${PLAYER_CORE_OUTPUT_FULL_PATH} && ! -d ${PLAYER_CORE_OUTPUT_FULL_PATH} ]]; then
#	mkdir -p ${PLAYER_CORE_OUTPUT_FULL_PATH}
#fi
#cp -f  ${SO_PATH}/${SO_NAME} ${PLAYER_CORE_OUTPUT_FULL_PATH}
#
#if [[ -f ${APP_OUTPUT_FULL_PATH} || -d ${APP_OUTPUT_FULL_PATH} ]]; then
#	print_message "== Copying ${SO_PATH}/${SO_NAME} to ${APP_OUTPUT_FULL_PATH}"
#	cp -f  ${SO_PATH}/${SO_NAME} ${APP_OUTPUT_FULL_PATH}
#fi


cd -
print_message "^-^ Done building ${SO_NAME}!!! ^-^"
echo
