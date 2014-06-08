package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

/**
 * ...
 * @author william.thompsonj
 */
class MainMenuState extends FlxState
{
	private var background:FlxSprite;
	private var title:FlxText;
	private var BtnRun:FlxButton;
	private var credits:FlxButton;
	
	override public function create():Void
	{
		var division:Int = Std.int(FlxG.height / 3);
		
		// background image
		background = new FlxSprite();
		background.loadGraphic("assets/background.png", false, 1024, 512);
		background.x = (FlxG.width - 1024) * .5;
		background.frame = background.framesData.frames[1];
		add(background);
		
		// title of game
		title = new FlxText(0, division*.5, FlxG.width, "HaXe Runner");
		title.setFormat(null, 50, 0xFFFFFFFF, "center");
		add(title);
		
		// button to run game
		BtnRun = new FlxButton(0, division * 1.5, "Run!", startGame);
		BtnRun.label.size = 30;
		BtnRun.loadGraphic("assets/buttons.png", false, 190, 49);
		BtnRun.x = (FlxG.width - BtnRun.width) * .5;
		add(BtnRun);
		
		// button to redirect to credits
		credits = new FlxButton(0, division * 2, "Credits", showCredits);
		credits.label.size = 30;
		credits.loadGraphic("assets/buttons.png", false, 190, 49);
		credits.x = (FlxG.width - credits.width) * .5;
		add(credits);
	}
	
	private function startGame():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function showCredits():Void
	{
		FlxG.switchState(new CreditsState());
	}
	
	override public function destroy():Void
	{
		background.destroy();
		title.destroy();
		BtnRun.destroy();
		credits.destroy();
		
		background = null;
		title = null;
		BtnRun = null;
		credits = null;
		
		super.destroy();
	}
}