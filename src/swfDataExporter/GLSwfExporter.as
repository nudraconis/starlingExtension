package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	
	public class GLSwfExporter 
	{
		private var atlasExporter:GLAtlasExporter = new GLAtlasExporter();
		private var dataExporter:SwfTagExporter = new SwfTagExporter();
		
		public function GLSwfExporter() 
		{
			
		}
		
		public function exportAnimation(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, output:IByteArray):IByteArray
		{
			output.begin();
			
			atlasExporter.exportAtlas(atlas, shapesList, output);
			//output.position = output.byteArray.position;
			trace("EXPORT POS", output.position);
			var atlasPart:int = output.position;
			
			
			dataExporter.exportTags(tagsList, output);
			
			
			output.end(true);
			
			output.length = output.position;
			
			trace("swf data size", atlasPart, output.length);
			
			output.byteArray.deflate();
			
			trace('compress', output.byteArray.length);
			
			return output;
		}
		
		public function importSwf(name:String, input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, format:String):BaseTextureAtlas
		{
			return null;
		}
		
		public function importAnimation(name:String, input:IByteArray, shapesList:ShapeLibrary, tagsList:Vector.<SwfPackerTag>, format:String):BaseTextureAtlas
		{
			input.byteArray.inflate();
			
			input.begin();
			
			var atlas:BaseTextureAtlas = atlasExporter.importAtlas(name, input, shapesList, format);
			
			dataExporter.importTags(tagsList, input);
			
			input.end(true);
			
			return atlas;
		}	
	}
}