package starling.drawer 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	
	public class BatchMesh extends BaseMesh 
	{
		public var orderBufferDataRaw:Vector.<Number> = new Vector.<Number>();
		public var orderBuffer:VertexBuffer3D;
		
		public function BatchMesh(batchSize:int) 
		{
			super();
			
			var vertexDataIndex:int = 0;
			var uvDataIndex:int = 0;
			var indexDataIndex:int = 0;
			var orderDataIndex:int = 0;
			var order:Number = 0;
				
			for (var i:int = 0; i < batchSize; i++)
			{
				vertexDataRaw[vertexDataIndex++] = -0.5;	vertexDataRaw[vertexDataIndex++] =  0.5;	vertexDataRaw[vertexDataIndex++] = 0.5;
				vertexDataRaw[vertexDataIndex++] = -0.5;	vertexDataRaw[vertexDataIndex++] = -0.5;	vertexDataRaw[vertexDataIndex++] = 0.5;
				vertexDataRaw[vertexDataIndex++] =  0.5;	vertexDataRaw[vertexDataIndex++] = -0.5;	vertexDataRaw[vertexDataIndex++] = 0.5;
				vertexDataRaw[vertexDataIndex++] =  0.5;	vertexDataRaw[vertexDataIndex++] =  0.5;	vertexDataRaw[vertexDataIndex++] = 0.5;
				
				uvDataRaw[uvDataIndex++] = 0;	uvDataRaw[uvDataIndex++] = 1;
				uvDataRaw[uvDataIndex++] = 0;	uvDataRaw[uvDataIndex++] = 0;
				uvDataRaw[uvDataIndex++] = 1;	uvDataRaw[uvDataIndex++] = 0;
				uvDataRaw[uvDataIndex++] = 1;	uvDataRaw[uvDataIndex++] = 1;
				
				indexDataRaw[indexDataIndex++] = 4 * i;	indexDataRaw[indexDataIndex++] = 4 * i + 1;	indexDataRaw[indexDataIndex++] = 4 * i + 2;
				indexDataRaw[indexDataIndex++] = 4 * i;	indexDataRaw[indexDataIndex++] = 4 * i + 2;	indexDataRaw[indexDataIndex++] = 4 * i + 3;
				
				order = 4 + (i * 4);
				
				orderBufferDataRaw[orderDataIndex++] = order;	//orderBufferDataRaw[orderDataIndex++] = order;
				orderBufferDataRaw[orderDataIndex++] = order;	//orderBufferDataRaw[orderDataIndex++] = order;
				orderBufferDataRaw[orderDataIndex++] = order;	//orderBufferDataRaw[orderDataIndex++] = order;
				orderBufferDataRaw[orderDataIndex++] = order;	//orderBufferDataRaw[orderDataIndex++] = order;
			}
		}
		
		override public function uploadToGpu(context3D:Context3D):void 
		{
			super.uploadToGpu(context3D);
			
			var verticesCount:int = int(vertexDataRaw.length / 3);
			
			if (orderBuffer == null)
				orderBuffer = context3D.createVertexBuffer(verticesCount, 1);
			
			orderBuffer.uploadFromVector(orderBufferDataRaw, 0, verticesCount); 
		}
		
		public function setToContext(context3D:Context3D):void 
		{
			context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context3D.setVertexBufferAt(1, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2, orderBuffer, 0, Context3DVertexBufferFormat.FLOAT_1);
		}
	}
}