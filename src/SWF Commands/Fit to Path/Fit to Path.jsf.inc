var dom = fw.getDocumentDOM();

Point = function(x, y){
	return {x:x, y:y};
}
SubtractPoints = function(p1, p2){
	return {x:p1.x-p2.x, y:p1.y-p2.y};
}
AddPoints = function(p1, p2){
	return {x:p1.x+p2.x, y:p1.y+p2.y};
}
PointDividePoint = function(p1, p2){
	return {x:p1.x/p2.x, y:p1.y/p2.y};
}
PointMultiplyPoint = function(p1, p2){
	return {x:p1.x*p2.x, y:p1.y*p2.y};
}
SelectElement = function(name){
	dom.setElementVisibleByName(name, false);
	dom.setElementVisibleByName(name, true);
}
FitToPath = function(order, reverse, rotate, offset, transAtts){
	var path = fw.selection[order[0]];
	var img = fw.selection[order[1]];
	var contour = 0; // 0 - contours.length-1 - IF contour has 4 nodes ^ check other contours in if
	var n = path.contours[contour].nodes;
	if (offset > n.length-4) offset = n.length-4;
	
	var origName = img.name;
	img.name = "__PROGRAMMATIC_SELECT__";
	SelectElement("__PROGRAMMATIC_SELECT__");
	img.name = origName;
	dom.cloneSelection();
	
	var pos = Point(img.left, img.top);
	
	if (img.width > img.height){
		var max = img.width;
		var min = img.height;
		pos = AddPoints(pos, Point(0, (min-max)/2));
	}else{
		var max = img.height;
		var min = img.width;
		pos = AddPoints(pos, Point((min-max)/2, 0));
	}
	
	var size = Point(max, max);
	var p = [
		PointDividePoint(SubtractPoints(n[offset], pos), size),
		PointDividePoint(SubtractPoints(n[offset+1], pos), size),
		PointDividePoint(SubtractPoints(n[offset+2], pos), size),
		PointDividePoint(SubtractPoints(n[offset+3], pos), size),
	];
	if (reverse) p.reverse();
	if (rotate < 0) rotate = 0;
	while(rotate--) p.push(p.shift());
	var opts = (transAtts) ? "autoTrimImages transformAttributes" : "autoTrimImages";
	dom.setQuadrangle(
		p[0],
		p[1],
		p[2],
		p[3],
		opts
	);
}