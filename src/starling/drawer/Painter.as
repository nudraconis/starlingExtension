package starling.drawer 
{
	import flash.display.Graphics;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import swfdata.ColorData;
	import swfdata.DisplayObjectData;
	import swfdata.Rectagon;
	import swfdata.swfdata_inner;
	import swfdata.atlas.BaseSubTexture;
	import swfdata.atlas.BaseTextureAtlas;
	import swfdata.atlas.TextureTransform;
	import swfdrawer.IDrawer;
	import swfdrawer.data.DrawingData;
	
	use namespace swfdata_inner;

	public class Painter implements IDrawer
	{
		private var drawMatrix:Matrix = new Matrix();
		
		public var canvas:Graphics;
		
		//TODO: заменить на объект типа Options с параметрами такого типа
		public var isDebugDraw:Boolean = false;
		public var checkMouseHit:Boolean = false;
		public var checkBounds:Boolean = false;
		public var hitTestResult:Boolean = false;
		
		private var currentBoundForDraw:Rectangle = new Rectangle();
		private var drawingRectagon:swfdata.Rectagon;
		
		private var textureId:int;
		private var currentSubTexture:BaseSubTexture;
		
		private var mousePoint:Point;
		private var transformedMousePoint:Point = new Point();
		
		private var texturePadding:Number;
		private var texturePadding2:Number;
		
		protected var textureAtlas:BaseTextureAtlas;
		
		private var drawingData:DrawingData;
		private var target:StarlingRenderer;
		
		public function Painter(mousePoint:Point, target:StarlingRenderer) 
		{
			this.target = target;
			this.mousePoint = mousePoint;
			drawingRectagon = new Rectagon(0, 0, 0, 0, drawMatrix);
		}
		
		public function clearMouseHitStatus():void
		{
			hitTestResult = false;
		}
		
		/**
		 * Apply sub texture draw transform
		 */
		[Inline]
		public final function applyDrawStyle():void
		{
			//trace('apply daraw', textureId);
			
			currentSubTexture = textureAtlas.getTexture(textureId) as BaseSubTexture;
			
			var transform:TextureTransform = currentSubTexture.transform;
			var mulX:Number = transform.positionMultiplierX;
			var mulY:Number = transform.positionMultiplierY;
			
			//TODO: если эта дата считается уже в ShapeLibrary и в итоге сохраняется уже умноженой, то поидеи этот момент не нужен
			/**
			 * Т.е
			 * 
			 * Мы берем шейпы как они были например баунд 10, 10, 100, 100
			 * После рисования в аталс и расчета его размеров со скейлом мы выесняем что он рисуется в
			 * 5, 5, 50, 50 размерах
			 * т.к в ShapeLibrary уже посчитан новый размер шейпа и размер текстуры ему соотвествует без скейла то этот скейл сдесь не нужен
			 * 
			 * Далее, для баунда считается хит тест, для этого нужно востановить баунд от скейла, что и делается в коде ниже т.е тут монжо довольно
			 * много операций исключить.
			 * 
			 * Вместе с тем еще можно пивоты текстур сразу сдвинуть в левый врехний угол
			 */
			drawMatrix.a *= mulX;
			drawMatrix.d *= mulY;
			drawMatrix.b *= mulX;
			drawMatrix.c *= mulY;
		}
		
		public function cleanDrawStyle():void
		{
			textureId = -1;
			currentSubTexture = null;
		}
		
		public function draw(drawable:DisplayObjectData, drawingData:DrawingData):void 
		{
			trace("call daraw");
		}
		
		[Inline]
		public final function _draw(drawable:DisplayObjectData, drawingData:DrawingData):void 
		{
			this.drawingData = drawingData;
			
			drawingData.setFromDisplayObject(drawable);
			
			textureId = drawable.characterId;
			//this.texturePadding = textureAtlas.padding;
			this.texturePadding2 = textureAtlas.padding * 2;
			//textureAtlas = atlas;
		}
		
		[Inline]
		public final function drawDebugInfo():void
		{
			if (drawingData.bound && hitTestResult)
			{
				canvas.lineStyle(1.6, 0xFF0000, 0.8);
				canvas.drawRect(drawingRectagon.x, drawingRectagon.y, drawingRectagon.width, drawingRectagon.height);
				
				canvas.lineStyle(1.6, 0x00FF00, 0.8);
				canvas.moveTo(drawingRectagon.resultTopLeft.x, drawingRectagon.resultTopLeft.y);
				canvas.lineTo(drawingRectagon.resultTopRight.x, drawingRectagon.resultTopRight.y);
				canvas.lineTo(drawingRectagon.resultBottomRight.x, drawingRectagon.resultBottomRight.y);
				canvas.lineTo(drawingRectagon.resultBottomLeft.x, drawingRectagon.resultBottomLeft.y);
				canvas.lineTo(drawingRectagon.resultTopLeft.x, drawingRectagon.resultTopLeft.y);
			}
		}
		
		[Inline]
		public final function drawHitBounds(deltaX:Number, deltaY:Number, transformedDrawingX:Number, transformedDrawingY:Number, transformedDrawingWidth:Number, transformedDrawingHeight:Number, transformedPoint:Point):void
		{
			canvas.lineStyle(1.6, hitTestResult? 0xFF0000:(0xFFFFFF * (currentSubTexture.id / 100)), 0.8);
			canvas.moveTo(transformedDrawingX + deltaX, transformedDrawingY + deltaY);
			canvas.lineTo(transformedDrawingX + transformedDrawingWidth + deltaX, transformedDrawingY + deltaY);
			canvas.lineTo(transformedDrawingX + transformedDrawingWidth + deltaX, transformedDrawingY + transformedDrawingHeight + deltaY);
			canvas.lineTo(transformedDrawingX + deltaX, transformedDrawingY + transformedDrawingHeight + deltaY);
			canvas.lineTo(transformedDrawingX + deltaX, transformedDrawingY + deltaY);
			
			canvas.drawCircle(transformedPoint.x + deltaX, transformedPoint.y + deltaY, 5);
		}
		
		[Inline]
		public final function hitTest(pixelPerfect:Boolean, texture:BaseSubTexture, transformedDrawingX:Number, transformedDrawingY:Number, transformedDrawingWidth:Number, transformedDrawingHeight:Number, transformedPoint:Point):Boolean
		{
			var isHit:Boolean = false;
			
			if (transformedPoint.x > transformedDrawingX && transformedPoint.x < transformedDrawingX + transformedDrawingWidth)
				if (transformedPoint.y > transformedDrawingY && transformedPoint.y < transformedDrawingY + transformedDrawingHeight)
					isHit = true;
					
			if (pixelPerfect && isHit)
			{
				var u:Number = (transformedPoint.x - transformedDrawingX) / (transformedDrawingWidth + texturePadding2);
				var v:Number = (transformedPoint.y - transformedDrawingY) / (transformedDrawingHeight + texturePadding2);
				
				isHit = texture.getAlphaAtUV(u, v) > 0x05;
			}
			
			return isHit;
		}
		
		[Inline]
		public final function setMaskData():void
		{
			//var isMask:Boolean = drawingData.isMask;
			//var isMasked:Boolean = drawingData.isMasked
			
			//if (isMask)
			//	Genome2D.g2d_instance.g2d_context.renderToStencil(1);	
			//else if(!isMask && !isMasked)
			//{
			//	if(Genome2D.g2d_instance.g2d_context.g2d_activeStencilLayer != 0)
			//		Genome2D.g2d_instance.g2d_context.renderToColor(0);
			//}
		}
		
		[Inline]
		public final function clearMaskData():void
		{
			//if (drawingData.isMask)
			//	Genome2D.g2d_instance.g2d_context.renderToColor(1);
		}
		
		[Inline]
		public final function drawRectangle(drawingBounds:Rectangle, transform:Matrix):void 
		{		
			drawMatrix.identity();
			
			GeomMath.concatMatrices(drawMatrix, transform, drawMatrix);
			//drawMatrix.concat(transform);
			
			applyDrawStyle();
			
			var texture:Texture = currentSubTexture.gpuData;
			
			var textureTransform:TextureTransform = currentSubTexture.transform;
			
			//TODO: можно вынести в тот же трансформ т.к это нужно всего единажды считать т.к это статические данные
			currentSubTexture.pivotX = -(drawingBounds.x * textureTransform.scaleX + (currentSubTexture.width - texturePadding2) / 2);
			currentSubTexture.pivotY = -(drawingBounds.y * textureTransform.scaleY + (currentSubTexture.height - texturePadding2) / 2);
			
			setMaskData();
				
			var isMask:Boolean = drawingData.isMask;
			
			var color:ColorData = drawingData.colorData;
			
			if(drawingData.isApplyColorTrasnform)
			{
				//filter = colorFilter.getColorFilter();
				//(filter as GColorMatrixFilter).setMatrix(drawingData.colorTransform.matrix);
			}
			
			target.draw(currentSubTexture, drawMatrix, color);
				
			clearMaskData();
			
			//transform mesh bounds to deformed mesh
			var transformedDrawingX:Number = drawingBounds.x * currentSubTexture.transform.scaleX;
			var transformedDrawingY:Number = drawingBounds.y * currentSubTexture.transform.scaleY;
			var transformedDrawingWidth:Number = (drawingBounds.width * 2 * currentSubTexture.transform.scaleX) / 2;
			var transformedDrawingHeight:Number = (drawingBounds.height * 2 * currentSubTexture.transform.scaleY) / 2;
			
			if (!isMask && checkBounds || isDebugDraw)
				drawingRectagon.setTo(transformedDrawingX, transformedDrawingY, transformedDrawingWidth, transformedDrawingHeight);
			
			if (!isMask && !hitTestResult && checkMouseHit)
			{
				//get inversion transform of current mesh and transform mouse point to its local coordinates
				//note doing it after set rectagon because we need not ivnerted transform
				drawMatrix.invert();
				GeomMath.transformPoint(drawMatrix, mousePoint.x, mousePoint.y, false, transformedMousePoint);
			
				hitTestResult = hitTest(true, currentSubTexture, transformedDrawingX, transformedDrawingY, transformedDrawingWidth, transformedDrawingHeight, transformedMousePoint);
				
				if (isDebugDraw)
					//may draw debug hit/bound visualisation
					drawHitBounds(400, 50, transformedDrawingX, transformedDrawingY, transformedDrawingWidth, transformedDrawingHeight, transformedMousePoint);
			}
			
			if (isDebugDraw)
				drawDebugInfo();
			
			if (!isMask && checkBounds)
			{
				currentBoundForDraw.setTo(drawingRectagon.x, drawingRectagon.y, drawingRectagon.width, drawingRectagon.height);
				GeomMath.rectangleUnion(drawingData.bound, currentBoundForDraw);
				
				//if (isDebugDraw)
				//{
				//	convas.lineStyle(1, 0x0000FF, 0.5);
				//	convas.drawRect(drawingData.bound.x, drawingData.bound.y, drawingData.bound.width, drawingData.bound.height);
				//}
			}
		}
	}
}