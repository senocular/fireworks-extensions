function pasteEffects(copied, copyFx, keepExisting, copyBrush, copyFill){
	var dom = fw.getDocumentDOM();
	var len = fw.selection.length;
	for (var sel=0; sel<len; sel++){
		var copyTo = fw.selection[sel];
		if (copyFx){
				copyTo.effectList = copied.effectList;
			}
		}
	}

function copyEffects(){
	var dom = fw.getDocumentDOM();
	var sel = (fw.selection[0].pathAttributes == undefined) ? dom : fw.selection[0];
		effectList: fw.selection[0].effectList,
		brush: [sel.pathAttributes.brush, sel.pathAttributes.brushColor],
		fill: [sel.pathAttributes.fill, sel.pathAttributes.fillColor]
	};