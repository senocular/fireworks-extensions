Stage.scaleMode = "noScale";

// ***************************************
// 3D Methods
//

Point = function(x,y,z,t){
	this.x = x;
	this.y = y;
	this.z = z;
	if (t) this.t = new Point();
};
Point.prototype.copy = function(){
	if (this.t) return new Point(this.x, this.y, this.z, true);
	return new Point(this.x, this.y, this.z);
};
Point.prototype.set2DPoint = function(){
	var foc = (this.isLightPt) ? 400 : FL;
	this.s = foc/(foc + this.t.z);
	this._x = this.t.x*this.s;
	this._y = this.t.y*this.s;
};
Point.prototype.toString = function(){
	if (this.t) return "x: "+this.t.x+", y: "+this.t.y+", z: "+this.t.z;
	return "x: "+this.x+", y: "+this.y+", z: "+this.z;
};
SquarePoly = function(a,b,c,d){
	this.a = a;
	this.b = b;
	this.c = c;
	this.d = d;
};
SquarePoly.prototype.drawFilled = function(c1, mc){
	if (isVisibleBetween(this.a,this.b,this.c)){
		if (LIGHT.ENABLED) c1 = GetShade(LIGHT.PTS[0].t, Direction(this.a.t, this.b.t, this.c.t), LIGHT.COL, c1);
		mc.moveTo(this.a._x, this.a._y);
		mc.beginFill(c1, 100);
		mc.lineTo(this.b._x, this.b._y);
		mc.lineTo(this.c._x, this.c._y);
		mc.lineTo(this.d._x, this.d._y);
		mc.lineTo(this.a._x, this.a._y);
		mc.endFill();
	}
};
SquarePoly.prototype.drawWired = function(mc){
	mc.moveTo(this.a._x, this.a._y);
	mc.lineTo(this.b._x, this.b._y);
	mc.lineTo(this.c._x, this.c._y);
	mc.lineTo(this.d._x, this.d._y);
	mc.lineTo(this.a._x, this.a._y);
};
NPoly = function(pts){
	this.pts = pts;
};
NPoly.prototype.drawFilled = function(c1, mc){
	if (isVisibleBetween(this.pts[0],this.pts[1],this.pts[2])){
		if (LIGHT.ENABLED) c1 = GetShade(LIGHT.PTS[0].t, Direction(this.pts[0].t, this.pts[1].t, this.pts[2].t), LIGHT.COL, c1);
		mc.moveTo(this.pts[0]._x, this.pts[0]._y);
		mc.beginFill(c1, 100);
		var i = this.pts.length;
		while(--i) mc.lineTo(this.pts[i]._x, this.pts[i]._y);
		mc.lineTo(this.pts[0]._x, this.pts[0]._y);
		mc.endFill();
	}
};
NPoly.prototype.drawWired = function(){
	return false; // not needed since other shapes make up outline
};
Number.prototype.HEXtoRGB = function(){
	return {rb:this >> 16, gb:(this >> 8) & 0xff, bb:this & 0xff};
};
Number.prototype.blendRGB = function(c2,t){
	if (t<0) t=0;
	else if (t>1) t=1;
	var c1 = this.HEXtoRGB();
	c2 = c2.HEXtoRGB();
	return (c1.rb+(c2.rb-c1.rb)*t) << 16 | (c1.gb+(c2.gb-c1.gb)*t) << 8 | (c1.bb+(c2.bb-c1.bb)*t);
};
Direction = function(a,b,c){ // direction, gives a perpendicular
	var va = new Point(b.x-a.x, b.y-a.y, b.z-a.z);
	var vb = new Point(c.x-a.x, c.y-a.y, c.z-a.z);
	return new Point(va.y*vb.z-va.z*vb.y, va.z*vb.x-va.x*vb.z, va.x*vb.y-va.y*vb.x); // cross product vector (points out perpendicularly from plane)
};
GetShade = function(a /*light*/, b /*direction*/, c2, c1){
	var aq = Math.sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
	var bq = Math.sqrt(b.x*b.x + b.y*b.y + b.z*b.z);
	var t = Math.asin((a.x*b.x + a.y*b.y + a.z*b.z)/(aq*bq))+Math.PI/2;	// angle between vectors
	t = 1-t/Math.PI;
	var spread = light_panel.focus_slider.getValue();
	t -= (1-t)*Math.tan((1-spread) * Math.PI/2);
	return c1.blendRGB(c2,t);
};
isVisibleBetween = function(a,b,c){
	return ((b._y-a._y)/(b._x-a._x)-(c._y-a._y)/(c._x-a._x)<0)^(a._x<=b._x == a._x>c._x);
};
RotatePoints = function(pts, rot){
	var sx = Math.sin(rot.x);
	var cx = Math.cos(rot.x);
	var sy = Math.sin(rot.y);
	var cy = Math.cos(rot.y);
	var sz = Math.sin(rot.z);
	var cz = Math.cos(rot.z);
	var p,xy,xz,yx,yz,zx,zy, i = pts.length;
	while (i--){
		p = pts[i];
		yz = cy*p.z - sy*p.x;
		yx = sy*p.z + cy*p.x;
		xy = cx*p.y - sx*yz;
		p.t.z = sx*p.y + cx*yz;
		p.t.x = cz*yx - sz*xy;
		p.t.y = sz*yx + cz*xy;
		p.set2DPoint();
	}
	return pts;
};
RenderBounding = function(){
	var i = SHAPE.POLYS.length;
	this.clear();
	this.lineStyle(0,0x666666,100);
	this.moveTo(SHAPE.BBOX[0]._x, SHAPE.BBOX[0]._y);
	this.lineTo(SHAPE.BBOX[1]._x, SHAPE.BBOX[1]._y);
	this.lineTo(SHAPE.BBOX[2]._x, SHAPE.BBOX[2]._y);
	this.lineTo(SHAPE.BBOX[3]._x, SHAPE.BBOX[3]._y);
	this.lineTo(SHAPE.BBOX[0]._x, SHAPE.BBOX[0]._y);
	this.lineTo(SHAPE.BBOX[4]._x, SHAPE.BBOX[4]._y);
	this.lineTo(SHAPE.BBOX[5]._x, SHAPE.BBOX[5]._y);
	this.lineTo(SHAPE.BBOX[6]._x, SHAPE.BBOX[6]._y);
	this.lineTo(SHAPE.BBOX[7]._x, SHAPE.BBOX[7]._y);
	this.lineTo(SHAPE.BBOX[4]._x, SHAPE.BBOX[4]._y);
	this.moveTo(SHAPE.BBOX[1]._x, SHAPE.BBOX[1]._y);
	this.lineTo(SHAPE.BBOX[5]._x, SHAPE.BBOX[5]._y);
	this.moveTo(SHAPE.BBOX[2]._x, SHAPE.BBOX[2]._y);
	this.lineTo(SHAPE.BBOX[6]._x, SHAPE.BBOX[6]._y);
	this.moveTo(SHAPE.BBOX[3]._x, SHAPE.BBOX[3]._y);
	this.lineTo(SHAPE.BBOX[7]._x, SHAPE.BBOX[7]._y);
	this.moveTo(0,0); // Axes
	this.lineStyle(0,0xff0000,100);
	this.lineTo(SHAPE.BBOX[8]._x, SHAPE.BBOX[8]._y);
	this.moveTo(0,0);
	this.lineStyle(0,0x00ff00,100);
	this.lineTo(SHAPE.BBOX[9]._x, SHAPE.BBOX[9]._y);
	this.moveTo(0,0);
	this.lineStyle(0,0x0000ff,100);
	this.lineTo(SHAPE.BBOX[10]._x, SHAPE.BBOX[10]._y);
	updateAfterEvent();	
};
RenderFill = function(){
	var i = SHAPE.POLYS.length;
	this.clear();
	if (SHAPE.LINE._visible) this.lineStyle(SHAPE.THICK, SHAPE.LINE, 100);
	while(i--) SHAPE.POLYS[i].drawFilled(SHAPE.FILL, this);
	updateAfterEvent();
};
RenderWire = function(){
	var i = SHAPE.POLYS.length;
	this.clear();
	this.lineStyle(SHAPE.THICK, SHAPE.LINE, 100);
	while(i--) SHAPE.POLYS[i].drawWired(this);
	updateAfterEvent();
};
RenderShape = function(){
	if (SHAPE.FILL._visible){
		RenderFill.call(this);
	}else if (SHAPE.LINE._visible){
		RenderWire.call(this);
	}else this.clear();
};
RenderLight = function(){
	this.lamp._x = LIGHT.PTS[0]._x;
	this.lamp._y = LIGHT.PTS[0]._y;
	new Color(this.lamp.center).setRGB(LIGHT.COL);
	new Color(light_z_rotater.center).setRGB(LIGHT.COL);
	this.lamp._xscale = this.lamp._yscale = 100*LIGHT.PTS[0].s;
	if (LIGHT.PTS[0].t.z > 0) this.lamp._alpha = 65;
	
	else  this.lamp._alpha = 100;
	var apex = LIGHT.PTS[0];
	this.clear();
	this.lineStyle(2,LIGHT.COL,100);
	this.lineTo(apex._x, apex._y);
	this.lineStyle(0,0x666666,70);
	this.lineTo(LIGHT.PTS[1]._x, LIGHT.PTS[1]._y);
	this.lineTo(LIGHT.PTS[2]._x, LIGHT.PTS[2]._y);
	this.lineTo(apex._x, apex._y);
	this.lineTo(LIGHT.PTS[3]._x, LIGHT.PTS[3]._y);
	this.lineTo(LIGHT.PTS[4]._x, LIGHT.PTS[4]._y);
	this.lineTo(apex._x, apex._y);
	this.moveTo(LIGHT.PTS[1]._x, LIGHT.PTS[1]._y);
	this.lineTo(LIGHT.PTS[4]._x, LIGHT.PTS[4]._y);
	this.moveTo(LIGHT.PTS[2]._x, LIGHT.PTS[2]._y);
	this.lineTo(LIGHT.PTS[3]._x, LIGHT.PTS[3]._y);
	updateAfterEvent();
};


