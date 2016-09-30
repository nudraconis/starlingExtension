package starling.drawer 
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	public class BaseMesh 
	{
		public var vertexDataRaw:Vector.<Number> = new Vector.<Number>();
		public var uvDataRaw:Vector.<Number> = new Vector.<Number>();
		public var indexDataRaw:Vector.<uint> = new Vector.<uint>();
		
		public var vertexBuffer:VertexBuffer3D;
		public var uvBuffer:VertexBuffer3D;
		public var indexBuffer:IndexBuffer3D;
		
		public function BaseMesh() 
		{
			
		}
		
		public function uploadToGpu(context3D:Context3D):void
		{
			var verticesCount:int = int(vertexDataRaw.length / 3);
			
			if (vertexBuffer == null)
				vertexBuffer = context3D.createVertexBuffer(verticesCount, 3);
				
			vertexBuffer.uploadFromVector(vertexDataRaw, 0, verticesCount);
			
			if (uvBuffer == null)
				uvBuffer = context3D.createVertexBuffer(verticesCount, 2);
				
			uvBuffer.uploadFromVector(uvDataRaw, 0, verticesCount);
			
			if (indexBuffer == null)
				indexBuffer = context3D.createIndexBuffer(indexDataRaw.length);
				
			indexBuffer.uploadFromVector(indexDataRaw, 0, indexDataRaw.length);
		}
	}
}