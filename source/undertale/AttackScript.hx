package undertale;

import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxAngle;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import hscript.*;

class AttackScript extends FlxBasic implements IFlxDestroyable
{
    public var interp:Interp = null;
    var script:Expr;
    var parser:Parser;

    var manager:BattleManager;

    public function new(scriptName:String, manager:BattleManager)
    {
        super();

        this.manager = manager;

        var rawScript = null;
        #if MODS_ALLOWED
		var moddyFile:String = Paths.modFolders("attackScripts/"+scriptName+".hx");
		if(FileSystem.exists(moddyFile)) {
			rawScript = File.getContent(moddyFile);
		}
		#end
        if(rawScript == null) {
            var path = Paths.file("attackScripts/"+scriptName+".hx");
			#if sys
            if(FileSystem.exists(path)) 
            {
                rawScript = File.getContent(path);
            }
			#else
            if(Assets.exists(path)) 
            {
                rawScript = Assets.getText(path);
            }
			#end
		}
        if (rawScript == null)
        {
            lime.app.Application.current.window.alert(scriptName + " could not be found.", 'Error loading script!');
            return;
        }
            
        parser = new Parser();
        parser.allowTypes = true;
        parser.allowMetadata = true;
        parser.allowJSON = true;
        
        try
        {
            interp = new Interp();
            script = parser.parseString(rawScript); //load da shit
            interp.execute(script);
        }
        catch(e)
        {
            lime.app.Application.current.window.alert(e.message, 'Error on attack script .hx!');
            return;
        }
        init();
        //trace(rawScript);
        trace('loaded attack script: ' + scriptName);
    }
    var timers:Array<FlxTimer> = [];
    var tweens:Array<FlxTween> = [];
    var tweenManager:FlxTweenManager = new FlxTweenManager();
    private function init()
    {
        if (interp == null)
            return;


        interp.variables.set('Math', Math);
        interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
        interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
        interp.variables.set('FlxAngle', FlxAngle);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
        interp.variables.set('StringTools', StringTools);
        interp.variables.set('Std', Std);

        interp.variables.set('BattleBox', BattleBox);
        interp.variables.set('Platform', Platform);
        interp.variables.set('PlayerHeart', PlayerHeart);
        interp.variables.set('AttackObject', AttackObject);
        interp.variables.set('BoneAttack', BoneAttack);
        interp.variables.set('PlayerControls', PlayerControls);
        interp.variables.set('HeartMovement', HeartMovement);

        interp.variables.set('playSound', function(sound:String, ?vol:Float = 1) {
            flixel.FlxG.sound.play(Paths.sound(sound), vol);
        });
        interp.variables.set('startTween', function(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions) {
            var tween = tweenManager.tween(Object, Values, Duration, Options);
            tweens.push(tween);
        });
        interp.variables.set('startTimer', function(time:Float, onComplete:FlxTimer->Void, loops:Int = 1) {
            var timer = new FlxTimer().start(time, onComplete, loops);
            timers.push(timer); //store timers in an array to destroy later to prevent crashes when destorying the script
        });

        interp.variables.set('makeAttack', function(x:Float = 0, y:Float = 0, sprName:String = "", angle:Float = 0, velX:Float = 0, velY:Float = 0, scale:Float = 1, blue:Bool = false, orange:Bool = false) {
            var attack = new AttackObject(x, y, blue, orange, sprName);
            attack.setGraphicSize(Std.int(attack.width*scale));
            attack.updateHitbox();
            attack.velocity.x = velX;
            attack.velocity.y = velY;
            attack.angle = angle;
            return attack;
        });

        interp.variables.set('makeBone', function(x:Float = 0, y:Float = 0, velX:Float = 0, velY:Float = 0, height:Float = 100, blue:Bool = false, orange:Bool = false) {
            var attack = new BoneAttack(x, y, blue, orange);
            attack.boneHeight = height;
            attack.velocity.x = velX;
            attack.velocity.y = velY;
            return attack;
        });

        interp.variables.set('box', manager.box);
        interp.variables.set('heart', manager.heart);

        interp.variables.set('add', function(attack:AttackObject)
        {
            manager.box.attacks.add(attack);
        });

        interp.variables.set('end', function(time:Float = 0, ease:Float->Float = null)
        {
            manager.endAttack(time, ease);
        });


        // old ///
        interp.variables.set('doTimer', function(timer:FlxTimer) {
            timers.push(timer); //store timers in an array to destroy later to prevent crashes when destorying the script
        });
        
    }
    public function call(event:String, args:Array<Dynamic>)
    {
        if (interp == null)
            return;
        if (interp.variables.exists(event)) //make sure it exists
        {
            try
            {
                if (args.length > 0)
                    Reflect.callMethod(null, interp.variables.get(event), args);
                else
                    interp.variables.get(event)(); //if function doesnt need an arg
            }
            catch(e)
            {
                lime.app.Application.current.window.alert(e.message, 'Error on attack script .hx! (while running)');
            }
        }
    }
    public function getVar(vari:String) : Dynamic
    {
        if (interp == null)
            return null;
        if (interp.variables.exists(vari)) //make sure it exists
        {
            return interp.variables.get(vari);
        }
        return null;
    }

    override public function update(elapsed:Float)
    {
        call("onUpdate", [elapsed]);
        tweenManager.update(elapsed);
        super.update(elapsed);
    }

    override public function destroy()
    {
        for (t in timers)
            t.cancel();
        for (t in tweens)
            t.cancel();
        if (tweenManager != null)
            tweenManager.destroy();
        interp = null;
        super.destroy();
    }
}