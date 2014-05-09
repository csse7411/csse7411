var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

router.get('/sensor', function(req, res) {
	console.log("Received get");
	res.send('respond with a resource');
});

router.post('/sensor', function(req, res) {
	console.log(req.body);
	console.log("Received post");
	res.send('respond with a resource');
});

/* RK: Never used, but simply used for completeness */
router.delete('/sensor', function(req, res) {
	console.log("Received post");
	res.send('respond with a resource');
});

router.put('/sensor', function(req, res) {
	console.log("Received post");
	res.send('respond with a resource');
});

module.exports = router;