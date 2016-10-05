package 
{
	import flash.geom.Matrix;
	
	import starling.AnimationRenderer;
	import starling.SWFView;
	import starling.display.Sprite;
	
	import swfdata.MovieClipData;
	import swfdata.SpriteData;
	import swfdata.SymbolsLibrary;
	import swfdata.atlas.gl.GLTextureAtlas;
	
	public class StarlingRoot extends Sprite 
	{
		
		public function StarlingRoot() 
		{
			super();
		}
		
		public function show(library:SymbolsLibrary, texture:GLTextureAtlas):void 
		{
			var h:int = 150;
			var w:int = 200;
			for (var i:int = 0; i < library.spritesList.length; i++) 
			{
				
				var view:AnimationRenderer = new AnimationRenderer();
				view.alphaThreshold = 0.1;
				
				view.x = (i % 10 ) * w + 100;
				view.y = int(i / 10) * h  + 400;
				addChild(view);
				
				var viewData:SpriteData = library.spritesList[0];
				
				var spriteAsTimeline:MovieClipData = viewData as MovieClipData;	
				
				if(spriteAsTimeline)
					spriteAsTimeline.stop();
				view.show(viewData, texture);
				view.currentFrame = i;
			}
				
			/*for (var i:int = 0; i < 250; i++) 
			{
				
				var view:SWFView = new SWFView();
				
				view.smooth = i % 2 == 0;
				view.alphaThreshold = 0.1;
				
				view.x = (i % 10 ) * w + 50;
				view.y = int(i / 10) * h + 50;
				
				addChild(view);
				
				var viewData:SpriteData = library.spritesList[0].clone() as SpriteData;
				viewData.transform = new Matrix();
				
				var spriteAsTimeline:MovieClipData = viewData as MovieClipData;	
				
				if(spriteAsTimeline)
					spriteAsTimeline.play();
				view.show(viewData, texture);
			}*/
		}
	}
}
