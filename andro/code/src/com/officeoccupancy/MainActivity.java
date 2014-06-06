package com.officeoccupancy;

import java.util.ArrayList;
import java.util.List;

import com.example.officeoccupancy.R;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity  extends Activity {
	
	Button btStart, btStop;
	TextView txtLog, txtStatus;	
    private RecordAudioTask recordAudioTask; 
	
	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);
        btStart = (Button) findViewById(R.id.btStart);
		btStop = (Button) findViewById(R.id.btStop);
		txtLog = (TextView) findViewById(R.id.txtLog);
		txtStatus = (TextView) findViewById(R.id.txtStatus);		
        addListenerOnButton();       
    }
    
    @Override
    protected void onPause()
    {
        super.onPause();
    }
    
    /** Listen for click on buttons */
    public void addListenerOnButton() {
		btStart.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) { 		
				txtStatus.setText("Start Logging");
				Intent accelIntent = new Intent(getApplicationContext(), SenseAccelerometer.class);
				startService(accelIntent);		       
				startTask(createAudioLogger(), "Audio Logger");
				txtLog.setText("Start Logging\n" + txtLog.getText());				
			}
		});
		btStop.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) { 					
				txtStatus.setText("Stop Logging");			
				Intent accelIntent = new Intent(MainActivity.this, SenseAccelerometer.class);
				stopService(accelIntent);
				stopAll();
			}
		});
	}
    
    private void shutDownTaskIfNecessary(final AsyncTask task)
    {
        if ( (task != null) && (!task.isCancelled()))
        {
            if ((task.getStatus().equals(AsyncTask.Status.RUNNING))
                    || (task.getStatus()
                            .equals(AsyncTask.Status.PENDING)))
            {
                Log.d("office_occupancy", "CANCEL " + task.getClass().getSimpleName());
                task.cancel(true);
            }
            else
            {
                Log.d("office_occupancy", "task not running");
            }
        }
    }
    
    @TargetApi(Build.VERSION_CODES.HONEYCOMB) // API 11
    private void startTask(AudioClipListener detector, String name)
    {
        stopAll();
        
        recordAudioTask = new RecordAudioTask(MainActivity.this, txtStatus, txtLog, name);
        //wrap the detector to show some output
        List<AudioClipListener> observers = new ArrayList<AudioClipListener>();
        observers.add(new AudioClipLogWrapper(txtLog, this));
        OneDetectorManyObservers wrapped = 
            new OneDetectorManyObservers(detector, observers);
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
    private void stopAll()
    {
        Log.d("office_occupancy", "stop record audio");
        shutDownTaskIfNecessary(recordAudioTask);
    }
}
