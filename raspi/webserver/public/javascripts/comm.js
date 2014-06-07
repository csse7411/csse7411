var myURL="http://localhost:4000?";

$(document).ready(function(e) {
	 $("#sendButton").click(function() {
        $.ajax({
		    url: myURL+"callback=?",
		    data: "graph="+document.getElementById("graph").value+"&sensor="+document.getElementById("sensor").value+"&sensortype="+document.getElementById("sensortype").value+"&startime="+document.getElementById("starttime").value+"&endtime="+document.getElementById("endtime").value,
		    type: 'GET',
		    success: function (resp) {
		        alert(resp);
		    },
		    error: function(e) {
		        alert('Error: '+e);
		    }  
		});            
     });

    return false;
});

