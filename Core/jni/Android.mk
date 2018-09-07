LOCAL_PATH := $(call my-dir)

FFMPEG_DIR = libFFmpeg-$(BUILD_TYPE)

#==============================================================
# Prebuild library for libgcc.a
#==============================================================
include $(CLEAR_VARS)
ifeq ($(BUILD_OS),linux)
OS_NAME=linux
else
OS_NAME=darwin
endif

#==============================================================
# Prebuild library for ffmpeg
#==============================================================
include $(CLEAR_VARS)
LOCAL_MODULE := avformat
LOCAL_SRC_FILES := $(LOCAL_PATH)/../$(FFMPEG_DIR)/lib/libavformat.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avcodec
LOCAL_SRC_FILES := $(LOCAL_PATH)/../$(FFMPEG_DIR)/lib/libavcodec.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swscale
LOCAL_SRC_FILES := $(LOCAL_PATH)/../$(FFMPEG_DIR)/lib/libswscale.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swsresample
LOCAL_SRC_FILES := $(LOCAL_PATH)/../$(FFMPEG_DIR)/lib/libswresample.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avutil
LOCAL_SRC_FILES := $(LOCAL_PATH)/../$(FFMPEG_DIR)/lib/libavutil.a
include $(PREBUILT_STATIC_LIBRARY)

#==============================================================
# Dynamic library for libPlayerCore.so
#==============================================================
include $(CLEAR_VARS)

FFMPEG_DIR := $(LOCAL_PATH)/../$(FFMPEG_DIR)

LOCAL_MODULE := PlayerCore

LOCAL_CFLAGS += -O3 -DANDROID
LOCAL_CFLAGS += -DPOSIX -D_POSIX_THREADS -DHAVE_PTHREADS -D__STDC_FORMAT_MACROS
LOCAL_CFLAGS += -D__ENABLE_LOG
LOCAL_CFLAGS += -fvisibility=hidden
ifeq ($(FFMPEG_VER), 1.2.1)
	LOCAL_CFLAGS += -DFFMPEG_1_2_1
else ifeq ($(FFMPEG_VER), 2.2.3)
	LOCAL_CFLAGS += -DFFMPEG_2_2_3
else ifeq ($(FFMPEG_VER), 3.2.2)
	LOCAL_CFLAGS += -DFFMPEG_3_2_2
else ifeq ($(FFMPEG_VER), 3.3.2)
        LOCAL_CFLAGS += -DFFMPEG_3_3_2
endif

ifeq ($(NDK_PROFILE),true)
LOCAL_CFLAG += -pg
endif

ifeq ($(TARGET_ARCH), arm)
#	LOCAL_CFLAGS += -march=armv5
	LOCAL_ARM_MODE := arm
#	LOCAL_CFLAGS += -march=armv6 -mfloat-abi=softfp -mfpu=neon
endif

LOCAL_SRC_FILES := \
	JniMgr.cpp \
	JniUtil.cpp \
	MediaPlayer.cpp
	
LOCAL_C_INCLUDES := \
	$(JNI_H_INCLUDE)						    \
	$(LOCAL_PATH)/$(FFMPEG_DIR)/include			\
	$(LOCAL_PATH)/inc

# No specia compiler flags.
LOCAL_CFLAGS += -fexceptions -Wno-deprecated-declarations
LOCAL_LDFLAGS += -fuse-ld=bfd

# Link libs (ex logs)
ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_LDLIBS := -lm -llog -lz -lEGL -lGLESv2 -lGLESv1_CM -landroid
LOCAL_WHOLE_STATIC_LIBRARIES += avformat avcodec swscale swresample avutil
endif

ifeq ($(TARGET_ARCH_ABI),armeabi)
LOCAL_LDLIBS := -lm -llog -lz -lEGL -lGLESv2 -lGLESv1_CM -landroid
LOCAL_WHOLE_STATIC_LIBRARIES += avformat avcodec swscale swresample avutil
endif


# Don't prelink this library.  For more efficient code, you may want
# to add this library to the prelink map and set this to true.
LOCAL_PRELINK_MODULE := true

include $(BUILD_SHARED_LIBRARY)
$(call import-add-path,$(LOCAL_PATH))
