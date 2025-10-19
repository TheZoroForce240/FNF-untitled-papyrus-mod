package undertale;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;

using StringTools;

/**
 * Simple Debugging state for testing out attack scripts.
 */
class BattleTestState extends MusicBeatState
{
    var battleManager:BattleManager;
    var currentScript = "";
    var scriptInputBox:FlxInputText;

    var bpmInput:FlxInputText;
    
    override public function create()
    {
        var bg:FlxSprite = new FlxSprite(-80);
		bg.loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        scriptInputBox = new FlxInputText(10, 100, 150, '');
        add(scriptInputBox);

        bpmInput = new FlxInputText(10, 50, 50, "200");
        bpmInput.callback = function(text:String, action:String)
        {
            //if (!Math.isNaN(Std.parseInt(text.trim())))
                //Conductor.changeBPM(Std.parseInt(text.trim()));
        }
        add(bpmInput);
        var changeBpmButton = new FlxButton(10, bpmInput.y+bpmInput.height+10, "Change BPM", function()
        {
            if (!Math.isNaN(Std.parseInt(bpmInput.text.trim())))
                Conductor.changeBPM(Std.parseInt(bpmInput.text.trim()));
        });
        add(changeBpmButton);

        battleManager = new BattleManager();
        add(battleManager);

        var loadScriptButton = new FlxButton(10, scriptInputBox.y+scriptInputBox.height+10, "Load Script", function()
        {
            battleManager.clearAttack();
            battleManager.loadAttack(scriptInputBox.text);
            battleManager.startAttack();
            currentScript = scriptInputBox.text;
        });
        add(loadScriptButton);

        var clearAttack = new FlxButton(10, loadScriptButton.y+loadScriptButton.height+10, "Clear Attack", function()
        {
            battleManager.clearAttack();
        });
        add(clearAttack);
        add(new FlxText(10, clearAttack.y+clearAttack.height+10, 0, "Press F5 to reload script\n"));
        
        FlxG.mouse.visible = true;

        super.create();
    }
    var total:Float = 0;
    override public function update(elapsed:Float)
    {
        total += elapsed;
        //box.boxWidth = 1000 + Math.sin(total*5)*50;
        if (FlxG.keys.justPressed.F5)
        {
            battleManager.clearAttack();
            battleManager.loadAttack(currentScript);
            battleManager.startAttack();
        }
        if (FlxG.keys.justPressed.ESCAPE)
        {
            battleManager.clearAttack();
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }


        super.update(elapsed);
    }
}