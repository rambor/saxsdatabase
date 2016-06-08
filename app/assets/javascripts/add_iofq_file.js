var iofqGraph;
var iofqData;
var kratkyGraph;
var kratkyData = new Array();
var qmax;
var xPadding=30;
var yPadding=30;
var radian = 1.5707963267948966;

//plot function (id, x-label, y-label, cdata, color, qmax, imax)
function createPlot(plotId, xLabel, yLabel, cData, color, qmax, thirdColumn){
    var graph = $('#'+plotId);
	var c = graph[0].getContext('2d');
	var n = cData.length;
	c.lineWidth = 2;
	c.strokeStyle = '#333';
	c.font = '14pt sans-serif';
	c.textAlign = "center";
	// fitGraph Axis
	c.beginPath();
	c.moveTo(xPadding, 0);
	c.lineTo(xPadding, graph.height() - yPadding);
	c.lineTo(graph.width()-10, graph.height() - yPadding);
   // Ticks (x,y)
	c.moveTo(375,265);
	c.lineTo(375,275);
	c.moveTo(250,265);
	c.lineTo(250,275);	
	c.moveTo(125,265);
	c.lineTo(125,275);
	
	c.moveTo(20,1);
	c.lineTo(40,1);
	
	c.stroke();
	// add text, needs to be last to overlap graph
	c.textBaseline = 'top';
	c.fillText(xLabel, 200, 275);
	c.save();
	
	c.rotate(-radian);
	c.fillText(yLabel, -135, 2);
	
	if (plotId == 'kratky'){	
	   c.font = '10pt sans-serif';	
	   c.fillText("2",-150, 0);
    }

	c.restore();
	c.font = '12pt sans-serif';	
	c.textBaseline = 'top';
	c.fillText(qmax, 370, 278);
	c.fillText((qmax*0.3333333).toFixed(2), 125, 278);
	c.fillText((qmax*0.6666667).toFixed(2), 250, 278);		
		
	//draw the data for the current time slice
    cData.forEach(function(d) {
	  if ((typeof d.x == "number")&&(typeof d.y == "number")&&(d.y != 102872)) {
        c.save();
        c.fillStyle = colors[color];
        c.globalAlpha = 0.5;
        c.beginPath();
        c.arc(d.x,d.y,3.4,0,Math.PI*2);
        c.fill();
        c.restore();
      } else if ((d.x == 102872) && (d.y == 102872)) {
	    color = color + 1;
      }
    });
}


$(document).ready(function() {
	createPlot('iofqPlot', "q", "log I(q)", iofqData , 0, qmax, false);	
	createPlot('kratkyPlot', "q", "q  * I(q)", kratkyData , 0, qmax, false);	
});
