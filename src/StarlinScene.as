package 
{
	import swfdata.atlas.gl.GLTextureAtlas;
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;
	import swfdata.SymbolsLibrary;
	
	[Event(name="complete", type="flash.events.Event")]
	public class StarlinScene extends Sprite
	{
		public function StarlinScene() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function show(library:SymbolsLibrary, genomeTextureAtlas:GLTextureAtlas):void 
		{
			(Starling.current.root as StarlingRoot).show(library, genomeTextureAtlas);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			var starling:Starling = new Starling(StarlingRoot, stage);
			starling.addEventListener("rootCreated", onStarlingReady);
			starling.start();
		}
		
		private function onStarlingReady(e:Object):void 
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}