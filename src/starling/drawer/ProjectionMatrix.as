package starling.drawer 
{
	import flash.geom.Matrix3D;
	
	public class ProjectionMatrix extends Matrix3D
	{
		static public var NEAR:int = 0;
		static public var FAR:int = 4000;
		static private var g2d_instance:ProjectionMatrix;

		private var g2d_vector:Vector.<Number>;

		public function ProjectionMatrix(v:Vector.<Number>=null) 
		{
			super(v);
			
			g2d_vector = new <Number>[2.0, 0.0, 0.0, 0.0,
										 0.0, -2.0, 0.0, 0.0,
										 0.0, 0.0, 1/(FAR-NEAR), -NEAR/(FAR-NEAR),
										 -1.0, 1.0, 0, 1.0
										];
		}

		static public function getOrtho(p_width:Number, p_height:Number, p_transform:Matrix3D = null):ProjectionMatrix {
			if (g2d_instance == null) g2d_instance = new ProjectionMatrix();
			return g2d_instance.ortho(p_width, p_height, p_transform);
		}

		public function ortho(p_width:Number, p_height:Number, p_transform:Matrix3D = null):ProjectionMatrix {
			g2d_vector[0] = 2/p_width;
			g2d_vector[5] = -2/p_height;
			this.copyRawDataFrom(g2d_vector);

			if (p_transform != null) this.prepend(p_transform);

			return this;
		}

		public function perspective(p_width:Number, p_height:Number, zNear:Number, zFar:Number):ProjectionMatrix {
			this.copyRawDataFrom(new <Number>[2/p_width, 0.0, 0.0, 0.0,
												 0.0, -2/p_height, 0.0, 0.0,
												 0, 0, zFar/(zFar-zNear), 1.0,
												 0, 0, (zNear*zFar)/(zNear-zFar), 0
												]);

			return this;
		}
	}
}