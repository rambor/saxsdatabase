var prGraph;
var prData;
var rmax;
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
	
	c.restore();
	c.font = '12pt sans-serif';	
	c.textBaseline = 'top';
	c.fillText(qmax, 370, 278);
	c.fillText(Math.round(qmax*0.3333333), 125, 278);
	c.fillText(Math.round(qmax*0.6666667), 250, 278);		
		
	//draw the data for the current time slice
	count = 1;
	c.save();
	c.beginPath();
    c.strokeStyle = colors[color];
    c.globalAlpha = 0.5;
    c.lineWidth=4;
	
	for (i=0; i < (cData.length-1); i++){
		startPt = cData[i];
		endPt = cData[i+1];
		c.moveTo(startPt.x, startPt.y);
		c.lineTo(endPt.x, endPt.y);

	}
	c.stroke();	
	
}


$(document).ready(function() {
	createPlot('pofrPlot', "r", "P(r)", pofrData , 10, rmax, false);	
});
