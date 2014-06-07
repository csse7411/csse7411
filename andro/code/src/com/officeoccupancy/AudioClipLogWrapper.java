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
package com.officeoccupancy;

import android.app.Activity;
import android.util.Log;
import android.widget.TextView;

public class AudioClipLogWrapper implements AudioClipListener
{
    private TextView log;

    private Activity context;
    
    private double previousFrequency = -1;
    
    private FileIO fileIO;

    int prevVol, prevAmp, prevFrq;
    Boolean audioPrev = false;
    
    public AudioClipLogWrapper(TextView log, Activity context)
    {
        this.log = log;
        this.context = context;               
    }

    @Override
    public boolean heard(short[] audioData, int sampleRate)
    {
    	    	
    	final double freq = ZeroCrossing.calculate(sampleRate, audioData);    	
        final int maxAmplitude = AudioUtil.getMaxValue(audioData);
        final double volume = AudioUtil.rootMeanSquared(audioData);
        
        
        final StringBuilder message = new StringBuilder();
        message.append(" rms: ").append((int)volume);      
        message.append(" max: ").append((int)maxAmplitude);
        message.append(" freq: ").append((int)freq);        
        
        if (audioPrev) {
        	if (volume > 1.3 * prevVol && maxAmplitude > 1.3 * prevAmp) {
        		Log.d("Debugger","Sending Volume sensor");
        		WebRequest webtask = new WebRequest();
				webtask.execute(new String("VC"));
        		try {
        			Thread.sleep(10);
        		} catch (Exception ex) {
        			
        		}
        	}
        }
        
        prevVol = (int) volume;
        prevAmp = (int) maxAmplitude;
        prevFrq = (int) freq;
        audioPrev = true;
        
        context.runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
               AudioTaskUtil.appendToStartOfLog(log, message.toString());
             }
        });    

        return false;
    }
    
}
