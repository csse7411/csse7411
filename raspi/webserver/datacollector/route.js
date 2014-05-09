var express = require('express');
var router = express.Router();
var mongoose = require( 'mongoose' );
var sensor = mongoose.model('Sensor');

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

router.get('/sensor', function(req, res) {
	console.log("Received get");
	res.send('respond with a resource\r\n');
});

router.post('/sensor', function(req, res) {
	console.log(req.body);
	console.log("Received post");
	new Sensor({
		timestamp: Date.now(),
    	sensortype: req.body.sensortype,
    	sensor: req.body.sensor,
    	value: req.body.value,
	}).save( function( err, todo, count ){
	    res.redirect( '/' );
	});
	res.send('respond with a resource\r\n');
});

/* RK: Never used, but simply written for completeness */
router.delete('/sensor', function(req, res) {
	console.log("Received delete request\r\n");
	res.send('Not implemented');
});

router.put('/sensor', function(req, res) {
	console.log("Received put request\r\n");
	res.send('Not implemented');
});

module.exports = router;