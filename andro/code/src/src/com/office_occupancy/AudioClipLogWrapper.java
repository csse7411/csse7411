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
package com.office_occupancy;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.text.format.DateFormat;
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
        		System.out.println("Sending Volume sensor");
        		this.postData("sound");
       	  	 	//(new Httprequest()).send("sound");
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
    
    public void postData(String aString) {
		// Create a new HttpClient and Post Header
	    String downloadedString= null;

	    HttpClient httpclient = new DefaultHttpClient();


	    //for registerhttps://te
	    HttpPost httppost = new HttpPost("http://10.0.0.1:3000/api/sensors");
	    //add data
	    try{
	        List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(3);
	        nameValuePairs.add(new BasicNameValuePair("sensortype", "andro"));
	        nameValuePairs.add(new BasicNameValuePair("sensor", aString ));
	        nameValuePairs.add(new BasicNameValuePair("value", "1"));
	        
	        //add data
	        httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

	        // Execute HTTP Post Request
	        HttpResponse response = httpclient.execute(httppost);

	        InputStream in = response.getEntity().getContent();
	        StringBuilder stringbuilder = new StringBuilder();
	        BufferedReader bfrd = new BufferedReader(new InputStreamReader(in),1024);
	        String line;
	        while((line = bfrd.readLine()) != null)
	            stringbuilder.append(line);

	        downloadedString = stringbuilder.toString();
	        System.out.println("Downloaded String::"+downloadedString);
	    } catch (Exception ex) {	   
	        ex.printStackTrace();
	    }
	   
	}
}
