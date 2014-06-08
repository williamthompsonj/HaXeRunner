package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxPoint;
/**
 * @author william.thompsonj
 * 
 * Welcome to the HaXe Flixel Infinite Runner source! Below is the logic needed
 * to make your very own infinite runner style game similar to canabalt. This
 * is not a clone of Canabalt by the way, it has different features. There are
 * 5 major sections to the code:
	 * 
	 * 0. Constructor and variable declarations
	 * 1. Setup logic
	 * 2. Initializers
		* 2a. Reset Handler
	 * 3. Updaters
	 * 4. GC Handling
	 * 5. Helpers
 * 
 * Happy coding!
 */
class PlayState extends FlxState
{
	// static constants for the size of the tilemap tiles
	private static inline var TILE_WIDTH:Int = 70;
	private static inline var TILE_HEIGHT:Int = 70;
	
	// base speed for player, stands for xVelocity
	private static inline var BASE_SPEED:Int = 250;
	
	// how fast the player speeds up going to the right
	private static inline var xAcceleration:Int = 1000;
	
	// force that pulls sprite to the right
	private static inline var xDrag:Int = 200;
	
	// represents how strong gravity pulls up or down
	private static inline var yAcceleration:Int = 1400;
	
	// maximum speed the player can fall
	private static inline var yVelocity:Int = 1400;
	
	// how long holding jump makes player jump in seconds
	private static inline var jumpDuration:Float = .25;
	
	// player object and related jump variable
	private var _player:FlxSprite;
	private var _jump:Float;
	private var _playJump:Bool;
	private var _jumpPressed:Bool;
	private var _sfxDie:Bool;
	
	// used to help with tracking camera movement
	private var _ghost:FlxSprite;
	
	// where to start generating platforms
	private var _edge:Int;
	
	// background image
	private var _bgImgGrp:FlxGroup;
	private var _bgImg1:FlxSprite;
	private var _bgImg2:FlxSprite;
	private var _bgImages:Array<String>;
	
	// collision group for generated platforms
	private var _collisions:FlxGroup;
	
	// track all platform objects on screen
	private var _tiles:Array<FlxSprite>;
	
	// sprite pool
	private var _pool:ObjectPool;
	
	// indicate whether the collision group has changed
	private var _change:Bool;
	
	// score counter and timer
	private var _score:Int;
	private var _startDistance:Int;
	
	// button to reset and some text
	private var _resetButton:FlxButton;
	private var _scoreText:FlxText;
	private var _helperText:FlxText;
	
	// used when resetting
	private var _resetPlatforms:Bool;
	
	override public function create():Void
	{
		// make sure world is wide enough, 100,000 tiles should be enough...
		FlxG.worldBounds.setSize(TILE_WIDTH * 100000, 1000);
		
		// background music
		#if flash
		FlxG.sound.playMusic("assets/Chip Bit Danger.mp3");
		#else
		FlxG.sound.playMusic("assets/Chip Bit Danger.ogg");
		#end
		
		// setup background image
		setupBg();
		
		// prepare the player
		setupPlayer();
		
		// prepare player related variables
		initPlayer();
		
		// setup UI
		setupUI();
		
		// prepare UI variables
		initUI();
		
		// setup platform logic
		setupPlatforms();
		
		// prepare platform variables
		initPlatforms();
		
		// initialize scrolling background image
		initBg();
	}
	
	/*************************
	 * 
	 * Section 1: Setup logic
	 * 
	 * Setup functions create new objects and get everything ready to start.
	 * They are not the same as initializers because they create new things.
	 * 
	 * Setup functions only get called when the game starts. There is no good
	 * reason to inline them since they only ever get called once.
	 * 
	 *************************/
	
	private function setupBg():Void
	{
		_bgImg1 = new FlxSprite();
		_bgImg2 = new FlxSprite();
		_bgImg1.loadGraphic("assets/background.png", false, 1024, 512);
		_bgImg2.loadGraphic("assets/background.png", false, 1024, 512);
		_bgImgGrp = new FlxGroup();
		
		this.add(_bgImgGrp);
		_bgImgGrp.add(_bgImg1);
		_bgImgGrp.add(_bgImg2);
	}
	
