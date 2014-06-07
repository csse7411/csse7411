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


/**
 * Calculates zero crossings to estimate frequency
 * @author Greg Milette &#60;<a href="mailto:gregorym@gmail.com">gregorym@gmail.com</a>&#62;
 */
public class ZeroCrossing
{
    private static final String TAG = "ZeroCrossing.java";
    
    /**
     * calculate frequency using zero crossings
     */
    public static int calculate(int sampleRate, short [] audioData)
    {
        int numSamples = audioData.length;
        int numCrossing = 0;
        int i;      
        float numSecondsRecorded = (float)numSamples/(float)sampleRate;
        float numCycles;
        float frequency;

        for (i = 1; i < audioData.length; i++) {
        	if (audioData[i] > 0 && audioData[i-1] <= 0)
        		numCrossing++;
        	else if (audioData[i] < 0 && audioData[i - 1] >=0)
        		numCrossing++;
        }
        numCycles = numCrossing/2;
        frequency = numCycles/numSecondsRecorded;
        return (int)frequency;
    }
}
