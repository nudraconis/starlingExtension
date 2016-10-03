package starling.drawer 
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import swfdata.ColorData;
	import swfdata.DisplayObjectData;
	import swfdata.DisplayObjectTypes;
	import swfdata.swfdata_inner;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdrawer.IDrawer;
	import swfdrawer.MovieClipDrawer;
	import swfdrawer.SpriteDrawer;
	import swfdrawer.data.DrawingData;
	
	use namespace swfdata_inner;
	
	public class DisplayListDrawer implements IDrawer
	{
		private var drawersMap:Dictionary = new Dictionary();
		private var mousePoint:Point;
		private var shapeDrawer:ShapeDrawer;
		
		private var drawingData:DrawingData = new DrawingData();
		
		private var _atlas:BaseTextureAtlas;
		private var target:StarlingRenderer;
		
		public function DisplayListDrawer(atlas:BaseTextureAtlas = null, mousePoint:Point = null, target:StarlingRenderer = null) 
		{
			this.target = target;
			this.mousePoint = mousePoint;
			
			_atlas = atlas;
			initialize();
		}
		
		public function set atlas(atlas:BaseTextureAtlas):void
		{
			_atlas = atlas;
			shapeDrawer.atlas = atlas;
		}
		
		/**
		 * Define is drawer should calculate full bound of object - Union of bound for every child
		 */
		public function set checkBounds(value:Boolean):void
		{
			shapeDrawer.checkBounds = value;
		}
		
		/**
		 * Define is drawer should do mouse hit test
		 * 
		 */
		public function set checkMouseHit(value:Boolean):void
		{
			shapeDrawer.checkMouseHit = value;
		}
		
		/**
		 * Define is drawer should draw debug data
		 */
		public function set debugDraw(value:Boolean):void
		{
			shapeDrawer.isDebugDraw = value;
		}
		
		public function get isHitMouse():Boolean
		{
			return shapeDrawer.hitTestResult;
		}
		
		private function initialize():void 
		{
			shapeDrawer = new ShapeDrawer(_atlas, mousePoint, target);
			
			var spriteDrawer:SpriteDrawer = new SpriteDrawer(this);
			var movieClipDrawer:MovieClipDrawer = new MovieClipDrawer(this);
			
			drawersMap[DisplayObjectTypes.SHAPE_TYPE] = shapeDrawer;
			drawersMap[DisplayObjectTypes.SPRITE_TYPE] = spriteDrawer;
			drawersMap[DisplayObjectTypes.MOVIE_CLIP_TYPE] = movieClipDrawer;
		}
		
		public function clear():void
		{
			shapeDrawer.clearMouseHitStatus();
			drawingData.clear();
		}
		
		public function drawDisplayObject(displayObject:DisplayObjectData, transform:Matrix, bound:Rectangle = null, colorData:ColorData = null):void
		{
			clear();
			
			drawingData.transform = transform;
			drawingData.bound = bound;
			
			if(colorData != null)
				drawingData.colorData.mulColorData(colorData);
			else if(displayObject.colorData)
				drawingData.colorData.mulColorData(displayObject.colorData);
			
			draw(displayObject, drawingData);
		}
		
		[Inline]
		public final function draw(displayObject:DisplayObjectData, drawingData:DrawingData):void
		{
			var type:int = displayObject.displayObjectType;
			
			var drawer:IDrawer = drawersMap[type];
			
			if (drawer)
				drawer.draw(displayObject, drawingData);
			else
			{
				CONFIG::debug
				{
					throw new Error("drawer for " + displayObject + " is not defined");
				}
				
				CONFIG::release
				{
					trace("drawer for " + displayObject + " is not defined");
				}
			}
		}
		
		/**
		 * Задает таргет для отрисовки дебаг даты
		 */
		public function set debugCanvas(value:Graphics):void 
		{
			shapeDrawer.canvas = value;
		}
	}
}