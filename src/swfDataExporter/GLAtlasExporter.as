package swfDataExporter 
{
	import fastByteArray.IByteArray;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import swfdata.ShapeData;
	import swfdata.ShapeLibrary;
	import swfdata.atlas.ITextureAtlas;
	import swfdata.atlas.TextureTransform;
	import swfdata.atlas.gl.GLSubTexture;
	import swfdata.atlas.gl.GLTextureAtlas;
	
	public class GLAtlasExporter extends BaseSwfAtlasExporter implements ISwfAtlasExporter
	{
		public function GLAtlasExporter() 
		{
			
		}
		
		override public function importAtlas(name:String, input:IByteArray, shapesList:ShapeLibrary, format:String):ITextureAtlas 
		{
			var textureAtlas:GLTextureAtlas;
			
			var padding:int = input.readInt8();
			var bitmapSize:int = input.readInt32();
			var width:int = input.readInt16();
			var height:int = input.readInt16();
			
			bitmapBytes.length = 0;
			
			input.readBytes(bitmapBytes, 0, bitmapSize);
			
			if (width < 2 || height < 2)
				internal_trace("Error: somethink wrong with atlas data");
			
			var bitmapData:BitmapData = new BitmapData(width, height, true);
			bitmapData.setPixels(bitmapData.rect, bitmapBytes);
			
			//WindowUtil.openWindowToReview(bitmapData);
			
			textureAtlas = new GLTextureAtlas(name, bitmapData, format, padding);
			
			var texturesCount:int = input.readInt16();
			
			//trace('pre read', input.position);
			
			var r:Rectangle = new Rectangle();
			for (var i:int = 0; i < texturesCount; i++)
			{
				var id:int = input.readInt16();
				
				var textureTransform:TextureTransform = readTextureTransform(input);
				var textureRegion:Rectangle = readRectangle(input);
				var shapeBounds:Rectangle = readRectangle(input);
				
				shapesList.addShape(null, new ShapeData(id, shapeBounds));
				var texture:GLSubTexture = new GLSubTexture(id, textureRegion, textureTransform, textureAtlas);
				
				textureAtlas.putTexture(texture);
			}
			
			textureAtlas.reupload();
			
			return textureAtlas;
		}
	}
}