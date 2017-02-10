package starling.drawer 
{
	import swfdata.ColorData;
	import swfdata.atlas.BaseSubTexture;
	
	public class DrawingList 
	{
		private static const RGB_VALUE_TO_SHADER:Number = 1 / 0xff;
		private var registersPerGeometry:int;
		
		public var data:Vector.<Number>;
		public var length:int = 0;
		public var registersSize:int = 0;
		public var registersMaxSize:int = 0;
		public var isFull:Boolean;
		public var blendMode:int = 0;
		
		public function DrawingList(size:int, registersPerGeometry:int) 
		{
			this.registersPerGeometry = registersPerGeometry;
			registersMaxSize = size;
			data = new Vector.<Number>(registersMaxSize * 4, true);
		}
		
		[Inline]
		public final function clear():void
		{
			length = 0;
			registersSize = 0;
			isFull = false;
		}
		
		[Inline]
		public final function addDrawingData(a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, texture:BaseSubTexture, colorData:ColorData, alphaMultiplier:Number = 1):void
		{
			data[length++] = a;
			data[length++] = c;
			data[length++] = b;
			data[length++] = d;
			
			data[length++] = tx;
			data[length++] = ty;
			data[length++] = texture.width;
			data[length++] = texture.height;
			
			data[length++] = texture.u;
			data[length++] = texture.v;
			data[length++] = texture.uscale;
			data[length++] = texture.vscale;
			
			data[length++] = colorData.redMultiplier;
			data[length++] = colorData.greenMultiplier;
			data[length++] = colorData.blueMultiplier;
			data[length++] = colorData.alphaMultiplier * alphaMultiplier;
			
			data[length++] = colorData.redAdd * RGB_VALUE_TO_SHADER;
			data[length++] = colorData.greenAdd * RGB_VALUE_TO_SHADER
			data[length++] = colorData.blueAdd * RGB_VALUE_TO_SHADER
			data[length++] = colorData.alphaAdd * RGB_VALUE_TO_SHADER
			
			registersSize += registersPerGeometry;
			
			isFull = registersSize + registersPerGeometry > registersMaxSize;
		}
	}
}