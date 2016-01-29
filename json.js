'use strict';
module.exports = {
	reporter: function (result) {
		result.forEach(function (r) {
			delete r.error['evidence']
		})
		console.log(JSON.stringify({
			result: result
		}));
	}
};
