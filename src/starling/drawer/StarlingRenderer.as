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
		private var drawingGeometry:BatchMesh = new BatchMesh(1);
		
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
			
			var quadsNum:int = int(drawingListSize / 16);
			
			for (var i:int = 0; i < quadsNum; i++)
			{
				var currentTexture:TextureBase = texturesDrawList[i].gpuData;
				setTexture(currentTexture, context);
				
				var offset:int = i * 16;
				
				HELPER_BUFFER[0] = drawingList[0 + offset];
				HELPER_BUFFER[1] = drawingList[1 + offset];
				HELPER_BUFFER[2] = drawingList[2 + offset];
				HELPER_BUFFER[3] = drawingList[3 + offset];
				HELPER_BUFFER[4] = drawingList[4 + offset];
				HELPER_BUFFER[5] = drawingList[5 + offset];
				HELPER_BUFFER[6] = drawingList[6 + offset];
				HELPER_BUFFER[7] = drawingList[7 + offset];
				HELPER_BUFFER[8] = drawingList[8 + offset];
				HELPER_BUFFER[9] = drawingList[9 + offset];
				HELPER_BUFFER[10] = drawingList[10 + offset];
				HELPER_BUFFER[11] = drawingList[11 + offset];
				HELPER_BUFFER[12] = drawingList[12 + offset];
				HELPER_BUFFER[13] = drawingList[13 + offset];
				HELPER_BUFFER[14] = drawingList[14 + offset];
				HELPER_BUFFER[15] = drawingList[15 + offset];
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, HELPER_BUFFER, 4);
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
								"mov vt0, va2						\n" +
								"mov vt0, va0						\n" +

								"mul vt1, va0.xy, vc5.zw			\n" +

								"mul vt2, vt1.xy, vc4.xy			\n" +
								"add vt2.x, vt2.x, vt2.y			\n" +
								"add vt2.x, vt2.x, vc5.x			\n" +

								"mul vt3, vt1.xy, vc4.zw			\n" +
								"add vt3.x, vt3.x, vt3.y            \n" +
								"add vt3.x, vt3.x, vc5.y			\n" +

								"mov vt2.y, vt3.x					\n" +

								"mov vt2.zw, vt0.zw					\n" +
								
								"m44 vt3, vt2, vc0					\n" +
								
								//"mov vt3.z		va2.y			\n" +
								"mov op			vt3					\n" +

								"mul vt0.xy, va1.xy, vc6.zw			\n" +
								"add vt0.xy, vt0.xy, vc6.xy			\n" +

								"mov v0, vt0						\n"+
								"mov v1, vc7";
					
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