package;

import flixel.FlxSprite;
/**
 * @author william.thompsonj
 * 
 * This class is used to minimize and standardize object creation during game
 * play. One of the problems with game play in flash is object creation is very
 * slow and can slow down execution. Using an object pool removes the need to
 * create objects on the fly or to discard them after they leave the screen.
 * 
 * Use an object pool any time you frequently need to create objects that will
 * quickly be destroyed. It saves the time and resource needed and speeds up
 * execution because it re-purposes old objects in a generic way.
 */
class ObjectPool
{
	private var TILE_WIDTH:Int;
	private var TILE_HEIGHT:Int;
	private var _tileMap:String;
	
	private var _pool:Array<FlxSprite>;
	private var _solid:Bool;
	private var counter:Int;
	private var size:Int;

	public function new(tile_width:Int, tile_height:Int, tileMap:String, len:Int = 600, Solid:Bool=true)
	{
		// actual object pool
		_pool = new Array<FlxSprite>();
		
		// whether to default to solid or not
		_solid = Solid;
		
		// size of tiles
		TILE_WIDTH = tile_width;
		TILE_HEIGHT = tile_height;
		
		// pass to the tilemap used
		_tileMap = tileMap;
		
		// how big to make the pool initially
		size = len;
		
		// make sure size is at least 1
		if (size < 1)
		{
			size = 1;
		}
		
		// create pool
		loadPool();
		
		// how big to make the pool initially
		size = Std.int(size * .1);
		
		// make sure size is at least 1
		if (size == 0)
		{
			size = 1;
		}
	}

	public function getObj():FlxSprite
	{
		// check if there are sprites in the pool
		if (counter == 0)
		{
			loadPool();
		}
		
		// pull sprite from the pool
		counter--;
		return _pool.shift();
	}
	
	public function returnObj(s:FlxSprite):Void
	{
		// add sprite to the pool
		counter++;
		_pool.push(s);
	}
	
	private function loadPool():Void
	{
		// define first block
		var block:FlxSprite = new FlxSprite();
		block.solid = _solid;
		block.immovable = true;
		block.loadGraphic(_tileMap, false, TILE_WIDTH, TILE_HEIGHT, false);
		_pool.unshift(block);
		
		// make pool bigger
		for (i in 1...size)
		{
			_pool.unshift(new FlxSprite());
			_pool[0].solid = _solid;
			_pool[0].immovable = true;
			_pool[0].loadGraphicFromSprite(block);
		}
		
		// reflect new pool size
		counter = _pool.length;
	}
}