package starling.drawer
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import starling.drawer.ProjectionMatrix;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import swfdata.ColorData;
	import swfdata.atlas.ITexture;
	
	public class StarlingRenderer extends DisplayObject
	{
		private static var HELPER_BUFFER:Vector.<Number> = new Vector.<Number>(16, true);
	
		private var shaderProgramm:Program3D;
		
		private var context3D:Context3D;
		
		private var batchRegistersSize:int = (128 - 1);
		private var batchConstantsSize:int = batchRegistersSize * 4;
		private var batchSize:int = batchRegistersSize / 4;
		
		private var drawingGeometry:BatchMesh = new BatchMesh(batchSize);
		
		private var texturesDrawList:Vector.<ITexture> = new Vector.<ITexture>(200000, true);
		private var texturesListSize:int = 0;
		
		private var drawingList:Vector.<Number> = new Vector.<Number>(200000, true);
		private var drawingListSize:int = 0;
		
		private var projection:ProjectionMatrix = new ProjectionMatrix().ortho(800, 800, null);
		
		private var currentTexture:TextureBase = null;
		
		public function StarlingRenderer()
		{
			super();
			
			drawingGeometry.uploadToGpu(Starling.context);
			Starling.current.enableErrorChecking = true;
		}
		
		public function draw(texture:ITexture, matrix:Matrix, colorData:ColorData):void
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
			
			drawingList[drawingListSize++] = a;
			drawingList[drawingListSize++] = c;
			drawingList[drawingListSize++] = b;
			drawingList[drawingListSize++] = d;
			
			drawingList[drawingListSize++] = tx;
			drawingList[drawingListSize++] = ty;
			drawingList[drawingListSize++] = texture.width;
			drawingList[drawingListSize++] = texture.height;
			
			drawingList[drawingListSize++] = texture.u;
			drawingList[drawingListSize++] = texture.v;
			drawingList[drawingListSize++] = texture.uscale;
			drawingList[drawingListSize++] = texture.vscale;
			
			drawingList[drawingListSize++] = colorData.r;
			drawingList[drawingListSize++] = colorData.g;
			drawingList[drawingListSize++] = colorData.b;
			drawingList[drawingListSize++] = colorData.a;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle 
		{
			return new Rectangle();
		}
		
		private function setTexture(texture:TextureBase, context3D:Context3D):void
		{
			if (currentTexture == texture)
				return;
				
			currentTexture = texture;
			context3D.setTextureAt(0, currentTexture);
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			var context:Context3D = Starling.context;
			
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgram(getProgram());
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			
			drawingGeometry.setToContext(context);
			
			var drawsNum:int = int(drawingListSize / batchRegistersSize);
			
			var currentTexture:TextureBase = texturesDrawList[0].gpuData;
			setTexture(currentTexture, context);
			
			trace('current draw', drawsNum, batchSize, texturesListSize);
			
			var totalRegisters:int = drawingListSize * 4;
			
			for (var i:int = 0; i < drawsNum; i++)
			{
				var registersToDraw:int = batchRegistersSize;
				var constantsOffset:int = 4 + i * batchSize;
				
				if (registersToDraw > totalRegisters)
					registersToDraw = totalRegisters;
					
				totalRegisters -= registersToDraw;
				
				trace("draw", constantsOffset, constantsSize);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, constantsOffset, drawingList, totalRegisters);
				context.drawTriangles(drawingGeometry.indexBuffer);
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
								//+	"mul	ft0		ft0			fc0 		\n"
								+	"mov	oc		ft0						  ";
									
				program = target.registerProgramFromSource(programName, vertexShader, fragmentShader);
			}
			
			return program;
		}
	}
}