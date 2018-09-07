#ifndef __JniUtil_Header_
#define __JniUtil_Header_

#include <jni.h>

int JNI_EnvInit(JavaVM *vm);
void JNI_EnvDeInit();

JNIEnv* JNI_GetThreadEnv();

#endif
