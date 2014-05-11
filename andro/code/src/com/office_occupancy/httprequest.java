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

public class httprequest {

		public static void send(String aString) {
		// Create a new HttpClient and Post Header
	    String downloadedString= null;

	    HttpClient httpclient = new DefaultHttpClient();


	    //for registerhttps://te
	    HttpPost httppost = new HttpPost("http://localhost:3000/api/sensors");
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

	    } catch (Exception ex) {	   
	        ex.printStackTrace();
	    }
	    System.out.println("downloadedString:in login:::"+downloadedString);
	}
}