// ***************************************
//Interface
//
info_btn.onRelease = function(){
	getURL("3D Primitives Doc/index.html");
};
ChangePanelSection = function(section){
	shape_panel._visible = false;
	transform_panel._visible = false;
	profile_panel._visible = false;
	view_panel._visible = false;
	light_panel._visible = false;
	export_panel._visible = false;
	this[section]._visible = true;
}
onChangeSection = function(inst){
	ChangePanelSection(inst.getValue());
};
GenericUpdate  = function(val){
	this.onReleased(val, true);
};

// SHAPE PANEL
shape_panel.onSetFill = function(inst){
	SHAPE.FILL = getPickerColor(inst);
	theScene.RenderShape();
};
shape_panel.onSetLine = function(inst){
	SHAPE.LINE = getPickerColor(inst);
	theScene.RenderShape();
};
shape_panel.line_thickness_slider.onUpdate = GenericUpdate;
shape_panel.line_thickness_slider.onReleased = function(val, abort){
	shape_panel.line_thickness_slider_txt.text = SHAPE.THICK = Math.round(1+24*val);
	if (!abort) theScene.RenderShape();
};
shape_panel.radial_slider.onUpdate = GenericUpdate;
shape_panel.radial_slider.onReleased = function(val, abort){
	shape_panel.radial_slider_txt.text = SHAPE.RADIAL = Math.round(3+17*val);
	if (!abort) CreatePolys();
};
shape_panel.axial_slider.onUpdate = GenericUpdate;
shape_panel.axial_slider.onReleased = function(val, abort){
	shape_panel.axial_slider_txt.text = SHAPE.AXIAL = Math.round(1+14*val);
	if (!abort) CreatePolys();
};
shape_panel.profile_btn.onRelease = function(){
	ChangePanelSection("profile_panel");
};
CreatePolys = function(){	
	if (SHAPE.RADIAL < 2) SHAPE.RADIAL = 2; // 2 is flat
	if (SHAPE.AXIAL < 1) SHAPE.AXIAL = 1;
	var radii = profile_panel.drawArc(SHAPE.AXIAL);
	var polyNum = SHAPE.RADIAL*SHAPE.AXIAL;
	SHAPE.POLYS = [];
	SHAPE.PTS = [];
	var rSpan = 2*Math.PI/SHAPE.RADIAL;
	var bSpan = 100/SHAPE.AXIAL;
	var topHeavy = (SHAPE.AXIAL == 1 && radii[0].x > radii[1].x);
	var ang, pt, len, rad, L, R;
	for(L=0; L<=SHAPE.AXIAL; L++){
		for (R=0; R<SHAPE.RADIAL; R++){
			ang = R*rSpan+rSpan/2;
			len = SHAPE.PTS.length;
			rad = radii[L];
			pt = SHAPE.PTS[len] = new Point(Math.cos(ang)*rad.x, rad.y-50, Math.sin(ang)*rad.x, true);
			if (L && R){ // make polys
				if (L == SHAPE.AXIAL && !topHeavy){ // prevents shared points at ends disrupting isVisible
					SHAPE.POLYS[SHAPE.POLYS.length] = new SquarePoly(SHAPE.PTS[len-1], SHAPE.PTS[len-SHAPE.RADIAL-1], SHAPE.PTS[len-SHAPE.RADIAL], pt);
					if (R == SHAPE.RADIAL-1) SHAPE.POLYS[SHAPE.POLYS.length] = new SquarePoly(pt, SHAPE.PTS[len-SHAPE.RADIAL], SHAPE.PTS[len-SHAPE.RADIAL-SHAPE.RADIAL+1], SHAPE.PTS[len-SHAPE.RADIAL+1]);
				}else{ // shift order
					SHAPE.POLYS[SHAPE.POLYS.length] = new SquarePoly(SHAPE.PTS[len-SHAPE.RADIAL], pt, SHAPE.PTS[len-1], SHAPE.PTS[len-SHAPE.RADIAL-1]);
					if (R == SHAPE.RADIAL-1) SHAPE.POLYS[SHAPE.POLYS.length] = new SquarePoly(SHAPE.PTS[len-SHAPE.RADIAL-SHAPE.RADIAL+1], SHAPE.PTS[len-SHAPE.RADIAL+1], pt, SHAPE.PTS[len-SHAPE.RADIAL]);
				}
			}
		}
	}
	SHAPE.POLYS[SHAPE.POLYS.length] = new NPoly(SHAPE.PTS.slice(0,SHAPE.RADIAL).reverse()); // caps
	SHAPE.POLYS[SHAPE.POLYS.length] = new NPoly(SHAPE.PTS.slice(-SHAPE.RADIAL));
	BackUpOriginalPoints();
	ApplyTransform();
	RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
	theScene.RenderShape();
};
BackUpOriginalPoints = function(){
	var p, i = SHAPE.PTS.length;
	SHAPE.PTSBAK = [];
	while(i--) SHAPE.PTSBAK[i] = SHAPE.PTS[i].copy();
};

