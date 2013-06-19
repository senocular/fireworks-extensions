function pasteEffects(copied, copyFx, keepExisting, copyBrush, copyFill){
	var dom = fw.getDocumentDOM();
	var len = fw.selection.length;	if (!copied || !len) return false;
	for (var sel=0; sel<len; sel++){
		var copyTo = fw.selection[sel];
		if (copyFx){			if (keepExisting && copyTo.effectList != null ){				var toEffects = copyTo.effectList.effects;				var fromEffects = copied.effectList.effects;				var elements = fromEffects.length;				for (var i=0; i<elements; i++){					toEffects[toEffects.length] = fromEffects[i];				}			}else{
				copyTo.effectList = copied.effectList;
			}
		}
	}	if (copyBrush) dom.setBrushNColor(copied.brush[0], copied.brush[1]);	if (copyFill) dom.setFillNColor(copied.fill[0], copied.fill[1]);	return true;};

function copyEffects(){
	var dom = fw.getDocumentDOM();	if (fw.selection.length != 1){		alert("Select only one (1) object to copy effects from.");		return false;	}
	var sel = (fw.selection[0].pathAttributes == undefined) ? dom : fw.selection[0];	return {
		effectList: fw.selection[0].effectList,
		brush: [sel.pathAttributes.brush, sel.pathAttributes.brushColor],
		fill: [sel.pathAttributes.fill, sel.pathAttributes.fillColor]
	};};