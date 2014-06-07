var myURL="http://10.0.0.1:4000?";

function ShowProgressAnimation() {
    $("#loading-div-background").show();
} 

function HideProgressAnimation() {
    $("#loading-div-background").hide();
} 

$(document).ready(function(e) {
	 $("#loading-div-background").css({ opacity: 0.8 });

	 $("#sendButton").click(function() {
	 	ShowProgressAnimation();
        $.ajax({
		    url: myURL+"callback=?",
		    data: "graph="+document.getElementById("graph").value+"&zone="+document.getElementById("zone").value+"&sensor="+document.getElementById("sensor").value+"&sensortype="+document.getElementById("sensortype").value+"&startime="+document.getElementById("starttime").value+"&endtime="+document.getElementById("endtime").value,
		    type: 'GET',
		    success: function (resp) {
		    	HideProgressAnimation();		        
		        $("#graphimage").attr('src', 'images/'+resp);
		    },
		    error: function(e) {
		    	HideProgressAnimation();
		        alert('Error: '+e);
		    }  
		});            
     });

    return false;
});

