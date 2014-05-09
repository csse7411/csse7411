/* Define Schema */
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Sensor = new Schema({
	timestamp: { type : Date, default: Date.now },
	sensortype : String,
	sensor : String,
	value : Number
});

mongoose.model('Sensor', Sensor);