// TRANSFORM PANEL
ApplyTransform = function(){
	var p, b, i = SHAPE.PTS.length;
	while(i--){
		p = SHAPE.PTS[i];
		b = SHAPE.PTSBAK[i];
		p.x = b.x*transform_panel.x_slider.trans;
		p.y = b.y*transform_panel.y_slider.trans;
		p.z = b.z*transform_panel.z_slider.trans;
	}
};
transform_panel.x_slider.onUpdate = transform_panel.y_slider.onUpdate = transform_panel.z_slider.onUpdate = function(val){
	this.trans = .1 + val*.9;
	transform_panel[this._name+"_txt"].text = Math.round(this.trans*100);
};
transform_panel.x_slider.onReleased = transform_panel.y_slider.onReleased = transform_panel.z_slider.onReleased = function(){
	CreatePolys();
};

// VIEW PANEL
xy_rotater.onPress = function(){
	this.onMouseMove = function(){
		var dx = (this.last_xmouse - _root._xmouse)/100;
		var dy = (this.last_ymouse - _root._ymouse)/100;
		var s = Math.sin(TIMELINE.CURRFRAME.ROT.z);
		var c = Math.cos(TIMELINE.CURRFRAME.ROT.z);
		RotateShape(s*dx-c*dy, c*dx+s*dy, 0)
		this.last_xmouse = _root._xmouse;
		this.last_ymouse = _root._ymouse;
	};
	this.last_xmouse = _root._xmouse;
	this.last_ymouse = _root._ymouse;
};
z_rotater.onPress = function(){
	this.onMouseMove = function(){
		var currMouseAngle = Math.atan2(this._ymouse, this._xmouse)
		var dif = currMouseAngle - this.mouseAngle;
		this.mouseAngle = currMouseAngle;
		if (dif > Math.PI) dif -= Math.PI*2;
		if (dif <= -Math.PI) dif += Math.PI*2;
		RotateShape(0,0,dif);
	};
	this.mouseAngle = Math.atan2(this._ymouse, this._xmouse);
};
RotateShape = function(x,y,z){
	SetKeyFrame();
	TIMELINE.CURRFRAME.ROT.x += x;
	TIMELINE.CURRFRAME.ROT.y += y;
	TIMELINE.CURRFRAME.ROT.z += z;
	UpdatexyzText();
	RotatePoints(SHAPE.BBOX, TIMELINE.CURRFRAME.ROT);
	theScene.RenderBounding();
};
UpdatexyzText = function(){
	view_panel.x_slider_txt.text = Math.round(TIMELINE.CURRFRAME.ROT.x*180/Math.PI);
	view_panel.y_slider_txt.text = Math.round(TIMELINE.CURRFRAME.ROT.y*180/Math.PI);
	view_panel.z_slider_txt.text = Math.round(TIMELINE.CURRFRAME.ROT.z*180/Math.PI);
};
CompleteRotation = function(){
	delete this.onMouseMove;
	RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
	theScene.RenderShape();
};
xy_rotater.onRelease = xy_rotater.onReleaseOutside = CompleteRotation;
z_rotater.onRelease = z_rotater.onReleaseOutside = CompleteRotation;
view_panel.perspective_slider.onUpdate = GenericUpdate;
view_panel.perspective_slider.onReleased = function(val, abort){
	FL = 125 + 500 * val;
	view_panel.perspective_slider_txt.text = Math.round(FL);
	var i = SHAPE.PTS.length;
	while(i--) SHAPE.PTS[i].set2DPoint();
	if (!abort) theScene.RenderShape();
	else RotateShape(0,0,0);
};
view_panel.x_slider.onPressed = view_panel.y_slider.onPressed = view_panel.z_slider.onPressed = function(val){
	this.lastVal = val;
};
view_panel.x_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateShape((val-this.lastVal)*Math.PI,0,0);
	this.lastVal = val;
};
view_panel.y_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateShape(0,(val-this.lastVal)*Math.PI,0);
	this.lastVal = val;
};
view_panel.z_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateShape(0,0,(val-this.lastVal)*Math.PI);
	this.lastVal = val;
};
view_panel.x_slider.onReleased = view_panel.y_slider.onReleased = view_panel.z_slider.onReleased = function(val){
	RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
	theScene.RenderShape();
	if (val != .5) this.setValue(.5);
};

