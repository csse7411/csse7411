package com.office_occupancy;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;

//import android.app.Activity;
//import android.os.Bundle;
import android.os.Environment;

public class FileIO {
	private String filename;
	private File sdCard;
	private File dir;
	
	public FileIO(String path, String filename){
		this.filename = filename;
		sdCard = Environment.getExternalStorageDirectory();
	    dir = new File (sdCard.getAbsolutePath()+path);
	    dir.mkdirs();

	}

public void writeToFile(String s){
    File file = new File(dir,this.filename);
    try {
        FileOutputStream f = new FileOutputStream(file,true); //True = Append to file, false = Overwrite
        PrintStream p = new PrintStream(f);
        p.print(s);
        p.close();
        f.close();


    } catch (FileNotFoundException e) {
        e.printStackTrace();
        System.out.printf("\nFile not found. Make sure to add WRITE_EXTERNAL_STORAGE permission to the manifest");
    } catch (IOException e) {
        e.printStackTrace();
    }   
}
}