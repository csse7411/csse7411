package com.officeoccupancy;

import android.app.Service;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorListener;
import android.hardware.SensorManager;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

public class SenseAccelerometer extends Service  implements SensorEventListener {

	SensorManager mSensorManager;
	Sensor accelerometer;
	Sensor magnetometer;
	Float azimut;
	
	float mLastX, mLastY, mLastZ;
	Boolean mInitialized = false;
	final float NOISE = (float) 0.05; 	 

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
	    		//System.out.println("Sending accelerometer data");
	    		 Log.d("debugger", "Reading accelerometer");
	    		 WebRequest webtask = new WebRequest();
				 webtask.execute(new String("ACCL"));
	    	  }		
	     }
	   }	     	  		        	  	 
	}

	@Override
	public void onAccuracyChanged(Sensor arg0, int arg1) {
	
	}


	
    @Override
    public void onCreate() {       
        super.onCreate();
        Log.d("debugger","Service Created");
        mSensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
        accelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        magnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
        mSensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);
    }
 
    @Override
    public void onDestroy() {   
        super.onDestroy();
        mSensorManager.unregisterListener(this);
    	Log.d("debugger","Service Destroyed");
        
    }
 
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
    	Log.d("debugger","Service start command");
    	return super.onStartCommand(intent, flags, startId);
    }

	@Override
	public IBinder onBind(Intent intent) {
    	Log.d("debugger","Service intent");
		return null;
	}
	
	
}