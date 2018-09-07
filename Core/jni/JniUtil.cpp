#include <stdio.h>
#include <pthread.h>
#include <android/log.h>
#include "JniUtil.h"

static const char*	LOG_TAG = "JNI_Util";

static pthread_key_t g_key;
static JavaVM		 *g_jvm	= NULL;

static void _detachCurrentThread(void *arg)
{
    if (arg) {
        JNIEnv* env = NULL;
        if (JNI_OK == g_jvm->GetEnv(reinterpret_cast<void**> (&env), JNI_VERSION_1_4)) {
            jint ret = g_jvm->DetachCurrentThread();
            __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JVM DetachCurrentThread return:%d, tid:%lu.\n", ret, pthread_self());

            return ;
        }
    }

    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JVM DetachCurrentThread err, tid:%lu\n", pthread_self());
}

int JNI_EnvInit(JavaVM *vm)
{
    if (vm == NULL)
        return -1;

    if (pthread_key_create(&g_key, _detachCurrentThread) != 0)
        return -1;

    g_jvm = vm;
    return 0;
}

void JNI_EnvDeInit()
{
    pthread_key_delete(g_key);
    return ;
}

JNIEnv* JNI_GetThreadEnv()
{
    JNIEnv* env = NULL;
    jint ret = g_jvm->GetEnv(reinterpret_cast<void**> (&env), JNI_VERSION_1_4);
    switch (ret) {
        case JNI_OK:
            break;
        case JNI_EDETACHED:
            if (JNI_OK != g_jvm->AttachCurrentThread(&env, NULL)) {
                env = NULL;
                __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "JVM JNI AttachCurrentThread Err.\n");
                break;
            }

            __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "JVM JNI AttachCurrentThread ok, tid:%lu.\n", pthread_self());
            pthread_setspecific(g_key, env);
            break;
        default:
            __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "JVM JNI GetEnv Err.\n");
            break;
    }

    return env;
}
