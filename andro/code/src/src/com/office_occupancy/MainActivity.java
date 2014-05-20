package com.office_occupancy;


/*
 * Copyright 2012 Greg Milette and Adam Stroud
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * 		http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.util.ArrayList;
import java.util.List;

import com.CSSE4011.Lab7.R;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

public class MainActivity extends Activity implements SensorEventListener 
{
    private static final String TAG = "AndroidBot";
    
    private TextView log;
    private TextView status;   
    private RecordAudioTask recordAudioTask; 
    
	private SensorManager mSensorManager;
	Sensor accelerometer;
	Sensor magnetometer;
	Float azimut;
	Context context;
	private float mLastX, mLastY, mLastZ;
	private Boolean mInitialized = false;
	private final float NOISE = (float) 0.05; 

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audio_layout);
        //test file io
        hookButtons();
        mSensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
        accelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        magnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
    }
    
    private void hookButtons()
    {
        log = (TextView)findViewById(R.id.tv_resultlog);
        
        status = (TextView)findViewById(R.id.tv_recording_status);
              
        Button pitch = (Button)findViewById(R.id.btn_audio_pitch_startstop);
        pitch.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                startTask(createAudioLogger(), "Audio Logger");
            }
        });
     
        findViewById(R.id.btn_audio_stopall).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                stopAll();
            }
        });

    }
    private void stopAll()
    {
        Log.d(TAG, "stop record audio");
        shutDownTaskIfNecessary(recordAudioTask);
    }
    
    private void shutDownTaskIfNecessary(final AsyncTask task)
    {
        if ( (task != null) && (!task.isCancelled()))
        {
            if ((task.getStatus().equals(AsyncTask.Status.RUNNING))
                    || (task.getStatus()
                            .equals(AsyncTask.Status.PENDING)))
            {
                Log.d(TAG, "CANCEL " + task.getClass().getSimpleName());
                task.cancel(true);
            }
            else
            {
                Log.d(TAG, "task not running");
            }
        }
    }
    
    @TargetApi(Build.VERSION_CODES.HONEYCOMB) // API 11
    private void startTask(AudioClipListener detector, String name)
    {
        stopAll();
        
        recordAudioTask = new RecordAudioTask(MainActivity.this, status, log, name);
        //wrap the detector to show some output
        List<AudioClipListener> observers = new ArrayList<AudioClipListener>();
        observers.add(new AudioClipLogWrapper(log, this));
        OneDetectorManyObservers wrapped = 
            new OneDetectorManyObservers(detector, observers);
        //recordAudioTask.execute(wrapped);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
        	recordAudioTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, wrapped);
        else
        	recordAudioTask.execute(wrapped);
    }

    private AudioClipListener createAudioLogger()
    {
        AudioClipListener audioLogger = new AudioClipListener()
        {
            @Override
            public boolean heard(short[] audioData, int sampleRate)
            {
                if (audioData == null || audioData.length == 0)
                {
                    return true;
                }
                
                // returning false means the recording won't be stopped
                // users have to manually stop it via the stop button
                return false;
            }
        };
        
        return audioLogger;
    }

    @Override
    protected void onPause()
    {
        stopAll();
        super.onPause();
        mSensorManager.unregisterListener(this);
    }
    
    @Override
	protected void onResume() {
	    super.onResume();
	 
	    // for the system's orientation sensor registered listeners
	    mSensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_UI);
	    mSensorManager.registerListener(this, magnetometer, SensorManager.SENSOR_DELAY_UI);
	}
    
    @Override
	  public void onSensorChanged(SensorEvent event) {
		float x, y, z, deltaX, deltaY, deltaZ;
		
	    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
	      x = event.values[0];
	      y = event.values[1];
	      z = event.values[2];
	      if (!mInitialized) {
	    	  mLastX = x;
	    	  mLastY = y;
	    	  mLastZ = z;
	    	  mInitialized = true;
	      }
	      else {
	    	  deltaX = Math.abs(mLastX - x);
	    	  deltaY = Math.abs(mLastY - y);
	    	  deltaZ = Math.abs(mLastZ - z);
	    	  
	    	  if (deltaX < NOISE) deltaX = (float)0.0;
	    	  if (deltaY < NOISE) deltaY = (float)0.0;
	    	  if (deltaZ < NOISE) deltaZ = (float)0.0;
	    	  mLastX = x;
	    	  mLastY = y;
	    	  mLastZ = z;
	    	  if (Math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ)) > 0) {
	    		System.out.println("Sending accelerometer data");
	    		new Httprequest().execute("accelero");
	    		//new Httprequest().postData("sound");
	     	  }
	    	// System.out.println("Change: " + Math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ)));
	      }
	    }	     	  		        	  	 
	  }

	@Override
	public void onAccuracyChanged(Sensor arg0, int arg1) {
		// TODO Auto-generated method stub
		
	}
}

