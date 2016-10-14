package starling.drawer 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	
	public class BlendMode 
	{
		public static const NORMAL:BlendMode	= new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		public static const LAYER:BlendMode		= new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		public static const MULTIPLY:BlendMode	= new BlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		public static const ADD:BlendMode		= new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
		public static const ALPHA:BlendMode		= new BlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);
		public static const SCREEN:BlendMode	= new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR);
		public static const ERASE:BlendMode	= new BlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		
		private static const _blendModesList:Vector.<BlendMode> = new Vector.<BlendMode>();
		public static function getBlendModesList():Vector.<BlendMode>
		{
			if (_blendModesList.length == 0)
			{
				_blendModesList[0] = BlendMode.NORMAL;
				_blendModesList[1] = BlendMode.NORMAL;
				_blendModesList[2] = BlendMode.LAYER;
				_blendModesList[3] = BlendMode.MULTIPLY;
				_blendModesList[4] = BlendMode.SCREEN;
				_blendModesList[5] = BlendMode.NORMAL; //LIGHTEN
				_blendModesList[6] = BlendMode.NORMAL; //DARKEN
				_blendModesList[7] = BlendMode.NORMAL; //DIFFERENCE
				_blendModesList[8] = BlendMode.ADD;
				_blendModesList[9] = BlendMode.NORMAL; //SUBTRACT
				_blendModesList[10] = BlendMode.NORMAL; //INVERT
				_blendModesList[11] = BlendMode.ALPHA;
				_blendModesList[12] = BlendMode.ERASE;
				_blendModesList[13] = BlendMode.NORMAL; //OVERLAY
				_blendModesList[14] = BlendMode.NORMAL; //HARDLIGHT
			}
			
			return _blendModesList;
		}
		
		public var src:String;
		public var dst:String;
		
		public function BlendMode(src:String, dst:String) 
		{
			this.dst = dst;
			this.src = src;
		}
	}
}