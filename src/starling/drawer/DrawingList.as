package starling.drawer 
{
	import swfdata.ColorData;
	import swfdata.atlas.ITexture;
	
	public class DrawingList 
	{
		public var data:Vector.<Number>;
		public var length:int = 0;
		public var registersSize:int = 0;
		public var registersMaxSize:int = 0;
		public var isFull:Boolean;
		
		public function DrawingList(size:int) 
		{
			registersMaxSize = size;
			data = new Vector.<Number>(registersMaxSize * 4, true);
		}
		
		public function clear():void
		{
			length = 0;
			registersSize = 0;
			isFull = false;
		}
		
		[Inline]
		public final function addDrawingData(a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, texture:ITexture, colorData:ColorData):void
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
			
			data[length++] = colorData.r;
			data[length++] = colorData.g;
			data[length++] = colorData.b;
			data[length++] = colorData.a;
			
			registersSize += 4;
			
			isFull = registersSize == registersMaxSize;
		}
	}
}