	private function setupPlayer():Void
	{
		// make a player sprite
		_player = new FlxSprite();
		_player.loadGraphic("assets/sprites.png", false, 70, 100);
		
		_startDistance = Std.int(_player.x);
		
		// set animations to use this run
		setAnimations();
		
		// face player to the right
		_player.facing = FlxObject.RIGHT;
		
		// add player to FlxState
		add(_player);
		
		// something that follows player's x movement
		_ghost = new FlxSprite(_player.x+FlxG.width-TILE_WIDTH, FlxG.height / 2);
		
		// camera can follow player's x movement, not y (jump bobbing)
		FlxG.camera.follow(_ghost);
	}
	
	private function setupUI():Void
	{
		// provide reset button for easy player resets
		_resetButton = new FlxButton(0, 0, "Reset", onReset);
		add(_resetButton);
		
		// add score counter so player can see how well they're doing
		_scoreText = new FlxText(0, 0, TILE_WIDTH * 3, Std.string("0 meters\nStart At: "+_startDistance));
		_scoreText.alignment = "right";
		add(_scoreText);
		
		// helper text that tells player what controls are
		_helperText = new FlxText(0, 0, TILE_WIDTH*5, "W/UP Arrow to Jump, R to reset");
		add(_helperText);
	}
	
	private function setupPlatforms():Void
	{
		// pool to hold platform objects
		_pool = new ObjectPool(TILE_WIDTH, TILE_HEIGHT, "assets/tiles.png");
		
		// keep track of objects currently in use
		_tiles = new Array<FlxSprite>();
		
		// holds all collision objects
		_collisions = new FlxGroup();
		
		// add the collisions group to the screen so we can see it!
		add(_collisions);
		
		// reset indicator
		_resetPlatforms = false;
	}
	
	/*************************
	 * 
	 * Section 2: Initializers
	 * 
	 * These should not create anything new, only reset values to default.
	 * 
	 *************************/
	
	private inline function initBg():Void
	{
		var i:Int = Std.random(4);
		_bgImg1.x = _player.x - TILE_WIDTH;
		_bgImg2.x = _bgImg1.x + _bgImg1.width;
		_bgImg1.frame = _bgImg1.framesData.frames[i];
		_bgImg2.frame = _bgImg2.framesData.frames[i];
		_bgImgGrp.update();
		
		if (i < 1)
		{
			_helperText.color = 0xFFFFFF;
			_scoreText.color = 0xFFFFFF;
		}
		else
		{
			_helperText.color = 0x000000;
			_scoreText.color = 0x000000;
		}
	}
	
	private inline function initPlayer():Void
	{
		// setup jump height
		_jump = -1;
		_playJump = true;
		_jumpPressed = false;
		_sfxDie = true;
		
		// setup player position
		_player.setPosition(_startDistance*TILE_WIDTH, 0);
		
		// Basic player physics
		_player.drag.x = xDrag;
		_player.velocity.set(0, 0);
		_player.maxVelocity.set(BASE_SPEED, yVelocity);
		_player.acceleration.set(xAcceleration, yAcceleration);
		
		// setup player animations
		setAnimations();
		
		// move camera to match player
		_ghost.x = _player.x - (TILE_WIDTH * .2) + (FlxG.width * .5);
	}
	
	private inline function initUI():Void
	{
		_resetButton.setPosition(20, 20);
		_scoreText.y = 20;
		_helperText.y = 20;
		_score = _startDistance;
		positionText();
	}
	
	private inline function initPlatforms():Void
	{
		// collision group is up to date
		_change = false;
		
		// reset edge screen where we generate new platforms
		_edge = (_startDistance-1)*TILE_WIDTH;
		
		// make initial platforms for starting place
		makePlatform(15, 4);
		makePlatform();
	}
	
	/*************************
	 * 
	 * Section 2a: Reset Handler
	 * 
	 * This is really a helper function in disguise but it's a standard
	 * feature for most any game. This can include custom code that's needed to
	 * fully reset the play environment.
	 * 
	 *************************/
	
	private function onReset():Void
	{
		// move the edge we're watching, then remove blocks
		_resetPlatforms = true;
		removeBlocks();
		_resetPlatforms = false;
		
		// re-initialize player physics and position
		initPlayer();
		
		// re-initialize UI
		initUI();
		
		// reset platforms and draw starting area
		initPlatforms();
		
		// setup background
		initBg();
	}
	
