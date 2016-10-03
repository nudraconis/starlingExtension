package 
{
	import starling.SWFView;
	import starling.display.Sprite;
	import swfdata.MovieClipData;
	import swfdata.SpriteData;
	import swfdata.SymbolsLibrary;
	import swfdata.atlas.gl.GLTextureAtlas;
	
	public class StarlingRoot extends Sprite 
	{
		private var view:SWFView;
		
		public function StarlingRoot() 
		{
			super();
			
			view = new SWFView();
			view.alphaThreshold = 0.1;
			
			view.x = 300;
			view.y = 300;
			
			addChild(view);
		}
		
		public function show(library:SymbolsLibrary, texture:GLTextureAtlas):void 
		{
			var h:int = 80;
			var w:int = 100;
			for (var i:int = 0; i < library.spritesList.length; i++) 
			{
				
				var view:SWFView = new SWFView();
				view.alphaThreshold = 0.1;
				
				view.x = (i % 10 ) * w + 50;
				view.y = int(i / 10) * h  + 400;
				addChild(view);
				
				var viewData:SpriteData = library.spritesList[i];
				
				var spriteAsTimeline:MovieClipData = viewData as MovieClipData;	
				
				if(spriteAsTimeline)
					spriteAsTimeline.play();
					
				view.show(viewData, texture);
			}
		}
	}
}