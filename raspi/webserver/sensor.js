var mongoose = require('mongoose')

module.exports = mongoose.model('Sensor', {
	type: String,
	value: Number
});
