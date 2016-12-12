package 
{
	import fastByteArray.SlowByteArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import swfDataExporter.GLSwfExporter;
	
	import swfdata.atlas.BitmapSubTexture;
	import swfdata.atlas.BitmapTextureAtlas;
	import swfdata.atlas.gl.GLTextureAtlas;
	import swfdata.dataTags.SwfPackerTag;
	
	import swfparser.SwfDataParser;
	import swfparser.SwfParserLight;
	
	import util.MaxRectPacker;
	import util.PackerRectangle;
	
	public class TestExporingStarling extends Sprite 
	{
		private var fileName:String = "testBitmap";
		
		private var fileContent:ByteArray;
		private var swfDataParser:SwfDataParser;
		private var packedAtlas:BitmapTextureAtlas;
		//private var maxRectPacker:MaxRectPacker = new MaxRectPacker(2048, 2048);
		private var maxRectPacker:MaxRectPacker = new MaxRectPacker(2048, 2048);
		private var data:SlowByteArray;
		//private var data:IByteArray = new FastByteArray(null, 1024*100000);
		private var swfExporter:GLSwfExporter;
		private var file:File;
		
		private var scene:StarlinScene;
		
		public function TestExporingStarling() 
		{
			super();
			
			DebugCanvas.current = graphics;
			
			file = File.documentsDirectory.resolvePath("packer/swf/" + fileName + ".swf");
			var t:Timer = new Timer(1000, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, onStartParse);
			t.start();
			
			//browseContetn();

			/*var t:Timer = new Timer(1000, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, loadAnimation);
			t.start();*/
		}
		
		private function onStartParse(e:TimerEvent = null):void 
		{
			openAndLoadContent();
			
			parseSwfData();
		
			//loadAnimation();
			//unpackData();
		}
		
		private function onSwfParseComplete(e:Event):void 
		{
			trace("onSwfParseComplete");
			packRectangles();
			rebuildAtlas();
			packData();
			saveAnimation();
			
			var t:Timer = new Timer(1000, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, loadAnimation);
			t.start();
		}
		
		private function browseContetn():void 
		{
			//file = new File("D:\panda\village\trunk-static\root\swf\actor\skin_summer\complex_decor");//File.applicationDirectory.clone();
			
			file = File.applicationDirectory;
			file.browseForOpen("Select animation file", [new FileFilter("swf file with animation", "*.swf", "*.swf")]);
			file.addEventListener(Event.SELECT, onSelected);
		}
		
		private function onSelected(e:Event):void 
		{
			onStartParse();
		}
		
		private function unpackData():void 
		{
			//swfDataParser.packerTags.length = 0;
			//data.position = 0;
			//var atlas:BitmapTextureAtlas = swfExporter.importSwf(data, swfDataParser.context.shapeLibrary, swfDataParser.packerTags);
			
			scene = new StarlinScene();
			scene.addEventListener(Event.COMPLETE, onSceneReady);
			
			stage.addChild(scene);
		}
		
		private function onSceneReady(e:Event):void 
		{
			swfExporter = new GLSwfExporter();
			var swfParserLight:SwfParserLight = new SwfParserLight();
			var swfTags:Vector.<SwfPackerTag> = new Vector.<SwfPackerTag>;
	
			data.position = 0;
			
			var glTextureAtlas:GLTextureAtlas = swfExporter.importAnimation("noname", data, swfParserLight.context.shapeLibrary, swfTags, Context3DTextureFormat.BGRA) as GLTextureAtlas;
			
			swfParserLight.context.library.addShapes(swfParserLight.context.shapeLibrary);
			swfParserLight.processDisplayObject(swfTags);		
			
			scene.show(swfParserLight.context.library, glTextureAtlas);
			
			data.clear();
		}
		
		private function packData():void 
		{
			swfExporter = new GLSwfExporter();
			
			trace("### PACKED ATLAS ###");
			trace(packedAtlas.width, packedAtlas.height);
			
			data = new SlowByteArray(null, 1024*100000);

			swfExporter.exportAnimation(packedAtlas, swfDataParser.context.shapeLibrary, swfDataParser.packerTags, data);
			swfDataParser.clear();
		}
		
		private function saveAnimation():void
		{
			var file:File = File.documentsDirectory.resolvePath("packer/packed/" + fileName + ".animation");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			
			fileContent = new ByteArray();
			data.position = 0;
			data.byteArray.endian = fileContent.endian = Endian.LITTLE_ENDIAN;
			fileStream.writeBytes(data.byteArray, 0, data.length);
			fileStream.close();
			
			//data.clear();
		}
		
		private function loadAnimation(e:Event = null):void {
			if (data) {
				data.clear();
				data = null;
			}
			if (fileContent) {
				fileContent.clear();
				fileContent = null;
			}
			file = File.documentsDirectory.resolvePath("packer/packed/" + fileName + ".animation");
			openAndLoadContent();
			fileContent.position = 0;
			fileContent.endian = Endian.LITTLE_ENDIAN;
			data = new SlowByteArray(fileContent);
			unpackData();
		}
		
		private function rebuildAtlas():void 
		{
			var atlasSoruce:BitmapData = maxRectPacker.drawAtlas(0);
			packedAtlas = new BitmapTextureAtlas(atlasSoruce.width, atlasSoruce.height, 4);
			packedAtlas.data = atlasSoruce;
			
			var rects:Vector.<PackerRectangle> = maxRectPacker.atlasDatas[0].rectangles;
			
			
			for (var i:int = 0; i < rects.length; i++)
			{
				var currentRegion:PackerRectangle = rects[i];
				
				var region:Rectangle = new Rectangle();
				region.setTo(currentRegion.x, currentRegion.y, currentRegion.width, currentRegion.height);
				
				packedAtlas.createSubTexture(currentRegion.id, region, currentRegion.scaleX, currentRegion.scaleY);
			}
			//WindowUtil.openWindowToReview(packedAtlas.atlasData);
			
			//addChild(new Bitmap(atlasSoruce));
			
			maxRectPacker.clearData();
		}
		
		private function packRectangles():void 
		{
			var rectangles:Vector.<PackerRectangle> = new Vector.<PackerRectangle>;
			
			var atlas:BitmapTextureAtlas = swfDataParser.context.atlasDrawer.targetAtlas;
			//WindowUtil.openWindowToReview(atlas.atlasData, "default atlas");
			
			for(var regionName:String in atlas.subTextures)
			{
				var subTexture:BitmapSubTexture = atlas.subTextures[int(regionName)];
				var region:Rectangle = subTexture.bounds;
				var packerRect:PackerRectangle = PackerRectangle.get(0, 0, region.width + atlas.padding * 2, region.height + atlas.padding * 2, subTexture.id, atlas.data, region.x - atlas.padding, region.y - atlas.padding);
				packerRect.scaleX = subTexture.transform.scaleX;
				packerRect.scaleY = subTexture.transform.scaleY;
				
				rectangles.push(packerRect);
			}
			
			maxRectPacker.clearData();
			maxRectPacker.packRectangles(rectangles, 0, 2);		
		}
		
		private function parseSwfData():void 
		{
			swfDataParser = new SwfDataParser();
			swfDataParser.addEventListener(Event.COMPLETE, onSwfParseComplete);
			
			swfDataParser.parseSwf(fileContent, false);
			fileContent.clear();
		}
		
		private function openAndLoadContent():void 
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			fileContent = new ByteArray();
			fileStream.readBytes(fileContent, 0, fileStream.bytesAvailable);
			fileStream.close();
		}	
		
	
	}
}