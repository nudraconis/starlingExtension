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
			var viewData:SpriteData = library.spritesList[0];
			
			var spriteAsTimeline:MovieClipData = viewData as MovieClipData;
				
			if(spriteAsTimeline && spriteAsTimeline.getChildByName('animation'))
				(spriteAsTimeline.getChildByName('animation') as MovieClipData).play();
				
			view.show(viewData, texture);
		}
	}
}