	/*************************
	 * 
	 * Section 3: Updaters
	 * 
	 * This is where the process spends most of it's time executing. Try to do
	 * as much optimizing on these functions as possible so the game runs fast
	 * and smooth. If possible, design updater functions to be inlined.
	 * 
	 *************************/
	
	override public function update():Void
	{
		#if !(android || blackberry || iphone || ios || mobile)
		// check if player hit keyboard reset key
		if (FlxG.keys.anyJustReleased(["R"]))
		{
			onReset();
			return;
		}
		#end
		
		// check if player fell off the screen
		if(_player.y > FlxG.height)
		{
			// call super.update so reset button works
			super.update();
			
			// stop updating
			return;
		}
		
		// platform garbage handling
		updatePlatforms();
		
		// update player position, etc.
		updatePlayer();
		
		// update background
		updateBg();
		
		// check if collision group changed
		if (_change)
		{
			// update collision group so it doesn't freak out
			_collisions.update();
			
			// collision group is up to date
			_change = false;
		}
		
		// check for collision with platforms
		if (FlxG.collide(_player, _collisions))
		{
			_playJump = false;
			
			// check if player hit the wall
			if (_player.velocity.x == 0)
			{
				// player went splat
				_jump = -1;
				_playJump = false;
				sfxDie();
			}
			else if(!_jumpPressed)
			{
				// reset jump variable
				_jump = 0;
				_sfxDie = true;
			}
		}
		
		playerAnimation();
		super.update();
		
		// update ui stuff
		updateUI();
	}
	
	private inline function updateUI():Void
	{
		// update score
		_score = Std.int(_player.x / (TILE_WIDTH));
		if (_score*.3 > _startDistance)
		{
			_startDistance = Std.int(_score * .3);
		}
		_scoreText.text = Std.string(_score + " meters\nStart At: " + _startDistance);
		
		positionText();
		
		// camera tracks ghost, not player (prevent tracking jumps)
		_ghost.x = _player.x - (TILE_WIDTH * .2) + (FlxG.width * .5);
	}
	
	private inline function updatePlayer():Void
	{
		// make player go faster as they go farther in j curve
		_player.maxVelocity.x = BASE_SPEED + Std.int(_player.x*.05);
		
		#if (android || blackberry || iphone || mobile)
		_jumpPressed = FlxG.mouse.pressed;
		#else
		_jumpPressed = FlxG.keys.anyPressed(["UP", "W"]);
		#end
		
		if (_jump != -1 && _jumpPressed)
		{
			// play jump sound just once
			if (_jump == 0)
			{
				sfxJump();
			}
			
			// Duration of jump
			_jump += FlxG.elapsed;
			
			if (_player.velocity.y >= 0)
			{
				// play jump animation
				_playJump = true;
				
				// get player off the platform
				_player.y -= 1;
				
				// set minimum velocity
				_player.velocity.y = -yAcceleration * .5;
				
				//The general acceleration of the jump
				_player.acceleration.y = -yAcceleration;
			}
			
			if (_jump > jumpDuration)
			{
				// set minimum velocity
				_player.velocity.y = -yAcceleration * .5;
				
				//You can't jump for more than 0.25 seconds
				_jump = -1;
				
				// make sure fall animation plays
				_playJump = true;
			}
		}
		else if (!_jumpPressed || _jump == -1)
		{
			if (_player.velocity.y < 0)
			{
				// set acceleration to pull to ground
				_player.acceleration.y = yAcceleration;
				
				// set minimum velocity
				_player.velocity.y = yAcceleration * .25;
				
				// stop jumping more than once, allows air jumps
				_jump = -1;
			}
		}
	}
	
	private inline function updateBg():Void
	{
		if (_bgImg2.x < (_player.x - TILE_WIDTH))
		{
			_bgImg1.x = _bgImg2.x;
			_bgImg2.x += _bgImg2.width;
		}
	}
	
	private inline function updatePlatforms():Void
	{
		// remove garbage before making new platforms
		removeBlocks();
		
		// check if we need to make more platforms
		while (_player.x + FlxG.width > _edge)
		{
			makePlatform();
		}
	}
	
	/*************************
	 * 
	 * Section 4: GC Handling
	 * 
	 * If possible, design garbage collector functions to be inlined. Since
	 * these usually run every frame, try to make them escape as soon as they
	 * detect they don't need to go further, that way they take no more power
	 * than absolutely necessary. Also if possible, try to modify as little as
	 * possible since it does involve running between frames.
	 * 
	 *************************/
	
