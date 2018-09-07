/*
 * =====================================================================================
 *
 *       Filename:  MediaPlayer.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2018年09月07日 22时47分00秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */
#include <android/log.h>
#include "MediaPlayer.h"

static const char *LOG_TAG = "MediaPlayer";

void Player_native_init()
{
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "Player native init.");
    return ;
}
