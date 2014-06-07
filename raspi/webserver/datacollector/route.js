/* APIs for data collector */
var express = require('express');
var router = express.Router();
var mongoose = require( 'mongoose' );
var sensor = mongoose.model('Sensor');

/* RK: GET default home page */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

/* RK: GET sensor data with optional parameters*/
router.get('/sensors', function(req, res) {
	console.log("Received get sensors");
	console.log(req.query);
	sensor.find(req.query, 'timestamp sensortype sensor value', function(err, readsensor) {
		res.send(readsensor);
	});
});

/* RK: Post data to be saved */
router.post('/sensors', function(req, res) {
	if ( typeof req.body.sensortype != 'undefined' && typeof req.body.sensor != 'undefined' && typeof req.body.value != 'undefined') {
		new sensor({
			timestamp: Date.now(),
	    	sensortype: req.body.sensortype,
	    	sensor: req.body.sensor,
	    	value: req.body.value,
		}).save( function( err, todo, count ){
			console.log("Received post from :"+req.body.sensortype+" Sensor:"+req.body.sensor);
		    res.send('Saved');
		});
	}
	else {
		res.send('Unsaved');
	}
});

/* RK: Never used, but simply written for completeness */
router.delete('/sensors', function(req, res) {
	console.log("Received delete request\r\n");
	res.send('Not implemented');
});

router.put('/sensors', function(req, res) {
	console.log("Received put request\r\n");
	res.send('Not implemented');
});

module.exports = router;