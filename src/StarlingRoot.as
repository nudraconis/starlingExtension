package 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.core.RenderSupport;
	import starling.drawer.DisplayListDrawer;
	import swfdata.MovieClipData;
	import swfdata.SpriteData;
	import swfdata.atlas.gl.GLTextureAtlas;
	import starling.display.Sprite;
	import starling.drawer.StarlingRenderer;
	import swfdata.SymbolsLibrary;
	import swfdrawer.data.DrawingData;
	
	public class StarlingRoot extends Sprite 
	{
		private var starlingRenderer:StarlingRenderer;
		
		private var mousePoint:Point = new Point();
		private var drawer:DisplayListDrawer;
		
		private var transform:Matrix = new Matrix(1, 0, 0, 1, 300, 300);
		private var currentSprite:SpriteData;
		
		public function StarlingRoot() 
		{
			super();
			
			starlingRenderer = new StarlingRenderer();
			addChild(starlingRenderer);
		}
		
		public function show(library:SymbolsLibrary, genomeTextureAtlas:GLTextureAtlas):void 
		{
			currentSprite = library.linkagesList[0];
			
			drawer = new DisplayListDrawer(genomeTextureAtlas, mousePoint, starlingRenderer);
			
			var spriteAsTimeline:MovieClipData = currentSprite as MovieClipData;
				
			if(spriteAsTimeline && spriteAsTimeline.getChildByName('animation'))
				(spriteAsTimeline.getChildByName('animation') as MovieClipData).play();
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			if (!drawer)
				return;
				
			if(currentSprite is IUpdatable)
				(currentSprite as IUpdatable).update();
					
			trace('===========');
			drawer.drawDisplayObject(currentSprite, transform);
			trace('===========');
			
			super.render(support, parentAlpha);
		}
	}
}