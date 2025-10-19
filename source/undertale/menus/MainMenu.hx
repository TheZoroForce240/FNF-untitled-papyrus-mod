package undertale.menus;

import flixel.tweens.FlxTween;
import undertale.overworld.OverworldState;
import options.BaseOptionsMenu;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;

class MainMenu extends MusicBeatState
{
    var optionsList:Array<String> = ["Continue", "Reset", "Settings"];
    var optionOffsets:Array<Array<Float>> = [[-150, 0], [150, 0], [0, 60]];
    var optionsTexts:Array<UTText> = [];
    var selectionOption:Int = 0;
    override public function create()
    {
        PlayerStats.load();
        var bg = new FlxSprite().loadGraphic(Paths.image("bg_floweyglow"));
        bg.scale.set(3, 3);
        bg.updateHitbox();
        bg.screenCenter();
        bg.y -= 230;
        add(bg);
        FlxG.sound.playMusic(Paths.music("mus_menu2"));

        var chairiel = new FlxSprite();
        chairiel.frames = Paths.getSparrowAtlas("chairiel");
        chairiel.animation.addByPrefix("chairiel", "chairiel", 6, true);
        chairiel.animation.play("chairiel");
        chairiel.scale.set(3, 3);
        chairiel.updateHitbox();
        chairiel.screenCenter();
        chairiel.y += 130;
        add(chairiel);


        var text = new UTText(0, 720-26, 0, "FNF v0.2.8 | Psych Engine v0.6.3 | Undertale by Toby Fox");
        text.setFormat(Paths.font("crypt-of-tomorrow-ut-font.ttf"), 16, 0xFF999999);
        add(text);
        text.screenCenter(X);

        var name = new UTText(320, 160, 640, PlayerStats.name);
        name.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(name);

        var lv = new UTText(320, name.y, 640, "LV"+ PlayerStats.lv);
        lv.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, CENTER);
        add(lv);

        var time = new UTText(320, name.y, 640, PlayerStats.getFormattedTimePlayed());
        time.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, RIGHT);
        add(time);

        var room = new UTText(320, lv.y+60, 640, PlayerStats.lastRoomTitle);
        room.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(room);

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        for (i in 0...optionsList.length)
        {
            var text = new UTText(320, room.y+80, 0, optionsList[i]);
            text.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
            add(text);
            text.screenCenter(X);
            text.x += optionOffsets[i][0];
            text.y += optionOffsets[i][1];
            optionsTexts.push(text);
        }

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float) 
    {
        super.update(elapsed);

        switch(selectionOption)
        {
            case 2: 
                if (PlayerControls.UP_P) //back up to top row
                {
                    selectionOption = 0;
                    changeSelection();
                }
            default:
                if (PlayerControls.LEFT_P || PlayerControls.RIGHT_P)
                {
                    if (selectionOption == 0)
                        selectionOption = 1;
                    else
                        selectionOption = 0;
                    changeSelection();
                }
                else if (PlayerControls.DOWN_P) //switch to bottom row
                {
                    selectionOption = 2;
                    changeSelection();
                }
        }

        if (PlayerControls.INTERACT_P)
        {
            switch(optionsList[selectionOption])
            {
                case "Continue": 
                    FlxTransitionableState.skipNextTransIn = true;
                    FlxTransitionableState.skipNextTransOut = true;
                    FlxG.sound.music.stop();
                    MusicBeatState.switchState(new OverworldState(PlayerStats.lastRoom));
                case "Reset": 
                    //PlayerStats.reset();
                    persistentUpdate = false;
                    openSubState(new NameChooseSubstate());
                    
                case "Settings":
                    MusicBeatState.switchState(new options.OptionsState());
            }
        }
            
    }

    function changeSelection(change:Int = 0)
    {
        //FlxG.sound.play(Paths.sound("snd_select"));

        selectionOption += change;
        if (selectionOption < 0)
            selectionOption = optionsList.length-1;
        if (selectionOption > optionsList.length-1)
            selectionOption = 0;

        for (i in 0...optionsTexts.length)
        {
            var text = optionsTexts[i];
            if (i == selectionOption)
                text.color = 0xFFFFFF00;
            else 
                text.color = 0xFFFFFFFF;
        }
    }
}


class NameChooseSubstate extends MusicBeatSubstate
{
    var leftChoice:Bool = false;

    var name:UTText;
    var title:UTText;
    var yes:UTText;
    var no:UTText;

    override public function create()
    {
        super.create();
        var black = new FlxSprite().makeGraphic(1280,720, 0xFF000000);
        add(black);

        title = new UTText(320, 100, 0, "A name has already \nbeen chosen.\n");
        title.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(title);
        title.screenCenter(X);

        name = new UTText(320, 200, 0, PlayerStats.name);
        name.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(name);
        name.screenCenter(X);

        yes = new UTText(320, 600, 640, "Yes");
        yes.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, RIGHT);
        add(yes);
        yes.color = 0xFFFFFF00;
        no = new UTText(320, 600, 640, "No");
        no.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(no);

        FlxTween.tween(name, {y: 450}, 5);
        FlxTween.tween(name.scale, {x: 3, y: 3}, 5);
    }

    var exiting:Bool = false;

    var elapsedTime:Float = 0;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        elapsedTime += elapsed;
        if (elapsedTime > 1/30)
        {
            elapsedTime -= 1/30;
            name.angle = FlxG.random.float(-2, 2);
            name.offset.x = FlxG.random.float(-1, 1);
            name.offset.y = FlxG.random.float(-1, 1);
        }

        name.screenCenter(X);

        if (PlayerControls.LEFT_P || PlayerControls.RIGHT_P)
        {
            leftChoice = !leftChoice;
            if (leftChoice)
            {
                yes.color = 0xFFFFFFFF;
                no.color = 0xFFFFFF00;
            }
            else 
            {
                yes.color = 0xFFFFFF00;
                no.color = 0xFFFFFFFF;
            }
        }

        if (PlayerControls.INTERACT_P)
        {
            if (leftChoice)
            {
                close();
                FlxG.state.persistentUpdate = true;
                return;
            }

            yes.visible = false;
            no.visible = false;
            title.visible = false;

            exiting = true;
            var white = new FlxSprite().makeGraphic(1280,720);
            white.alpha = 0;
            add(white);
            
            FlxG.sound.music.stop();
            var snd = FlxG.sound.play(Paths.sound("mus_cymbal"));
            FlxTween.tween(white, {alpha: 1}, snd.length*0.001);
            snd.onComplete = function()
            {
                PlayerStats.reset();
                CustomFadeTransition.doUTTrans = true;
                MusicBeatState.switchState(new OverworldState("firstRoom"));
            }
        }
    }
}