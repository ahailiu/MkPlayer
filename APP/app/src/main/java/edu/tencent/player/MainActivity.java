package edu.tencent.player;

import android.app.Activity;
import android.os.Bundle;

import com.player.playernative.PlayerNative;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        PlayerNative player = new PlayerNative();
    }
}
