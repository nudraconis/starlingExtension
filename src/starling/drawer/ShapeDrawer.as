package starling.drawer 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import swfdata.DisplayObjectData;
	import swfdata.ShapeData;
	import swfdata.swfdata_inner;
	import swfdata.atlas.ITextureAtlas;
	import swfdrawer.data.DrawingData;
	
	use namespace swfdata_inner;
	
	public class ShapeDrawer extends Painter
	{
		private var drawMatrix:Matrix = new Matrix();
		
		public function ShapeDrawer(atlas:ITextureAtlas, mousePoint:Point, target:StarlingRenderer) 
		{
			super(mousePoint, target);
			
			this.textureAtlas = atlas;
		}
		
		public function set atlas(value:ITextureAtlas):void
		{
			textureAtlas = value;
		}
		
		override public function draw(drawable:DisplayObjectData, drawingData:swfdrawer.data.DrawingData):void 
		{
			super.draw(drawable, drawingData);
			
			drawMatrix.identity();
			
			if (drawable.transform)
			{
				drawMatrix.concat(drawable.transform);
			}
				
			drawMatrix.concat(drawingData.transform);
			
			var drawableAsShape:ShapeData = drawable as ShapeData;
			
			drawRectangle(drawableAsShape._shapeBounds, drawMatrix);
			
			cleanDrawStyle();
		}
	}
}