// PROFILE PANEL
profile_panel.apply_btn.onRelease = function(){
	ChangePanelSection("shape_panel");
	CreatePolys();
};

// LIGHT PANEL
LampOnPress = function(){
	this.onMouseMove = function(){
		var dx = (this.last_xmouse - _root._xmouse)/100;
		var dy = (this.last_ymouse - _root._ymouse)/100;
		var s = Math.sin(TIMELINE.CURRFRAME.LIGHTROT.z);
		var c = Math.cos(TIMELINE.CURRFRAME.LIGHTROT.z);
		RotateLight(s*dx-c*dy, c*dx+s*dy, 0);
		this.last_xmouse = _root._xmouse;
		this.last_ymouse = _root._ymouse;
	};
	this.last_xmouse = _root._xmouse;
	this.last_ymouse = _root._ymouse;
};
light_z_rotater.onPress = function(){
	this.onMouseMove = function(){
		var currMouseAngle = Math.atan2(this._ymouse, this._xmouse)
		var dif = currMouseAngle - this.mouseAngle;
		this.mouseAngle = currMouseAngle;
		if (dif > Math.PI) dif -= Math.PI*2;
		if (dif <= -Math.PI) dif += Math.PI*2;
		RotateLight(0,0,dif);
	};
	this.mouseAngle = Math.atan2(this._ymouse, this._xmouse);
};
RotateLight = function(x,y,z){
	SetKeyFrame();
	TIMELINE.CURRFRAME.LIGHTROT.x += x;
	TIMELINE.CURRFRAME.LIGHTROT.y += y;
	TIMELINE.CURRFRAME.LIGHTROT.z += z;
	UpdateLightText();
	RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
	theLight.RenderLight();
};
UpdateLightText = function(){
	light_panel.x_slider_txt.text = Math.round(TIMELINE.CURRFRAME.LIGHTROT.x*180/Math.PI);
	light_panel.y_slider_txt.text = Math.round(TIMELINE.CURRFRAME.LIGHTROT.y*180/Math.PI);
	light_panel.z_slider_txt.text = Math.round(TIMELINE.CURRFRAME.LIGHTROT.z*180/Math.PI);
};
CompleteLampRotation = function(){
	delete this.onMouseMove;
	theScene.RenderShape();
};
light_z_rotater.onRelease = light_z_rotater.onReleaseOutside = CompleteLampRotation;
light_panel.onSetLight = function(inst){
	LIGHT.COL = getPickerColor(inst);
	theLight.RenderLight();
	theScene.RenderShape();
};
light_panel.onEnableLight = function(inst){
	LIGHT.ENABLED = inst.getValue();
	theScene.RenderShape();
};
light_panel.onShowLight = function(inst){
	theLight._visible = light_z_rotater._visible = inst.getValue();
};
light_panel.focus_slider.onUpdate = GenericUpdate;
light_panel.focus_slider.onReleased = function(val, abort){
	light_panel.focus_slider_txt.text = Math.round(val*100);
	if (!abort) theScene.RenderShape();
};
getPickerColor = function(picker){
	var c = picker.getColor();
	var val = new Number(picker.stringToColor(c.slice(1)));
	if (c == "#FFFFFF00") val._visible = false;
	else val._visible = true;
	return val;
	
};
light_panel.x_slider.onPressed = light_panel.y_slider.onPressed = light_panel.z_slider.onPressed = function(val){
	this.lastVal = val;
};
light_panel.x_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateLight((val-this.lastVal)*Math.PI,0,0);
	this.lastVal = val;
};
light_panel.y_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateLight(0,(val-this.lastVal)*Math.PI,0);
	this.lastVal = val;
};
light_panel.z_slider.onUpdate = function(val){
	if (val == .5) return false;
	RotateLight(0,0,(val-this.lastVal)*Math.PI);
	this.lastVal = val;
};
light_panel.x_slider.onReleased = light_panel.y_slider.onReleased = light_panel.z_slider.onReleased = function(val){
	RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
	theLight.RenderLight();
	theScene.RenderShape();
	if (val != .5) this.setValue(.5);
};

