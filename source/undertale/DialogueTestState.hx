package undertale;

import flixel.FlxSprite;
import flixel.FlxG;
import undertale.DialogueManager.BoxDialogueDisplay;

class DialogueTestState extends MusicBeatState
{
    var menu:BattleMenu;
    override public function create()
    {
        super.create();

        //var bg:FlxSprite = new FlxSprite(-80);
		//bg.loadGraphic(Paths.image('menuBG'));
		//bg.scrollFactor.set(0, 0);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		//bg.updateHitbox();
		//bg.screenCenter();
		//bg.antialiasing = ClientPrefs.globalAntialiasing;
		//add(bg);

        //FlxG.sound.playMusic(Paths.music('mus_papyrus'), 1);

        //menu = new BattleMenu();
        //add(menu);
        //menu.y = 370;

        //resetDial();
    }

    /*function resetDial()
    {
        menu.dialogueBox.setDialogue([
            {text: "* asdfhjkasdfhkjl"},
            {text: "WHAT THE FUCK", font: "papyrus-ut.ttf", face: "pap_wacky", sound: "snd_txtpap", fontSize: 48},
            {text: "DFA HJKLADS HJKALSD HJKLASD HJAKLSD HJKLASD", font: "papyrus-ut.ttf", face: "pap_mad", sound: "snd_txtpap", fontSize: 48},
        ]);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER && menu.dialogueBox.manager.finishedLine)
        {
            menu.dialogueBox.manager.startNext();
        }
        if (FlxG.keys.justPressed.SHIFT && !menu.dialogueBox.manager.finishedLine)
        {
            menu.dialogueBox.manager.skip();
        }
        if (FlxG.keys.justPressed.SPACE)
        {
            resetDial();
            menu.dialogueBox.manager.startNext();
        }
    }*/
}