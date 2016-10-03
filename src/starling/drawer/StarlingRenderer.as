package starling.drawer
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import swfdata.ColorData;
	import swfdata.atlas.BaseSubTexture;
	
	public class StarlingRenderer extends DisplayObject
	{	
		private static const DEFAULT_THRESHOLD:Number = 0.1;
		private static const MAX_VERTEX_CONSTANTS:int = 128;//may change in different profiles
		
		private var batchRegistersSize:int = (MAX_VERTEX_CONSTANTS - 4);
		private var batchConstantsSize:int = batchRegistersSize * 4;
		private var batchSize:int = batchRegistersSize / 4;
		
		private var drawingGeometry:BatchMesh = new BatchMesh(batchSize);
		
		private var fragmentData:Vector.<Number> = new <Number>[0, 0, 0, DEFAULT_THRESHOLD];
		
		private var texturesDrawList:Vector.<BaseSubTexture> = new Vector.<BaseSubTexture>(200000, true);
		private var texturesListSize:int = 0;
		
		private var drawingList:Vector.<DrawingList> = new Vector.<DrawingList>(1000, true);
		private var drawingListSize:int = 0;
		
		private var currentTexture:TextureBase = null;
		
		public function StarlingRenderer()
		{
			super();
			
			this.blendMode = BlendMode.NORMAL;
			drawingGeometry.uploadToGpu(Starling.context);
			//Starling.current.enableErrorChecking = false;
		}
		
		public function set alphaThreshold(value:Number):void
		{
			fragmentData[3] = value;
		}
		
		public function get alphaThreshold():Number
		{
			return fragmentData[3];
		}
		
		[Inline]
		public final function draw(texture:BaseSubTexture, matrix:Matrix, colorData:ColorData):void
		{
			texturesDrawList[texturesListSize++] = texture;
		
			var a:Number = matrix.a;
			var b:Number = matrix.b;
			var c:Number = matrix.c;
			var d:Number = matrix.d;
			var tx:Number = matrix.tx;
			var ty:Number = matrix.ty;
			
			var pivotX:Number = texture.pivotX;
			var pivotY:Number = texture.pivotY;
			
			if (pivotX != 0 || pivotY != 0) 
			{
				tx = tx - pivotX * a - pivotY * c;
				ty = ty - pivotX * b - pivotY * d;
			}
			
			//TODO: менять лист ка ктолько поменяется текстура
			var currentDrawingList:DrawingList = getDrawingList();
			
			if (currentDrawingList.isFull)
			{
				drawingListSize++;
				currentDrawingList = getDrawingList();
			}
			
			currentDrawingList.addDrawingData(a, b, c, d, tx, ty, texture, colorData);
		}
		
		[Inline]
		public final function getDrawingList():DrawingList
		{
			var currentDrawingList:DrawingList = drawingList[drawingListSize];
			
			if (currentDrawingList == null)
			{
				currentDrawingList = new DrawingList(batchRegistersSize);
				drawingList[drawingListSize] = currentDrawingList;
			}
			
			return currentDrawingList;
		}
		
		private static const rect:Rectangle = new Rectangle();
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle 
		{
			return rect;
		}
		
		[Inline]
		public final function setTexture(texture:TextureBase, context3D:Context3D):void
		{
			if (currentTexture == texture)
				return;
				
			currentTexture = texture;
			context3D.setTextureAt(0, currentTexture);
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			var context:Context3D = Starling.context;
			
			//premultiplied because textures is BitmapData
			RenderSupport.setBlendFactors(true, blendMode);
			//context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO); //normal
			//context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); //layer
			context.setProgram(getProgram());
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragmentData, 1);
			//context.setCulling(Context3DTriangleFace.BACK);
			
			drawingGeometry.setToContext(context);
			
			var currentTexture:TextureBase = texturesDrawList[0].gpuData;
			setTexture(currentTexture, context);

			var triangleToRegisterRate:Number = 0.5;
			var length:int = drawingListSize + 1;
			for (var i:int = 0; i < length; i++)
			{	
				var currentDrawingList:DrawingList = drawingList[i];
				var trianglesNum:int = currentDrawingList.registersSize * triangleToRegisterRate;
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, currentDrawingList.data, currentDrawingList.registersSize);
				context.drawTriangles(drawingGeometry.indexBuffer, 0, trianglesNum);
				
				currentDrawingList.clear();
			}
			
			drawingListSize = 0;
			texturesListSize = 0;
		}
		
		private function getProgram():Program3D
		{
			var target:Starling = Starling.current;
			var programName:String = "dynamicDrawing";
			
			//if (mTexture)
			//	programName = getImageProgramName(tinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);
			
			var program:Program3D = target.getProgram(programName);
			
			if (!program)
			{	
				var vertexShader:String;
				var fragmentShader:String;
				
				vertexShader =
								"mov		vt0			va2									\n" +
								"mov		vt0			va0									\n" +

								"mul		vt1			va0.xy		vc[va2.x+1].zw		\n" +

								"mul		vt2			vt1.xy		vc[va2.x].xy			\n" +
								"add		vt2.x		vt2.x		vt2.y					\n" +
								"add		vt2.x		vt2.x		vc[va2.x+1].x			\n" +

								"mul		vt3			vt1.xy		vc[va2.x].zw			\n" +
								"add		vt3.x		vt3.x		vt3.y					\n" +
								"add		vt3.x		vt3.x		vc[va2.x+1].y			\n" +

								"mov		vt2.y		vt3.x								\n" +

								"mov		vt2.zw		vt0.zw								\n" +
								
								"m44		vt3			vt2			vc0						\n" +
								
								//"mov vt3.z		va2.y			\n" +
								"mov		op			vt3									\n" +

								"mul		vt0.xy		va1.xy		vc[va2.x+2].zw		\n" +
								"add		vt0.xy		vt0.xy		vc[va2.x+2].xy		\n" +

								"mov		v0			vt0									\n"+
								"mov		v1			vc[va2.x+3]";
					
				fragmentShader = 	"tex 	ft0		v0			fs0	<2d, clamp, linear>	\n"	
								+	"mul	ft0		ft0			v1						\n"
								+	"sub	ft1		ft0			fc0						\n"
								+	"kil	ft1.w										\n"
								//+	"mul	ft0		ft0			fc0 		\n"
								+	"mov	oc		ft0						  ";
									
				program = target.registerProgramFromSource(programName, vertexShader, fragmentShader);
			}
			
			return program;
		}
	}
}
