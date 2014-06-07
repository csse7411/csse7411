package com.officeoccupancy;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import android.os.AsyncTask;

public class WebRequest extends AsyncTask<String, Void, String> {
    @Override
    protected String doInBackground(String ...aSensor) {
      HttpClient httpclient = new DefaultHttpClient();
      HttpPost httppost = new HttpPost("http://192.168.0.6:3000/api/sensors");
      String downloadedString;
	    //add data
	    try{
	        List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(3);
	        nameValuePairs.add(new BasicNameValuePair("sensortype", "android1"));
	        nameValuePairs.add(new BasicNameValuePair("sensor", aSensor[0]));
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
	    return "Test";
    }

    @Override
    protected void onPostExecute(String result) {
      
    }
  }