	private function removeBlocks():Void
	{
		// distance from player to inspect
		var distance:Float = _player.x - (TILE_WIDTH * 2);
		
		// reset the level
		if (_resetPlatforms)
		{
			distance += _edge;
		}
		
		// try to run at least once
		var ticker:Bool = true;
		
		// check for old tiles that need to be removed
		while (ticker && _tiles.length != 0)
		{
			// tile is past player, remove it
			if (_tiles[0].x < distance)
			{
				// temp holder for block
				_block = _tiles.shift();
				
				// remove from collision group
				_collisions.remove(_block);
				
				// put tile back in the pool
				_pool.returnObj(_block);
				
				// check the next block to see if it needs to be removed
				ticker = true;
				
				// contents of collision group have changed
				_change = true;
			}
			else
			{
				ticker = false;
			}
		}
	}
	
	/*************************
	 * 
	 * Section 5: Helpers
	 * 
	 * Anything that cannot be included as part of the other sections.
	 * 
	 *************************/
	
	private var _block:FlxSprite;
	
	private function makePlatform(wide:Int=0, high:Int=0):Void
	{
		if (wide == 0)
		{
			wide = Std.random(5) + 4 + Std.int(_player.x*.0001);
		}
		if (high == 0)
		{
			high = Std.random(3) + 1;
		}
		
		// which set of tiles to use for this platform
		var line:Int = Std.random(9) * 4;
		
		var top:Int = FlxG.height - (high * TILE_HEIGHT);
		
		// grass tuft on left edge
		makeBlock(_edge, top, line);
		
		// hanging tile next to edge
		makeBlock(_edge + TILE_WIDTH, top, line + 1);
		
		// update screen edge and width of platform lower part
		_edge += TILE_WIDTH*2;
		
		for (row in 0...wide)
		{
			// grass tuft on left edge
			makeBlock(_edge, top, line + 1);
			
			for (c in 1...high)
			{
				// grass tuft on left edge
				makeBlock(_edge, top + (c * TILE_HEIGHT), line + 3);
			}
			
			// move edge of platform over one
			_edge += TILE_WIDTH;
		}
		
		// hanging tile next to edge
		makeBlock(_edge, top, line + 1);
		
		// grass tuft on right edge
		makeBlock(_edge + TILE_WIDTH, top, line + 2);
		
		// buffer for distance between platforms
		_edge += Std.int(_player.x / (TILE_WIDTH * .9)) + ((Std.random(2) + 3) * TILE_WIDTH);
		
		// contents of collision group have changed
		_change = true;
	}
	
	private inline function makeBlock(x:Float, y:Float, tile:Int):Void
	{
		_block = _pool.getObj();
		_block.setPosition(x, y);
		_block.frame = _block.framesData.frames[tile];
		
		// add platform block to tile array
		_tiles.push(_block);
		
		// add block to collisions group
		_collisions.add(_block);
	}
	
	private inline function playerAnimation():Void
	{
		// ANIMATION
		if (_player.velocity.x == 0)
		{
			_player.animation.play("die");
		}
		else if (_playJump)
		{
			_player.animation.play("jump");
		}
		else if (_player.velocity.y != 0)
		{
			_player.animation.play("fall");
		}
		else
		{
			_player.animation.play("run");
		}
	}
	
	private inline function setAnimations():Void
	{
		var line:Int = Std.random(5)*6;
		
		// Animations
		_player.animation.add("run", [line+1, line+2], 4);
		_player.animation.add("jump", [line+3]);
		_player.animation.add("fall", [line+4]);
		_player.animation.add("die", [line+5]);
	}
	
	private inline function positionText():Void
	{
		// position helper text
		_helperText.x = _player.x + TILE_WIDTH * 3;
		
		// position score text
		_scoreText.x = _player.x + FlxG.width - (4 * TILE_WIDTH);
	}
	
	private inline function sfxDie():Void
	{
		if (_sfxDie)
		{
			#if flash
			FlxG.sound.play("assets/goblin-9.mp3");
			#else
			FlxG.sound.play("assets/goblin-9.ogg");
			#end
			_sfxDie = false;
		}
	}
	
	private inline function sfxJump():Void
	{
		#if flash
		FlxG.sound.play("assets/goblin-1.mp3");
		#else
		FlxG.sound.play("assets/goblin-1.ogg");
		#end
	}
}