package com.player.playernative;

import android.util.Log;

/**
 * Created by ahailiu-MC1 on 2018/9/7.
 */

public class PlayerNative {
    static final private String TAG = "PlayerNative";

    static {
        try {
            System.loadLibrary("PlayerCore_neon");
        } catch (SecurityException | UnsatisfiedLinkError | NullPointerException e) {
            Log.e(TAG, e.toString());
        }

        native_init();
    }

    private long mNativeContext;

    private static native final void native_init();
}
