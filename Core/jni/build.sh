#!/bin/bash

################################################################################
# Print a line of information in color red
################################################################################
print_info_in_red(){
    echo -e "\033[31m ${1} \033[0m"
}

################################################################################
# Print a warning
################################################################################
print_error_and_exit(){
    print_info_in_red "${1}!!!"
    exit 1
}

################################################################################
# Check the execution result of the previous command, and exit with 1 if there's
# any error
################################################################################
show_result(){
	if [[ ${1} = 0 ]]; then
        print_info_in_red "== ${2}: successful ^-^"
    else
        print_info_in_red "======================================================"
        print_info_in_red "== ${2}: failed!!!"
        print_info_in_red "======================================================"
        exit 1
    fi
}

################################################################################
# Print help information
################################################################################
print_help_and_exit(){
    print_info_in_red "${1}"
    echo "Usage: ${0} <[min] [full]> [rebuild]"
    echo "min - 编译最小化版本（只支持基本视频格式）"
    echo "full - 编译全格式支持版本"
    echo "rebuild - 全部清空重新编译"
    exit 1
}


################################################################################
# Start the execution flow
################################################################################

# If no parameter, print help info and exit
if [[ $# = 0 ]]; then
    print_help_and_exit
fi

REBUILD="no"
BuildType="min"

# Parse parameters
for var in $*
do
    if [[ $var = "rebuild" ]]; then
        REBUILD="yes"
    elif [[ $var = "min" || $var = "full" ]]; then
        BuildType=$var
    else
    	print_help_and_exit "Invalid parameter:${var}"
    fi
done

if [[ "${REBUILD}" = "yes" ]]; then
	rm -rf ../obj/local
fi

ndk-build -j4 TARGET_PLATFORM=android-9 BUILD_TYPE=${BuildType}
show_result $? "Build all the libraries"

print_info_in_red "====== To install all libraries..."
#
# Copy the release libs to the destinations
#
if [[ ! -d ../libs-${BuildType} ]]; then
	mkdir -p ../libs-${BuildType}
fi
cp -f ../libs/armeabi/libPlayerCore.so     ../libs-${BuildType}/libPlayerCore.so
cp -f ../libs/armeabi-v7a/libPlayerCore.so ../libs-${BuildType}/libPlayerCore_neon.so
if [[ -d ../app_libs ]]; then
	cp -f ../libs-${BuildType}/libPlayerCore_neon.so  ../app_libs/
	cp -f ../libs-${BuildType}/libTxCodec_neon.so     ../app_libs/
fi

#
# Copy the debug libs to the destinations
#
if [[ ! -d ../obj-${BuildType} ]]; then
	mkdir -p ../obj-${BuildType}
fi
cp -f ../obj/local/armeabi/libPlayerCore.so      ../obj-${BuildType}/libPlayerCore.so
cp -f ../obj/local/armeabi-v7a/libPlayerCore.so  ../obj-${BuildType}/libPlayerCore_neon.so

print_info_in_red "====== ALL completed ======"
print_info_in_red "===================================="
