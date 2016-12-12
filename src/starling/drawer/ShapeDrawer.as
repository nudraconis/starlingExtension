package starling.drawer
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import swfdata.DisplayObjectData;
	import swfdata.ShapeData;
	import swfdata.swfdata_inner;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdrawer.data.DrawingData;
	
	use namespace swfdata_inner;
	
	public class ShapeDrawer extends Painter
	{
		private var drawMatrix:Matrix = new Matrix();
		
		public function ShapeDrawer(atlas:BaseTextureAtlas, mousePoint:Point, target:StarlingRenderer)
		{
			super(mousePoint, target);
			
			this.textureAtlas = atlas;
		}
		
		public function set atlas(value:BaseTextureAtlas):void
		{
			textureAtlas = value;
		}
		
		public override function draw(drawable:DisplayObjectData, drawingData:DrawingData):void
		{
			_draw(drawable, drawingData);
			
			drawMatrix.identity();
			
			if (drawable.transform)
			{
				GeomMath.concatMatrices(drawMatrix, drawable.transform, drawMatrix);
					//drawMatrix.concat(drawable.transform);
			}
			
			GeomMath.concatMatrices(drawMatrix, drawingData.transform, drawMatrix);
			//drawMatrix.concat(drawingData.transform);
			
			var drawableAsShape:ShapeData = drawable as ShapeData;
			
			drawRectangle(drawableAsShape._shapeBounds, drawMatrix);
			
			cleanDrawStyle();
		}
	}
}
