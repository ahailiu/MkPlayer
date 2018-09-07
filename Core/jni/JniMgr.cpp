/*
 * =====================================================================================
 *
 *       Filename:  JniMgr.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2018年09月07日 22时32分08秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */
#include <jni.h>
#include <android/log.h>
#include <stdint.h>

#include "JniMgr.h"
#include "JniUtil.h"
#include "MediaPlayer.h"

#ifdef JNI_VERSION_1_4
#define JNI_VER JNI_VERSION_1_4
#endif
// JDK 1.5 used JNI_VERSION 1.4!  But, just in case, keep it here.
#ifdef JNI_VERSION_1_5
#undef JNI_VER
#define JNI_VER JNI_VERSION_1_5
#endif
#ifdef JNI_VERSION_1_6
#undef JNI_VER
#define JNI_VER JNI_VERSION_1_6
#endif


static const char *LOG_TAG = "JniMgr";
static const char *gPlayerClass = "com/player/playernative/PlayerNative";

static JNINativeMethod gPlayerMethods[] = {
    { "native_init", "()V", (void *)Player_native_init},
};

static int _JNI_Init(JavaVM *vm)
{
    JNI_EnvInit(vm);

    JNIEnv *env = JNI_GetThreadEnv();

    //注册播放器的native方法
    jclass playerCls = env->FindClass(gPlayerClass);
    if (playerCls == NULL) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "Native registration unable to find class '%s'", gPlayerClass);
        return -1;
    }

    if(env->RegisterNatives(playerCls, gPlayerMethods, sizeof(gPlayerMethods)/sizeof(gPlayerMethods[0])) != 0) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "Register player methods failed");
        return -1;
    }

    return 0;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    if (_JNI_Init(vm) < 0) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "JNI OnLoad err." );
        return JNI_ERR;
    }

    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JNI OnLoad ok." );
    return JNI_VER;
}

JNIEXPORT void JNICALL JNI_UnLoad(JavaVM *vm, void *reserved)
{
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JNI UnLoad err." );
    return ; 
}
