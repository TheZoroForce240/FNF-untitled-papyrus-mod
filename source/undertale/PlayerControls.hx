package undertale;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class PlayerControls
{
	//directional controls (holding)
    public static var upControls:Array<FlxKey> = [FlxKey.W, FlxKey.UP];
    public static var UP(get, null):Bool;
	static function get_UP():Bool {
		return FlxG.keys.anyPressed(upControls);
	}

    public static var leftControls:Array<FlxKey> = [FlxKey.A, FlxKey.LEFT];
    public static var LEFT(get, null):Bool;
	static function get_LEFT():Bool {
		return FlxG.keys.anyPressed(leftControls);
	}

    public static var downControls:Array<FlxKey> = [FlxKey.S, FlxKey.DOWN];
    public static var DOWN(get, null):Bool;
	static function get_DOWN():Bool {
		return FlxG.keys.anyPressed(downControls);
	}

    public static var rightControls:Array<FlxKey> = [FlxKey.D, FlxKey.RIGHT];
    public static var RIGHT(get, null):Bool;
	static function get_RIGHT():Bool {
		return FlxG.keys.anyPressed(rightControls);
	}

	//directional presses
    public static var UP_P(get, null):Bool;
	static function get_UP_P():Bool {
		return FlxG.keys.anyJustPressed(upControls);
	}

    public static var LEFT_P(get, null):Bool;
	static function get_LEFT_P():Bool {
		return FlxG.keys.anyJustPressed(leftControls);
	}

    public static var DOWN_P(get, null):Bool;
	static function get_DOWN_P():Bool {
		return FlxG.keys.anyJustPressed(downControls);
	}

    public static var RIGHT_P(get, null):Bool;
	static function get_RIGHT_P():Bool {
		return FlxG.keys.anyJustPressed(rightControls);
	}

	//other controls

	public static var interactControls:Array<FlxKey> = [FlxKey.Z, FlxKey.ENTER];
    public static var INTERACT_P(get, null):Bool;
	static function get_INTERACT_P():Bool {
		return FlxG.keys.anyJustPressed(interactControls);
	}

	public static var backControls:Array<FlxKey> = [FlxKey.X, FlxKey.SHIFT];
    public static var BACK_P(get, null):Bool;
	static function get_BACK_P():Bool {
		return FlxG.keys.anyJustPressed(backControls);
	}

	public static var menuControls:Array<FlxKey> = [FlxKey.C, FlxKey.CONTROL];
    public static var MENU_P(get, null):Bool;
	static function get_MENU_P():Bool {
		return FlxG.keys.anyJustPressed(menuControls);
	}
}