// EXPORT PANEL
export_panel.onExportSingleOrRange = function(inst){
	if (inst.getValue() == "single"){
		export_panel.multiple_frames._visible = false;
	}else{
		export_panel.multiple_frames._visible = true;
	}		
};
UpdateScaleText = function(){
	export_panel.scale_slider_txt.text = Math.round(export_panel.scale_slider.scale*100);
};
export_panel.scale_slider.onPressed = function(val){
	this.lastVal = val;
};
export_panel.scale_slider.onUpdate = function(val){
	if (val == .5) return false;
	this.scale = Math.min(Math.max(.01, this.scale+(val-this.lastVal)*2),5);
	UpdateScaleText();
	this.lastVal = val;
};
export_panel.scale_slider.onReleased = function(val){
	if (val != .5) this.setValue(.5);
};

// TIMELINE
Frame = function(shapeRot, lightRot, key){
	this.ROT = (shapeRot) ? shapeRot : new Point();
	this.LIGHTROT = (lightRot) ? lightRot : new Point();
	this.isKeyframe = (key) ? true : false;
};
Array.prototype.getEnds = function(index){
	var i, start, startpos, end, endpos, last=this.length-1;
	if (index <= 0){
		start = this[0];
		startpos = 0;
	}else{
		for (i=index-1; i>=0; i--){
			if (this[i].isKeyFrame){
				start = this[i];
				startpos = i;
				break;
			}
			if (i == 0){
				start = this[0];
				startpos = 0;
			}
		}
	}
	if (index >= last){
		end = start;
		endpos = startpos;
	}else{
		for (i=index+1; i<=last; i++){
			if (this[i].isKeyFrame){
				end = this[i];
				endpos = i;
				break;
			}
			if (i == last){
				end = start;
				endpos = startpos;
			}
		}
	}
	return {start:start, startpos:startpos,  end:end, endpos:endpos};
};
InterpolateFrames = function( ends, index){
	var range = ends.endpos - ends.startpos;
	var per = (index - ends.startpos)/range;
	TIMELINE.CURRFRAME.ROT = new Point(
		ends.start.ROT.x+(ends.end.ROT.x-ends.start.ROT.x)*per,
		ends.start.ROT.y+(ends.end.ROT.y-ends.start.ROT.y)*per,
		ends.start.ROT.z+(ends.end.ROT.z-ends.start.ROT.z)*per
	);
	TIMELINE.CURRFRAME.LIGHTROT = new Point(
		ends.start.LIGHTROT.x+(ends.end.LIGHTROT.x-ends.start.LIGHTROT.x)*per,
		ends.start.LIGHTROT.y+(ends.end.LIGHTROT.y-ends.start.LIGHTROT.y)*per,
		ends.start.LIGHTROT.z+(ends.end.LIGHTROT.z-ends.start.LIGHTROT.z)*per
	);
};
SetCurrentFrame = function(index){
	TIMELINE.INDEX = index;
	TIMELINE.CURRFRAME = TIMELINE.FRAMES[index];
	if (!TIMELINE.CURRFRAME.isKeyframe){
		var ends = TIMELINE.FRAMES.getEnds(index);
		if (ends.startpos == ends.endpos){
			TIMELINE.CURRFRAME.ROT = ends.start.ROT.copy();
			TIMELINE.CURRFRAME.LIGHTROT = ends.start.LIGHTROT.copy();
		}else{
			InterpolateFrames(ends, index);
		}
	}
};
SetKeyFrame = function(){
	if (!TIMELINE.INDEX || TIMELINE.CURRFRAME.isKeyframe) return false;
	TIMELINE.CURRFRAME.isKeyframe = true;
	theTimeline.attachMovie("keyframe", "keyframe"+TIMELINE.INDEX, TIMELINE.INDEX, {_x:TIMELINE.INDEX*10});
};
MoveToFrame = function(fra, abort){
	SetCurrentFrame(fra);
	frame_marker_mc._x = TIMELINE.MIN+fra*10;
	RotatePoints(SHAPE.BBOX, TIMELINE.CURRFRAME.ROT);
	theScene.RenderBounding();
	UpdatexyzText();
	RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
	theLight.RenderLight();
	UpdateLightText();
	if (!abort){
		RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
		theScene.RenderShape();
	};
}
theTimeline.onPress = function(){
	MoveToFrame(Math.min(Math.max(0,Math.floor(this._xmouse/10)),24));
};
Key.addListener(theTimeline);
theTimeline.onKeyDown = function(){ // delete keyframe
	if (!this._parent.noKeyDelete && (Key.isDown(Key.DELETEKEY) || Key.isDown(Key.BACKSPACE) || Key.isDown(68))){
		if (TIMELINE.INDEX && TIMELINE.CURRFRAME.isKeyframe){
			TIMELINE.CURRFRAME.isKeyframe = false;
			theTimeline["keyframe"+TIMELINE.INDEX].removeMovieClip();
			MoveToFrame(TIMELINE.INDEX);
		}
	}
};
timeline_slider_1.onPress = function(){
	this.onMouseMove = function(){
		var range = Math.min(Math.max(TIMELINE.MIN, this._parent._xmouse), timeline_slider_2._x-10);
		this._x = Math.round(range/10)*10;
		timeline_range.update();
	};
};
timeline_slider_2.onPress = function(){
	this.onMouseMove = function(){
		var range = Math.min(Math.max(timeline_slider_1._x+10, this._parent._xmouse), TIMELINE.MAX);
		this._x = Math.round(range/10)*10;
		timeline_range.update();
	};
};
timeline_slider_1.onRelease = timeline_slider_1.onReleaseOutside = function(){
	delete this.onMouseMove;
};
timeline_slider_2.onRelease = timeline_slider_2.onReleaseOutside = function(){
	delete this.onMouseMove;
};
timeline_range.update = function(){
	this._x = timeline_slider_1._x;
	this._xscale = timeline_slider_2._x - timeline_slider_1._x;
	var low = Math.round((timeline_slider_1._x - TIMELINE.MIN)/10);
	var high = Math.round((timeline_slider_2._x - TIMELINE.MIN)/10);
	export_panel.multiple_frames.range_from_txt.text = low+1;
	export_panel.multiple_frames.range_to_txt.text = high+1;
	TIMELINE.RANGE = [low,high];
};
frame_marker_mc.onPress = function(){
	this.onMouseMove = function(){
		var range = Math.min(Math.max(TIMELINE.MIN, this._parent._xmouse), TIMELINE.MAX);
		var pos = Math.round(range/10)*10;
		var fra = Math.round((pos - TIMELINE.MIN)/10);
		if (fra != TIMELINE.INDEX) MoveToFrame(fra, true);
	};
};
frame_marker_mc.onRelease = frame_marker_mc.onReleaseOutside = function(){
	delete this.onMouseMove;
	RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
	theScene.RenderShape();
};


