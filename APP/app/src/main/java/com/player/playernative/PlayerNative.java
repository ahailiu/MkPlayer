package com.player.playernative;

import android.net.Uri;
import android.util.Log;
import android.view.Surface;

import java.util.Map;

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

    public PlayerNative() {

    }

    public void setSurface(Surface surface) {

    }

    public void setDataSource(Uri uri) {

    }

    public void setDataSource(Uri uri, Map<String, String> headers) {

    }

    public void setParameter(String[] keys, String[] values) {

    }

    public native void prepareAsync();

    public void prepared() {

    }

    public void start() {

    }

    public void stop() {

    }

    public void pause() {

    }
}
