package;

import flash.Lib;
import flixel.FlxGame;
	
class GameClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		//var ratioX:Float = stageWidth / 600;
		//var ratioY:Float = stageHeight / 400;
		//var ratio:Float = Math.min(ratioX, ratioY);
		//var fps:Int = 60;
		
		//super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), PlayState, ratio, fps, fps);
		super(stageWidth, stageHeight, MainMenuState, 1, 60, 60, false, false);
	}
}