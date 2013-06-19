var dom = fw.getDocumentDOM();
var elems = dom.layers[dom.currentLayerNum].frames[dom.currentFrameNum].elements;
var arrangement = new Array(); // single values to be compared (ie top OR left, not a point)
var submittedRotation;

SetSelection = function(f,l,e){
	dom.setElementVisible(f, l, e, false);
	dom.setElementVisible(f, l, e, true);
}
MoveElementFromTo = function(from, to){
	SetSelection(-1,-1,from);
	if (!to) to = -1;
	dom.moveSelectionToLayer(dom.currentLayerNum, false, "none", to);
}
MoveArrayItemFromTo = function(ary, from, to){
	ary.splice(to,0,ary.splice(from,1)[0]);
}
MoveFromTo = function(from, to){
	MoveElementFromTo(from, to);
	MoveArrayItemFromTo(arrangement, from, to);
}
Sort = function(reverse){
	var i,ii,sel,a,b,L = arrangement.length;
	for (i=0; i<L; i++){
		sel = i;
		if (reverse){
			for (ii=i+1; ii<L; ii++) if (arrangement[ii] < arrangement[sel]) sel = ii;
		}else{
			for (ii=i+1; ii<L; ii++) if (arrangement[ii] > arrangement[sel]) sel = ii;
		}
		MoveFromTo(sel, i);
	}
}
GetElementBounds = function(elem){
	return {
		center: {
			x: elem.left + elem.width/2,
			y: elem.top + elem.height/2
		},
		left: elem.left, right: elem.left + elem.width,
		top: elem.top, bottom: elem.top + elem.height,
		width: elem.width, height: elem.height
	}
}
GetBoundsPoint = function(elem, submittedRotation){
	var obj = GetElementBounds(elem);
	var dx = obj.width/2, dy = obj.height/2;
	var angle = Math.atan2(dy,dx);
	var rotation = angle*180/Math.PI;
	submittedRotation = Math.round(submittedRotation) % 360;
	if (submittedRotation < -180) submittedRotation += 360;
	else if (submittedRotation > 180) submittedRotation -= 360;
	switch (submittedRotation){
		case 0: return {x: obj.right, y: obj.center.y}
		case 90: return {x: obj.center.x, y: obj.top} 
		case 180: return {x: obj.left, y: obj.center.y}
		case 270: return {x: obj.center.x, y: obj.bottom}
	}
	subangle = submittedRotation*Math.PI/180;
	if (submittedRotation > -rotation && submittedRotation < 180-rotation){
		if (submittedRotation > rotation){  // use top
			var p = {x: obj.center.x+Math.cos(subangle)*dy/Math.sin(subangle), y: obj.top}
		}else{  // use right
			var p = {x: obj.right, y: obj.center.y-Math.sin(subangle)*dx/Math.cos(subangle)}
		}
	}else{
		if (submittedRotation < 0 && submittedRotation > rotation-180){  // use bottom
			var p = {x: obj.center.x-Math.cos(subangle)*dy/Math.sin(subangle), y: obj.bottom}
		}else{  // use left
			var p = {x: obj.left, y: obj.center.y+Math.sin(subangle)*dx/Math.cos(subangle)}
		}
	}
	return p;
}
RotatePoint = function(pt,angle) {
	var ca = Math.cos(angle);
	var sa = Math.sin(angle);
	return {x: pt.x*ca-pt.y*sa, y: pt.x*sa+pt.y*ca}
}
DefineArrangementValues = function(submittedRotation, placement){
	var i,p, dir = true;
	if ((placement == "width" || placement == "height" || placement == "area") && submittedRotation < 0) dir = false;
	for (i=0; i<elems.length; i++){
		if (placement == "top") p = RotatePoint(GetBoundsPoint(elems[i], submittedRotation), -submittedRotation*Math.PI/180);
		else if (placement =="center") p = RotatePoint(GetElementBounds(elems[i]).center, -submittedRotation*Math.PI/180);
		else if (placement =="bottom")  p = RotatePoint(GetBoundsPoint(elems[i], submittedRotation+180), -submittedRotation*Math.PI/180);
		else if (placement =="width")  p = {x: elems[i].width};
		else if (placement =="height")  p = {x: elems[i].height};
		else if (placement =="area")  p = {x: elems[i].width*elems[i].height};
		arrangement[i] = p.x;
	}
	return dir;
}
// placememt: "top" "center" "bottom" "width" "height" "area"
doCommand = function(submittedRotation, placement){
	if (submittedRotation == undefined) return alert("Error: Variable submittedRotation not defined.");
	else if (placement == undefined) return alert("Error: Variable placement not defined.");
	var inverseDirection = DefineArrangementValues(submittedRotation, placement);
	Sort(inverseDirection);
	dom.selectNone();
}