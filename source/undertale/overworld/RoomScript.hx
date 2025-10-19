package undertale.overworld;


import flixel.addons.display.FlxBackdrop;
import undertale.BattleMenu.MenuList;
import undertale.BattleMenu.BattleMenuOption;
import undertale.BattleMenu.BattleMenuButton;
import undertale.DialogueManager.DialogueData;
import undertale.DialogueManager.BubbleDialogueDisplay;
import undertale.DialogueManager.BoxDialogueDisplay;
import undertale.DialogueManager.BaseDialogueDisplay;
import undertale.DialogueManager.DialogueDefaults;
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

class RoomScript extends FlxBasic implements IFlxDestroyable
{
    public var interp:Interp = null;
    var script:Expr;
    var parser:Parser;

    var instance:OverworldState;

    public function new(scriptName:String, instance:OverworldState)
    {
        super();

        this.instance = instance;

        var rawScript = null;
        #if MODS_ALLOWED
		var moddyFile:String = Paths.modFolders("rooms/"+scriptName+".hx");
		if(FileSystem.exists(moddyFile)) {
			rawScript = File.getContent(moddyFile);
		}
		#end
        if(rawScript == null) {
            var path = Paths.file("battleScripts/"+scriptName+".hx");
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
            //lime.app.Application.current.window.alert(scriptName + " could not be found.", 'Error loading script!');
            trace('script not found');
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
            lime.app.Application.current.window.alert(e.message, 'Error on room script .hx!');
            return;
        }
        init();
        //trace(rawScript);
        trace('loaded battle script: ' + scriptName);
    }
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

        interp.variables.set('FlxBackdrop', FlxBackdrop);

        interp.variables.set('BattleBox', BattleBox);
        interp.variables.set('Platform', Platform);
        interp.variables.set('PlayerHeart', PlayerHeart);
        interp.variables.set('AttackObject', AttackObject);
        interp.variables.set('BoneAttack', BoneAttack);
        interp.variables.set('PlayerControls', PlayerControls);
        interp.variables.set('HeartMovement', HeartMovement);

        interp.variables.set('BattleMenu', BattleMenu);
        interp.variables.set('BattleMenuButton', BattleMenuButton);
        interp.variables.set('BattleMenuOption', BattleMenuOption);
        interp.variables.set('MenuList', MenuList);
        interp.variables.set('DialogueDefaults', DialogueDefaults);
        interp.variables.set('DialogueManager', DialogueManager);
        interp.variables.set('BaseDialogueDisplay', BaseDialogueDisplay);
        interp.variables.set('BubbleDialogueDisplay', BubbleDialogueDisplay);
        interp.variables.set('BoxDialogueDisplay', BoxDialogueDisplay);
        interp.variables.set('BattleNPC', BattleNPC);
        interp.variables.set('UTText', UTText);


        interp.variables.set('BoxMenu', BoxMenu);
        interp.variables.set('DialogueHUDMenu', DialogueHUDMenu);
        interp.variables.set('InteractableSprite', InteractableSprite);
        interp.variables.set('OverworldState', OverworldState);
        interp.variables.set('OverworldCharacter', OverworldCharacter);
        interp.variables.set('OverworldHUDMenu', OverworldHUDMenu);
        interp.variables.set('SavePoint', SavePoint);
        interp.variables.set('SaveMenu', SaveMenu);
        interp.variables.set('PlayerStats', PlayerStats);
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

    override public function destroy()
    {
        interp = null;
        super.destroy();
    }
}