package undertale.overworld;

import undertale.DialogueManager.BoxDialogueDisplay;
import undertale.DialogueManager.DialogueData;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class PlayerHUDMenu extends OverworldHUDMenu
{
    var list:Array<String> = ["ITEM", "STAT"];
    var optionTexts:Array<UTText> = [];
    var heart:PlayerHeart;

    var selectionOption:Int = 0;
    var inSubMenu:Bool = false;

    var subMenuGroup:FlxSpriteGroup;

    var selectedItem:Int = 0;
    var pickedItem:Bool = false;
    var itemOptionList:Array<String> = ["USE", "INFO", "DROP"];
    var selectedItemOption:Int = 0;

    var dialogueBox:BoxDialogueDisplay;
    var inDialogue:Bool = false;

    override public function new(instance:OverworldState)
    {
        super(instance);

        if (PlayerStats.hasPhone)
            list.push("CELL");

        var infoBox = new UndertaleBox(200, 150);
        infoBox.x = (960*0.5)-(850*0.5);
        infoBox.y = 80;
        add(infoBox);

        var playerName:UTText = new UTText(infoBox.x + 16, infoBox.y + 12, 0, PlayerStats.name);
        playerName.setFormat(Paths.font("DeterminationMono.ttf"), 40);
        add(playerName);

        var lv:UTText = new UTText(playerName.x, playerName.y + playerName.height+4, 0, "LV  "+PlayerStats.lv);
        lv.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 14);
        add(lv);

        var hp:UTText = new UTText(playerName.x, lv.y + lv.height+2, 0, "HP  "+PlayerStats.hp + "/"+PlayerStats.hpMax);
        hp.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 14);
        add(hp);

        var gold:UTText = new UTText(playerName.x, hp.y + hp.height+2, 0, "G   "+PlayerStats.gold);
        gold.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 14);
        add(gold);

        var selectionBox = new UndertaleBox(200, 220);
        selectionBox.x = (960*0.5)-(850*0.5);
        selectionBox.y = infoBox.y+150+10;
        add(selectionBox);

        heart = new PlayerHeart(null);
        heart.x = selectionBox.x + 25;
       

        for (i in 0...list.length)
        {
            var text = new UTText(selectionBox.x + 65, selectionBox.y + 25 + (56*i), 0, list[i]);
            text.setFormat(Paths.font("DeterminationMono.ttf"), 48);
            optionTexts.push(text);
            add(text);

            if (list[i] == "ITEM")
            {
                if (PlayerStats.getItemList().length == 0)
                    text.color = 0xFF777777;
            }
        }

        subMenuGroup = new FlxSpriteGroup();
        add(subMenuGroup);

        add(heart);

        dialogueBox = new BoxDialogueDisplay();
        dialogueBox.visible = false;
        add(dialogueBox);

        dialogueBox.x = (960*0.5)-(850*0.5);
        dialogueBox.y = selectionBox.y+10+220;

        FlxG.sound.play(Paths.sound("snd_select"));

        changeSelection();
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (inDialogue)
        {
            if (PlayerControls.INTERACT_P && dialogueBox.manager.finishedLine)
            {
                dialogueBox.manager.startNext();
            }
            else if (PlayerControls.BACK_P)
            {
                dialogueBox.manager.skip();
            }

            if (dialogueBox.manager.finishedDialogue && PlayerControls.INTERACT_P)
            {
                instance.closeMenu();
            }

            return;
        }

        if (!inSubMenu)
        {
            if (PlayerControls.BACK_P || PlayerControls.MENU_P)
            {
                instance.closeMenu();
                return;
            }
    
            if (PlayerControls.UP_P)
                changeSelection(-1);
            if (PlayerControls.DOWN_P)
                changeSelection(1);
            if (PlayerControls.INTERACT_P)
                selectSubMenu();
        }
        else 
        {
            if (PlayerControls.BACK_P)
            {
                FlxG.sound.play(Paths.sound("snd_select"));
                switch(list[selectionOption])
                {
                    case "ITEM": 
                        if (!pickedItem)
                            closeSubMenu();
                        else 
                        {
                            pickedItem = false;
                            changeSelection();
                        }
                    default: 
                        closeSubMenu();
                }
            }
            if (PlayerControls.INTERACT_P)
            {
                FlxG.sound.play(Paths.sound("snd_select"));
                switch(list[selectionOption])
                {
                    case "ITEM": 
                        if (!pickedItem)
                        {
                            pickedItem = true;
                            changeSelection();
                        }
                        else 
                        {
                            switch(itemOptionList[selectedItemOption])
                            {
                                case "USE": 
                                    var item = Item.createItem(itemTexts[selectedItem].text);
                                    switch(item.data.type)
                                    {
                                        case "heal": 
                                            PlayerStats.hp += item.data.heal;
                                            var hpHealText:String = "* You recovered "+item.data.heal+" HP";
                                            if (PlayerStats.hp >= PlayerStats.hpMax)
                                            {
                                                PlayerStats.hp = PlayerStats.hpMax;
                                                hpHealText = "* Your HP was maxed out.";
                                            }
                                            showDialogue([
                                                {text: item.getItemDialogueText() + "\n" +hpHealText, sound: "SND_TXT1"}
                                            ]);
                                            FlxG.sound.play(Paths.sound("snd_heal_c"));
                                            PlayerStats.removeItemFromInventory(selectedItem);
                                    }
                                case "INFO": 
                                    var item = Item.createItem(itemTexts[selectedItem].text);
                                    var text = '* "'+item.name+'"';
                                    switch(item.data.type)
                                    {
                                        case "heal": 
                                            text += ' Heals ' + item.data.heal + " HP";
                                        case "weapon": 
                                            text += ' Weapon AT ' + item.data.atk;
                                        case "armor": 
                                            text += ' Armor DF ' + item.data.def;
                                    }
                                    showDialogue([
                                        {text: text + "\n* " + item.data.desc, sound: "SND_TXT1"}
                                    ]);
                                case "DROP": 
                                    var item = Item.createItem(itemTexts[selectedItem].text);
                                    showDialogue([
                                        {text: "* The "+item.name+" was thrown away.", sound: "SND_TXT1"}
                                    ]);
                                    PlayerStats.removeItemFromInventory(selectedItem);

                            }
                        }
                }   
            }

            switch(list[selectionOption])
            {
                case "ITEM": 
                    if (!pickedItem)
                    {
                        if (PlayerControls.UP_P)
                            changeSelection(-1);
                        if (PlayerControls.DOWN_P)
                            changeSelection(1);
                    }
                    else 
                    {
                        if (PlayerControls.LEFT_P) //change for when selecting what to do with item
                            changeSelection(-1);
                        if (PlayerControls.RIGHT_P)
                            changeSelection(1);
                    }
            }
        }
    }

    function changeSelection(change:Int = 0)
    {
        if (change != 0)
            FlxG.sound.play(Paths.sound("snd_squeak"));

        if (inSubMenu)
        {
            switch(list[selectionOption])
            {
                case "ITEM": 
                    if (pickedItem)
                    {
                        selectedItemOption += change;
                        selectedItemOption = boundVal(selectedItemOption, itemOptionTexts.length);
                        for (i in 0...itemOptionTexts.length)
                        {
                            var text = itemOptionTexts[i];
                            if (i == selectedItemOption)
                            {
                                heart.x = (text.x - heart.width)-10;
                                heart.y = text.y + text.height*0.5 - heart.height*0.5;
                            }
                        }
                    }
                    else 
                    {
                        selectedItem += change;
                        selectedItem = boundVal(selectedItem, itemTexts.length);
                        for (i in 0...itemTexts.length)
                        {
                            var text = itemTexts[i];
                            if (i == selectedItem)
                            {
                                heart.x = (text.x - heart.width)-10;
                                heart.y = text.y + text.height*0.5 - heart.height*0.5;
                            }
                        }
                    }
                    
            }

            return;
        }

        selectionOption += change;
        selectionOption = boundVal(selectionOption, list.length);

        for (i in 0...optionTexts.length)
        {
            var text = optionTexts[i];
            if (i == selectionOption)
            {
                heart.x = (text.x - heart.width)-10;
                heart.y = text.y + text.height*0.5 - heart.height*0.5;
            }
        }
    }

    function boundVal(i:Int, length:Int)
    {
        if (i < 0)
            i = length-1;
        if (i > length-1)
            i = 0;
        return i;
    }

    var itemTexts:Array<UTText> = [];
    var itemOptionTexts:Array<UTText> = [];

    function selectSubMenu()
    {
        FlxG.sound.play(Paths.sound("snd_select"));
        inSubMenu = true;
        switch(list[selectionOption])
        {
            case "STAT": 
                var box = new UndertaleBox(500, 600);
                box.x = 210+50;
                box.y = 80;
                subMenuGroup.add(box);

                var name = new UTText(box.x+25, box.y+40, 0, '"'+PlayerStats.name+'"');
                name.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(name);

                var lv = new UTText(name.x, name.y+90, 0, "LV "+PlayerStats.lv);
                lv.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(lv);

                var hp = new UTText(name.x, lv.y+45, 0, "HP "+PlayerStats.hp + "/"+PlayerStats.hpMax);
                hp.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(hp);

                var atk = new UTText(name.x, hp.y+90, 0, "AT "+PlayerStats.getLevelATK()+"("+PlayerStats.getWeaponATK()+")");
                atk.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(atk);

                var def = new UTText(name.x, atk.y+45, 0, "DF "+PlayerStats.getLevelDEF()+"("+PlayerStats.getArmorDEF()+")");
                def.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(def);

                var exp = new UTText(name.x+250, hp.y+90, 0, "EXP:"+PlayerStats.exp);
                exp.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(exp);

                var next = new UTText(name.x+250, atk.y+45, 0, "NEXT:"+PlayerStats.getEXPTillNext());
                next.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(next);


                var weapon = new UTText(name.x, def.y+90, 0, "WEAPON:"+PlayerStats.getWeaponName());
                weapon.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(weapon);

                var armor = new UTText(name.x, weapon.y+45, 0, "ARMOR:"+PlayerStats.getArmorName());
                armor.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(armor);

                var gold = new UTText(name.x, armor.y+75, 0, "GOLD:"+PlayerStats.gold);
                gold.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                subMenuGroup.add(gold);
            case "ITEM": 
                if (PlayerStats.getItemList().length == 0)
                {
                    inSubMenu = false;
                    return;
                }
                var box = new UndertaleBox(500, 600);
                box.x = 210+50;
                box.y = 80;
                subMenuGroup.add(box);

                var list = PlayerStats.getItemList();
                for (i in 0...list.length)
                {
                    var item = new UTText(box.x+70, box.y+40 + (45*i), 0, list[i]);
                    item.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                    subMenuGroup.add(item);
                    itemTexts.push(item);
                }

                for (i in 0...itemOptionList.length)
                {
                    var item = new UTText(box.x+70 + (150*i), box.y+500, 0, itemOptionList[i]);
                    item.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                    subMenuGroup.add(item);
                    itemOptionTexts.push(item);
                }

                changeSelection();
        }
    }

    function closeSubMenu()
    {
        subMenuGroup.clear();
        inSubMenu = false;
        changeSelection();
    }

    function showDialogue(d:Array<DialogueData>)
    {
        closeSubMenu();
        dialogueBox.visible = true;
        dialogueBox.setDialogue(d);
        dialogueBox.manager.startNext();
        inDialogue = true;
    }

}