// ***************************************
// FW Actions
//

FWAPIClass = function(){
	this.commandString = "";
};
FWAPIClass.prototype.init = function(){
	this.commandString = "var dom = fw.getDocumentDOM();\r\n";
	this.selectNone();
};
FWAPIClass.prototype.pointToString = function(pt) {
	return "{x:" + pt.x + "+OFFSET_X, y:" + pt.y + "+OFFSET_Y}";
};
// COMMANDSTRING appending
FWAPIClass.prototype.selectNone = function(){
	this.commandString += "dom.selectNone();\r\n";
};
FWAPIClass.prototype.setOffsets = function(){
	this.commandString += "var OFFSET_X = "+this.offx+";\r\n";
	this.commandString += "var OFFSET_Y = "+this.offy+";\r\n";
};
FWAPIClass.prototype.assignOffsets = function(alt){
	var commandString = "function getSelectionOffset(){\r\n";
	commandString += "\tvar offset = \"\";\r\n";
	commandString += "\tif (fw.selection.length) {\r\n";
	commandString += "\t\tvar sel = fw.selection[0];\r\n";
	commandString += "\t\toffset = (sel.left+sel.width/2)+\",\"+(sel.top+sel.height/2);\r\n";
	commandString += "\t}else{\r\n";
	commandString += "\t\toffset = \""+alt+","+alt+"\";\r\n";
	commandString += "\t}\r\n";
	commandString += "\treturn offset\r\n";
	commandString += "};\r\n";
	commandString += "getSelectionOffset();";
	var offsets =  FWJavascript(commandString).split(",");
	this.offx = parseInt(offsets[0],10);
	this.offy = parseInt(offsets[1],10);
};
FWAPIClass.prototype.addNewPointForPath = function(pt) {	
	this.commandString += "dom.addNewSinglePointPath(" + this.pointToString(pt) + ", " + this.pointToString(pt) + ", " + this.pointToString(pt) + ", false);\r\n";	
};
FWAPIClass.prototype.appendPointToPath = function( ptToInsertBefore, pt) {
	this.commandString += "dom.appendPointToPath(0, " + ptToInsertBefore + ", " +  this.pointToString(pt) + ", " + this.pointToString(pt) + ", " + this.pointToString(pt) + ");\r\n";
};
FWAPIClass.prototype.closePath = function( ptToInsertBefore, pt) {
	this.commandString += "fw.selection[0].contours[0].isClosed=true;\r\n";
};
FWAPIClass.prototype.addNewLayer = function(name) {
	this.commandString += "dom.addNewLayer(\"" + name + "\", false);\r\n";	
};
FWAPIClass.prototype.hideLayers = function() {
	this.commandString += "dom.setLayerDisclosure(-1, false);\r\n";	
};
FWAPIClass.prototype.setFillColor = function(fill) {
	this.commandString += "dom.setFillColor(\"" + fill + "\");\r\n";	
};
FWAPIClass.prototype.setLineColor = function(line) {
	this.commandString += "dom.setBrushColor(\"" + line + "\");\r\n";
};
FWAPIClass.prototype.setLineThick = function(thick) {
	this.commandString += "var myThickBrush = dom.pathAttributes.brush;\r\n";
	this.commandString += "if (myThickBrush == null) myThickBrush = new Brush();\r\n";
	this.commandString += "myThickBrush.diameter = "+ thick +";\r\n";
	this.commandString += "dom.setBrush(myThickBrush);\r\n";
};
FWAPIClass.prototype.setFillSolid = function() {
	this.commandString += "var mySolidFill = dom.pathAttributes.fill;\r\n";
	this.commandString += "if (mySolidFill == null) mySolidFill = new Fill();\r\n";
	this.commandString += "mySolidFill.shape = \"solid\";\r\n";
	this.commandString += "dom.setFill(mySolidFill);\r\n";
};
FWAPIClass.prototype.flatten = function() {
	this.commandString += "dom.selectAllOnLayer(dom.currentLayerNum);\r\n";
	this.commandString += "dom.flattenSelection();\r\n";
};
FWAPIClass.prototype.nextFrame = function(){
	this.commandString += "if (dom.frames.length-1 == dom.currentFrameNum) {\r\n";
	this.commandString += "\tdom.addFrames(1, \"end\", true);\r\n";
	this.commandString += "}else{\r\n";
	this.commandString += "\tdom.currentFrameNum++;\r\n";
	this.commandString += "}\r\n";
};
// FLA control
FWAPIClass.prototype.createPathAt = function(pt){
	this.currPoint = 0;
	pt = {x:pt._x*this.scale, y:pt._y*this.scale};
	this.addNewPointForPath(pt);
};
FWAPIClass.prototype.addPathPoint = function(pt){
	this.currPoint++;
	pt = {x:pt._x*this.scale, y:pt._y*this.scale};
	this.appendPointToPath(this.currPoint, pt);
};
FWAPIClass.prototype.FWDrawFilled = function(c1, poly){
	var sq = (poly instanceof SquarePoly);
	var vis = (sq) ? isVisibleBetween(poly.a,poly.b,poly.c) : isVisibleBetween(poly.pts[0],poly.pts[1],poly.pts[2]);
	if (vis){
		if (sq){
			if (LIGHT.ENABLED) c1 = GetShade(LIGHT.PTS[0].t, Direction(poly.a.t, poly.b.t, poly.c.t), LIGHT.COL, c1);
			this.createPathAt(poly.a);
			this.addPathPoint(poly.b);
			this.addPathPoint(poly.c);
			this.addPathPoint(poly.d);
		}else{ // NPOLY
			if (LIGHT.ENABLED) c1 = GetShade(LIGHT.PTS[0].t, Direction(poly.pts[0].t, poly.pts[1].t, poly.pts[2].t), LIGHT.COL, c1);
			this.createPathAt(poly.pts[0]);
			var i = poly.pts.length;
			while(--i) this.addPathPoint(poly.pts[i]);
		}
		var ln = (SHAPE.LINE._visible) ? SHAPE.LINE.toString(16) : "FFFFFF00";
		while (ln.length < 6) ln = "0"+ln;
		ln = "#"+ln;
		var fl = (SHAPE.FILL._visible) ? c1.toString(16) : "FFFFFF00";
		while (fl.length < 6) fl = "0"+fl;
		fl = "#"+fl;
		this.setLineColor(ln);
		this.setFillColor(fl);
		this.closePath();
	}
};
FWAPIClass.prototype.FWDrawWired = function(poly){
	if (poly instanceof SquarePoly){
		this.createPathAt(poly.a);
		this.addPathPoint(poly.b);
		this.addPathPoint(poly.c);
		this.addPathPoint(poly.d);
	}else{
		this.createPathAt(poly.pts[0]);
		var i = poly.pts.length;
		while(--i) this.addPathPoint(poly.pts[i]);
	}
	var ln = (SHAPE.LINE._visible) ? SHAPE.LINE.toString(16) : "FFFFFF00";
	while (ln.length < 6) ln = "0"+ln;
	ln = "#"+ln;
	this.setLineColor(ln);
	this.setFillColor("#FFFFFF00");
	this.closePath();
};
FWAPIClass.prototype.FWRenderFill = function(a,b,c,d){ // FOR EACH POLY
	var i = SHAPE.POLYS.length;
	while(i--) this.FWDrawFilled(SHAPE.FILL, SHAPE.POLYS[i]);
};
FWAPIClass.prototype.FWRenderWire = function(a,b,c,d){ // FOR EACH POLY
	var i = SHAPE.POLYS.length;
	while(i--) this.FWDrawWired(SHAPE.POLYS[i]);
};
FWAPIClass.prototype.FWRenderShape = function(){
	if (SHAPE.FILL._visible) this.FWRenderFill();
	else this.FWRenderWire();
};
export_panel.export_btn.onRelease =function(){
	FWAPI = new FWAPIClass();
	FWAPI.scale = export_panel.scale_slider.scale;
	FWAPI.assignOffsets(OFFSET+50*FWAPI.scale);
	
	var flattenFaces = export_panel.flatten_check.getValue();
	var asFrames = (export_panel.multiple_frames.frames_layers_pull.getValue() == "frames");
	var frameOnExport = TIMELINE.INDEX;
	var frameCount = 1;
	var startFrame = TIMELINE.INDEX;
	if (export_panel.single_range_pull.getValue() == "range"){
		frameCount += TIMELINE.RANGE[1]-TIMELINE.RANGE[0];
		startFrame = TIMELINE.RANGE[0];
	}
	var endFrame = startFrame+frameCount-1;
	
	ROOT.main._visible = false;
	ROOT.theExportWait._visible = true;
	ROOT.theExportWait.ok_btn._visible = false;
	ROOT.theExportWait.progress_bar._xscale = 0;
	ROOT.theExportWait.time = startFrame;
	ROOT.theExportWait.timeShifter = 0;
	ROOT.theExportWait.onEnterFrame = function(){
		var shifted = this.timeShifter%2;
		if (!shifted) {
			SetCurrentFrame(this.time);
			RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
			RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
		}else{
			FWAPI.init();
			FWAPI.setLineThick(SHAPE.THICK);
			FWAPI.setFillSolid();
			if (this.time != startFrame){
				if (asFrames) FWAPI.nextFrame();
				else FWAPI.addNewLayer(document.name_txt.text);
			}else FWAPI.addNewLayer(document.name_txt.text);
			
			FWAPI.setOffsets();
			FWAPI.FWRenderShape();
			if (flattenFaces) FWAPI.flatten();
			FWAPI.hideLayers();
			if (this.time == endFrame) FWAPI.selectNone();
			FWJavascript(FWAPI.commandString);
			
			this.time++;
		}
		this.progress_bar._xscale = 200*(this.time-startFrame+.5-shifted/2)/frameCount;
		this.timeShifter++;
		
		if (this.time > endFrame){
			SetCurrentFrame(frameOnExport);
			RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
			RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
			theScene.RenderShape();
			theLight.RenderLight();
			this.ok_btn._visible = true;
			delete this.onEnterFrame;
			
			FWEndCommand(true, "");
		}
	};
};
export_panel.preview_btn.onRelease = function(){
	var anim = ROOT.thePreview.createEmptyMovieClip("animation_mc",1);
	anim._x = 200;
	anim._y = 150;
	
	var frameOnExport = TIMELINE.INDEX;
	
	var frameCount = 1;
	var startFrame = TIMELINE.INDEX;
	if (export_panel.single_range_pull.getValue() == "range"){
		frameCount += TIMELINE.RANGE[1]-TIMELINE.RANGE[0];
		startFrame = TIMELINE.RANGE[0];
	}
	var endFrame = startFrame+frameCount-1;
	
	ROOT.main._visible = false;
	ROOT.thePreview.gotoAndStop(1);
	ROOT.thePreview._visible = true;
	ROOT.thePreview.progress_bar._xscale = 0;
	ROOT.thePreview.frame = 0;
	ROOT.thePreview.onEnterFrame = function(){
		var fra = anim.createEmptyMovieClip("frame"+this.frame,this.frame);
		fra._visible = false;
		SetCurrentFrame(startFrame+this.frame);
		RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
		RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
		RenderShape.call(fra);
		this.frame++;
		this.progress_bar._xscale = 200*this.frame/frameCount;
		if (startFrame+this.frame > endFrame){
			delete this.onEnterFrame;
			this.nextFrame();
			setUpForAnimation(anim, frameCount);
			anim.onEnterFrame = handleFrames;
			SetCurrentFrame(frameOnExport);
			RotatePoints(SHAPE.PTS, TIMELINE.CURRFRAME.ROT);
			RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
			theScene.RenderShape();
			theLight.RenderLight();
		}
	}
};
setUpForAnimation = function(mc, frames){
	mc.currFrame = 0;
	mc.totalFrames = frames;
	mc.isPlaying = false;
	mc.gotoFrame = function(fra){
		this["frame"+this.currFrame]._visible = false;
		if (fra < 0)	this.currFrame = this.totalFrames-1;
		else this.currFrame = fra;
		this["frame"+this.currFrame]._visible = true;
		this.isPlaying = false;
	};
}
handleFrames = function(){
	if (this.isPlaying){
		this["frame"+this.currFrame]._visible = false;
		this.currFrame++;
		if (this.currFrame >= this.totalFrames){
			if (this.loops) this.currFrame = 0;
			else{
				this.currFrame--;
				this.isPlaying = false;
			}
		}
		this["frame"+this.currFrame]._visible = true;
	}else if (!this["frame"+this.currFrame]._visible) this["frame"+this.currFrame]._visible = true;
};


