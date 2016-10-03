package starling 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.drawer.DisplayListDrawer;
	import starling.drawer.StarlingRenderer;
	import swfdata.SpriteData;
	import swfdata.atlas.gl.GLTextureAtlas;
	
	public class SWFView extends StarlingRenderer 
	{
		private var mousePoint:Point = new Point();
		private var drawer:DisplayListDrawer;
		
		private var transform:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
		private var _bounds:Rectangle = new Rectangle();
		
		private var viewData:SpriteData;
		
		public function SWFView() 
		{
			super();
		}
		
		override public function get x():Number 
		{
			return transform.tx;
		}
		
		override public function set x(value:Number):void 
		{
			transform.tx = value;
		}
		
		override public function get y():Number 
		{
			return transform.ty;
		}
		
		override public function set y(value:Number):void 
		{
			transform.ty = value;
		}
		
		public function show(viewData:SpriteData, texture:GLTextureAtlas):void 
		{
			this.viewData = viewData;
			
			this.atlas = texture;
			drawer = new DisplayListDrawer(texture, mousePoint, this);
			//drawer.debugConvas = DebugCanvas.current;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle 
		{
			return _bounds;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			if (!drawer)
				return;
				
			viewData.update();
			
			_bounds.setTo(0, 0, 0, 0);
			
			//mousePoint.x = transform.tx + 10;
			//mousePoint.y = transform.ty + 10;
			//DebugCanvas.current.clear();
			
			//drawer.checkMouseHit = drawer.checkBounds = drawer.debugDraw = true;
			drawer.drawDisplayObject(viewData, transform, _bounds);
			
			super.render(support, parentAlpha);
		}
	}
}
