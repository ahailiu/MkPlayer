#include <jni.h>
#include <android/log.h>
#include <stdint.h>

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

static const char *LOG_TAG  = "PlayerCore";

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JNI OnLoad ok." );
    return JNI_VER;
}

JNIEXPORT void JNICALL JNI_UnLoad(JavaVM *vm, void *reserved)
{
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JNI UnLoad err." );
    return ; 
}
