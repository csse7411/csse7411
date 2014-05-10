#!/bin/bash

#Test hello world
curl http://localhost:3000

#Save Sensor data via POST API call
curl --data "sensortype=zigduino&sensor=pir&value=1" http://localhost:3000/api/sensors

#Get sensor data via GET API call
curl http://localhost:3000/api/sensors
curl hp://localhost:3000/api/sensors?sensortype=zigduino
