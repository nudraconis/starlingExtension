package starling
{
	import starling.core.RenderSupport;
	
	import swfdata.MovieClipData;

	public class AnimationRenderer extends SWFView
	{
		
		private var _currentFrame:int = 0;
		public function AnimationRenderer() {
			super();
		}
		
		public function get totalFrames():int
		{
			return (viewData as MovieClipData)? (viewData as MovieClipData).framesCount : 1;
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (value < totalFrames)
				_currentFrame = value;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			(viewData as MovieClipData).gotoAndStop(_currentFrame);
			super.render(support, parentAlpha);
		}

	}
}