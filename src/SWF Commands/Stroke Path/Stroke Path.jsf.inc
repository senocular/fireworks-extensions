var dom = fw.getDocumentDOM();
var toDeg = 180/Math.PI;
var __originalDuplicateName;

main = function(spacing, orient, reverse, a, order){
	if (arguments.length != 5) return (0);
	var selnodes = ValidSelection(order);
	if (selnodes){
		
		if (reverse) selnodes = selnodes.reverse();
		
		// point finding
		if (a < 1) a = 1;
		else a = 1/a;
		var t, i, snlen = selnodes.length;
		var s, e = selnodes[0];
		var lastpt, pt = 0;
		
		// interpolation
		var tots = 0, srem = 0, lrem = 0;
		var span, divs, d,  empt = false;
		var rot = 0;
	
		for (i=1; i<snlen; i++){ // for all nodes
			s = e;
			e = selnodes[i];
			t =  0;
			while(t <= 1){ // for all divisions in accuracy
				lastpt = pt;
				if (reverse)  pt = BezierPosition(s.x, s.y, s.predX, s.predY, e.succX, e.succY, e.x, e.y, t);
				else pt = BezierPosition(s.x, s.y, s.succX, s.succY, e.predX, e.predY, e.x, e.y, t);
				if (lastpt){ // interpolate
					span = DistanceBetween(lastpt,pt);
					if (orient) rot = AngleBetween(lastpt, pt)*toDeg;
					if (srem){
						if (srem < span){
							tots = srem;
							AddElement(PositionBetweenPercent(lastpt,pt, tots/span), rot);
							lrem = span-tots;
						}else{
							srem -= span;
							empt = true;
						}		
					}else{
						lrem = span;
						tots = 0;
						AddElement(PositionBetweenPercent(lastpt,pt, 0), rot);
					}
					if (!empt){
						divs = Math.floor(lrem/spacing);
						if (divs){
							for (d=1; d<=divs; d++){
								tots += spacing;
								AddElement(PositionBetweenPercent(lastpt,pt, tots/span), rot);
							}
						}
						srem = spacing-(span-tots);
					}else empt = false;
				}
				t += a;
			}
		}
		SelectElement("__DUPLICATE_ALONG_PATH__");
		fw.selection[0].name = __originalDuplicateName;
	}
}

ValidSelection = function(order){
	if (fw.selection.length == 2 && fw.selection[order[0]].__proto__ == Path.prototype && fw.selection[order[0]].contours.length){
		var n_array =(new Array()).concat(fw.selection[order[0]].contours[0].nodes);
		if (fw.selection[order[0]].contours[0].isClosed){
			n_array.push(n_array[0]);
		}
		__originalDuplicateName = fw.selection[order[1]].name;
		fw.selection[order[1]].name = "__DUPLICATE_ALONG_PATH__";
		SelectElement("__DUPLICATE_ALONG_PATH__");
		return n_array;
	}else{
		return false;
	}
}

AddElement = function(pt, rot){
	SelectElement("__DUPLICATE_ALONG_PATH__");
	dom.moveSelectionTo(SubtractPoints(pt, Point(fw.selection[0].width/2,fw.selection[0].height/2)), true, false);
	fw.selection[0].name = __originalDuplicateName;
	if (rot) dom.rotateSelection(rot, "autoTrimImages");
}

BezierPosition = function(b0x, b0y, b1x, b1y, b2x, b2y, b3x, b3y, t){
	var t2 = t*t;
	var t3 = t2*t;
	var i = 1-t;
	var i2 = i*i;
	var i3 = i2*i;
	var ti3 = t*i2*3;
	var it3 = i*t2*3;
	return {
		x: i3*b0x + ti3*b1x + it3*b2x + t3*b3x,
		y: i3*b0y + ti3*b1y + it3*b2y + t3*b3y
	};
}
Point = function(x,y){
	return {x:x, y:y};
}
SubtractPoints = function(p1, p2){
	return {x:p1.x-p2.x, y:p1.y-p2.y};
}
DistanceBetween = function(p1,p2){
	var dx = p2.x - p1.x;
	var dy = p2.y - p1.y;
	return Math.sqrt(dx*dx + dy*dy);
}
AngleBetween = function(p1,p2){
	return Math.atan2(p2.y - p1.y, p2.x - p1.x);
}
PositionBetweenPercent = function(p1,p2, p){
	return {x: p1.x + (p2.x - p1.x)*p, y: p1.y + (p2.y - p1.y)*p};
}

SelectElement = function(name){
	dom.setElementVisibleByName(name, false);
	dom.setElementVisibleByName(name, true);
}
