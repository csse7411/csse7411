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

import android.os.AsyncTask;

public class Httprequest extends AsyncTask<String, Integer, Double> {

		@Override
		protected Double doInBackground(String... params) {
			// TODO Auto-generated method stub
			postData(params[0]);
			return null;
		}
		 
		protected void onPostExecute(Double result){
			// pb.setVisibility(View.GONE);
			//Toast.makeText(getApplicationContext(), "command sent", Toast.LENGTH_LONG).show();
		}
		protected void onProgressUpdate(Integer... progress){
			//pb.setProgress(progress[0]);
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