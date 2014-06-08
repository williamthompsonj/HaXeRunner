package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

/**
 * ...
 * @author william.thompsonj
 */
class CreditsState extends FlxState
{
	private var background:FlxSprite;
	private var title:FlxText;
	private var subtitle:FlxText;
	private var attrib:FlxText;
	private var attribText:String;
	private var backBtn:FlxButton;

	override public function create():Void
	{
		// background image
		background = new FlxSprite();
		background.loadGraphic("assets/background.png", false, 1024, 512);
		background.x = (FlxG.width - 1024) * .5;
		background.frame = background.framesData.frames[0];
		add(background);
		
		title = new FlxText(0, 20, FlxG.width, "HaXe Runner");
		title.setFormat(null, 20, 0xFFFFFFFF, "center");
		add(title);
		
		subtitle = new FlxText(0, 50, FlxG.width, "Credits");
		subtitle.setFormat(null, 15, 0xFFFFFFFF, "center");
		add(subtitle);
		
		attribText = "Programming by William.ThompsonJ\n"
		+ "http://opengameart.org/users/williamthompsonj\n\n"
		+ "Graphics by Kenney Vleugels of www.Kenney.nl\n"
		+ "http://opengameart.org/users/kenney\n\n"
		+ "Sound effects by artisticdude\n"
		+ "http://opengameart.org/content/goblins-sound-pack\n\n"
		+ "Music by Sudocolon\n"
		+ "http://opengameart.org/content/chip-bit-danger\n\n"
		+ "Many thanks to all the members of OpenGameArt.org for all their help and support.\n\n"
		+ "Originally created for a tutorial on making an infinite runner with Flixel but it grew "
		+ "beyond it's original bounds significantly. Let's see if it win's any praise in the first "
		+ "ever Procedural Death Jam!\n\n"
		+ "http://proceduraldeathjam.com/";
		
		attrib = new FlxText(0, 100, FlxG.width, attribText);
		attrib.setFormat(null, 12, 0xFFFFFFFF, "center");
		add(attrib);
		
		backBtn = new FlxButton(0, 200+attrib.height, "Back", goBack);
		backBtn.label.size = 30;
		backBtn.loadGraphic("assets/buttons.png", false, 190, 49);
		backBtn.x = (FlxG.width - backBtn.width) * .5;
		add(backBtn);
	}
	
	private function goBack():Void
	{
		FlxG.switchState(new MainMenuState());
	}
	
	override public function destroy():Void
	{
		title.destroy();
		subtitle.destroy();
		attrib.destroy();
		backBtn.destroy();
		
		title = null;
		subtitle = null;
		attrib = null;
		backBtn = null;
		
		super.destroy();
	}
}