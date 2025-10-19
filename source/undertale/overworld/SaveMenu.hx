package undertale.overworld;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class SaveMenu extends OverworldHUDMenu
{
    var list:Array<String> = ["Save", "Return"];
    var optionTexts:Array<UTText> = [];
    var heart:PlayerHeart;

    var selectionOption:Int = 0;

    var name:UTText;
    var lv:UTText;
    var time:UTText;
    var room:UTText;

    override public function new(instance:OverworldState)
    {
        super(instance);

        var infoBox = new UndertaleBox(650, 280);
        infoBox.y = 180;
        infoBox.x = (960*0.5)-(650*0.5);
        add(infoBox);

        var gap = 40;

        name = new UTText(infoBox.x+gap, infoBox.y+gap, 650-(gap*2), PlayerStats.name);
        name.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT, NONE);
        add(name);

        lv = new UTText(name.x, name.y, name.fieldWidth, "LV"+ PlayerStats.saveFile.data.lv);
        lv.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, CENTER);
        add(lv);

        time = new UTText(name.x, name.y, name.fieldWidth, PlayerStats.getFormattedTimePlayed(PlayerStats.saveFile.data.timePlayed));
        time.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, RIGHT);
        add(time);

        room = new UTText(name.x, lv.y+60, name.fieldWidth, PlayerStats.saveFile.data.lastRoomTitle);
        room.setFormat(Paths.font("DeterminationMono.ttf"), 48, FlxColor.WHITE, LEFT);
        add(room);

        heart = new PlayerHeart(null);
        //heart.x = selectionBox.x + 25;
        add(heart);

        for (i in 0...list.length)
        {
            var text = new UTText(infoBox.x + 75 + (650*i*0.5), room.y + 100, 0, list[i]);
            text.setFormat(Paths.font("DeterminationMono.ttf"), 48);
            optionTexts.push(text);
            add(text);
        }

        changeSelection();
    }
    var justOpened:Bool = true;
    var saved:Bool = false;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (justOpened)
        {
            justOpened = false;
            return;
        }

        if (PlayerControls.BACK_P)
        {
            instance.closeMenu();
            return;
        }

        if (PlayerControls.LEFT_P)
            changeSelection(-1);
        if (PlayerControls.RIGHT_P)
            changeSelection(1);
        if (PlayerControls.INTERACT_P)
        {
            if (saved)
            {
                instance.closeMenu();
                return; 
            }
            switch(list[selectionOption])
            {
                case "Save": 
                    FlxG.sound.play(Paths.sound("snd_save"));
                    saved = true;
                    PlayerStats.save();
                    lv.text = "LV"+PlayerStats.lv;
                    time.text = PlayerStats.getFormattedTimePlayed();
                    room.text = PlayerStats.lastRoomTitle;

                    name.color = 0xFFFFFF00;
                    lv.color = 0xFFFFFF00;
                    time.color = 0xFFFFFF00;
                    room.color = 0xFFFFFF00;
                    heart.visible = false;

                    for (i in 0...optionTexts.length)
                    {
                        var text = optionTexts[i];
                        if (i == selectionOption)
                        {
                            text.color = 0xFFFFFF00;
                            text.text = "File Saved.";
                        }
                        else 
                            text.visible = false;
                    }

                case "Return": 
                    instance.closeMenu();
            }
        }
    
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound("snd_squeak"));

        selectionOption += change;
        if (selectionOption < 0)
            selectionOption = list.length-1;
        if (selectionOption > list.length-1)
            selectionOption = 0;

        for (i in 0...optionTexts.length)
        {
            var text = optionTexts[i];
            if (i == selectionOption)
            {
                //text.color = 0xFFFFFF00;
                heart.x = (text.x - heart.width)-10;
                heart.y = text.y + text.height*0.5 - heart.height*0.5;
            }
            //else 
                //text.color = 0xFFFFFFFF;
        }
    }
}