// ***************************************
// Init
//

this.init = function(){
	this.createEmptyMovieClip("theScene", 1);
	theScene.RenderShape = RenderShape;
	theScene.RenderBounding = RenderBounding;
	this.createEmptyMovieClip("theLight", 2);
	theLight.RenderLight = RenderLight;
	theLight.attachMovie("lamp","lamp",1);
	theLight.lamp.onPress = LampOnPress;
	theLight.lamp.onRelease = theLight.lamp.onReleaseOutside = CompleteLampRotation;
	theScene._x = theLight._x = xy_rotater._x;
	theScene._y = theLight._y = xy_rotater._y;
	
	OFFSET = 100;
	LIGHT = new Object();
	LIGHT.PTS = [
		new Point(100,0,0, true), /* actual light */
		new Point(0,-50,-50, true), /* direction box */
		new Point(0,-50,50, true), 
		new Point(0,50,50, true), 
		new Point(0,50,-50, true)
	];
	for (var i=0; i<LIGHT.PTS.length; i++) LIGHT.PTS[i].isLightPt = true;
	LIGHT.ROT = new Point(-Math.PI/6, 5*Math.PI/6,0); // ini shape rotation for frame 1
	LIGHT.ENABLED = true;
	LIGHT.COL = getPickerColor(light_panel.lightColor_comp);
	SHAPE = new Object();
	SHAPE.BBOX = [
		new Point(-50,-50,-50, true),
		new Point(50,-50,-50, true),
		new Point(50,-50,50, true),
		new Point(-50,-50,50, true),
		new Point(-50,50,-50, true),
		new Point(50,50,-50, true),
		new Point(50,50,50, true),
		new Point(-50,50,50, true),
		new Point(25,0,0, true), /* axes */
		new Point(0,-25,0, true),
		new Point(0,0,-25, true)
	];
	SHAPE.AXIAL = 0;
	SHAPE.RADIAL = 0;
	SHAPE.PROFILE = new Object;
	SHAPE.ROT = new Point(Math.PI/6,-Math.PI/6,0); // ini shape rotation for frame 1
	SHAPE.FILL = getPickerColor(shape_panel.fillColor_comp);
	SHAPE.LINE = getPickerColor(shape_panel.lineColor_comp);
	SHAPE.THICK = 1;
	FL = 0;
	TIMELINE = new Object();
	TIMELINE.MIN = 10;
	TIMELINE.MAX = 250;
	TIMELINE.RANGE = [0,1];
	TIMELINE.FRAMES = new Array(25);
	TIMELINE.FRAMES[0] = new Frame(SHAPE.ROT, LIGHT.ROT, true);
	for (var i=1; i<25; i++) TIMELINE.FRAMES[i] = new Frame();
	SetCurrentFrame(0);
	
	shape_panel.line_thickness_slider.setValue(0);
	shape_panel.line_thickness_slider.onReleased(0, true);
	shape_panel.radial_slider.setValue(0);
	shape_panel.radial_slider.onReleased(.03, true);
	shape_panel.axial_slider.setValue(0);
	shape_panel.axial_slider.onReleased(0, true);
	view_panel.perspective_slider.setValue(.5);
	view_panel.perspective_slider.onReleased(.5, true);
	view_panel.x_slider.setValue(.5);
	view_panel.y_slider.setValue(.5);
	view_panel.z_slider.setValue(.5);
	UpdatexyzText();
	transform_panel.x_slider.setValue(1);
	transform_panel.y_slider.setValue(1);
	transform_panel.z_slider.setValue(1);
	light_panel.focus_slider.setValue(.5);
	light_panel.x_slider.setValue(.5);
	light_panel.y_slider.setValue(.5);
	light_panel.z_slider.setValue(.5);
	UpdateLightText();
	light_panel.onShowLight(light_panel.show_light_check);
	light_panel.onEnableLight(light_panel.enable_light_check);
	timeline_range.update();
	export_panel.scale_slider.onReleased();
	export_panel.scale_slider.scale = 1;
	UpdateScaleText();
	RotatePoints(LIGHT.PTS, TIMELINE.CURRFRAME.LIGHTROT);
	theLight.RenderLight();
	CreatePolys();
	RotatePoints(SHAPE.BBOX, TIMELINE.CURRFRAME.ROT);
	theScene.RenderShape();
	
	_global.ROOT = this._parent;
};
this.onEnterFrame = function(){
	this.init();
	delete this.onEnterFrame;
};
