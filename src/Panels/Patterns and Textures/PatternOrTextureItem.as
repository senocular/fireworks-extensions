import flash.geom.*;
import flash.display.BitmapData;

class PatternOrTextureItem extends MovieClip {
	var name_txt:TextField;
	var background_mc:MovieClip;
	var source_mc:MovieClip;
	var preview_mc:MovieClip;
	
	var loadListener:Object;
	var loader_mcl:MovieClipLoader;
		
	static var selected:PatternOrTextureItem;
	
	// constructor
	function PatternOrTextureItem(){
		name_txt.autoSize = true;
		var selection_color:Color = new Color(background_mc);
		selection_color.setRGB( _global.colorRef.controlFaceColor );
		name_txt.textColor = _global.colorRef.textColor;
	}
	
	function resize(container:mx.containers.ScrollPane):Void {
		background_mc._width = container.width - 20;
	}
	
	function setName(name:String):Void {
		name_txt.text = name;
	}
	
	function loadPatternOrTexture(url:String):Void {
		createEmptyMovieClip("source_mc", 1);
		source_mc._alpha = 0;
		loadListener = new Object();
		loadListener.onLoadInit = mx.utils.Delegate.create(this, generatePreview);
		
		loader_mcl = new MovieClipLoader();
		loader_mcl.addListener(loadListener);
		loader_mcl.loadClip(url, source_mc);
	}
	
	function generatePreview(Void):Void {
		var baseMatrix:Matrix = new Matrix();
		var baseColorTransform:ColorTransform = new ColorTransform();
		var baseObject:Object = new Object();
		
		var sourceBitmap:BitmapData = new BitmapData(source_mc._width, source_mc._height, false, 0xFFFFFFFF);
		var sourceRect:Rectangle = new Rectangle(0, 0, source_mc._width, source_mc._height);
		sourceBitmap.draw(source_mc, baseMatrix, baseColorTransform, baseObject, sourceRect, false);
		source_mc.removeMovieClip();
		
		createEmptyMovieClip("preview_mc", 1);
		preview_mc._y = 20;
		with (preview_mc){
			 beginBitmapFill(sourceBitmap, baseMatrix, true, false);
			 lineStyle(1, 0);
			 moveTo(0, 30);
			 lineTo(0, 0);
			 lineTo(100, 0);
			 lineTo(100, 30);
			 lineTo(0, 30);
		}
	}
	
	function onRelease(){
		if (_global.selectedType == "Patterns"){
			MMExecute(_root.jsf.setPattern_txt.text);
		}else{
			MMExecute(_root.jsf.setTexture_txt.text);
		}
		MMExecute('setSelection("'+name_txt.text+'");');
	
		this.select();
	}
	
	function select(){
		removeSelection();
		var selection_color:Color = new Color(background_mc);
		selection_color.setRGB( _global.colorRef.hilightItemColor );
		name_txt.textColor = _global.colorRef.hilightTextColor;
		selected = this;
	}
	
	static function removeSelection(){
		if (selected){
			var selection_color:Color = new Color(selected.background_mc);
			selection_color.setRGB( _global.colorRef.controlFaceColor );
			selected.name_txt.textColor = _global.colorRef.textColor;
			selected = null;
		}
	}
}