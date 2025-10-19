package undertale.overworld;

import flixel.FlxSprite;
import flixel.FlxG;

class BoxMenu extends OverworldHUDMenu
{
    var infoBox:UndertaleBox;
    var selectedItem:Int = 0;
    var onBoxSide:Bool = false;

    var heart:PlayerHeart;

    var invTexts:Array<UTText> = [];
    var boxTexts:Array<UTText> = [];
    var lines:Array<FlxSprite> = [];

    var invSize:Int = 8;
    var boxSize:Int = 10;

    override public function new(instance:OverworldState)
    {
        super(instance);

        infoBox = new UndertaleBox(960-50, 720-50);
        infoBox.screenCenter();
        infoBox.x = (960*0.5)-(910*0.5);
        add(infoBox);

        heart = new PlayerHeart(null);
        add(heart);

        var inv = new UTText(0,60,0, "INVENTORY");
        inv.setFormat(Paths.font("DeterminationMono.ttf"), 40);
        add(inv);

        inv.x = (960*0.5)-(inv.width*0.5) - (910*0.25);

        var box = new UTText(0,60,0, "BOX");
        box.setFormat(Paths.font("DeterminationMono.ttf"), 40);
        add(box);
        box.x = (960*0.5)-(box.width*0.5) + (910*0.25);


        var finish = new UTText(0,600,0, "Press [X] to Finish");
        finish.setFormat(Paths.font("DeterminationMono.ttf"), 40);
        add(finish);
        finish.x = (960*0.5)-(finish.width*0.5);

        var line = new FlxSprite(0, 150).makeGraphic(2, 450);
        add(line);
        line.x = (960*0.5)-1;

        regenList();
    }

    function regenList()
    {
        for (i in invTexts)
            remove(i);
        for (i in boxTexts)
            remove(i);
        for (i in lines)
            remove(i);

        invTexts = [];
        boxTexts = [];
        lines = [];

        var itemList = PlayerStats.getItemList();
        for (i in 0...invSize)
        {
            if (itemList[i] != null)
            {
                var item = new UTText(25+(910*0.075),150 + (i*45),0, itemList[i]);
                item.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                add(item);
                invTexts.push(item);
            }
            else 
            {
                var line = new FlxSprite(25+(910*0.075)+20,150 + (i*45) + 24).makeGraphic(250, 2, 0xFFFF0000);
                lines.push(line);
                add(line);
            }
        }

        var boxItemList = PlayerStats.getBoxList();
        for (i in 0...boxSize)
        {
            if (boxItemList[i] != null)
            {
                var item = new UTText(25+(910*0.075) + (910*0.5),150 + (i*45),0, boxItemList[i]);
                item.setFormat(Paths.font("DeterminationMono.ttf"), 40);
                add(item);
                invTexts.push(item);
            }
            else 
            {
                var line = new FlxSprite(25+(910*0.075)+20 + (910*0.5),150 + (i*45) + 24).makeGraphic(250, 2, 0xFFFF0000);
                lines.push(line);
                add(line);
            }
        }
        changeSelection();
    }

    var justOpened:Bool = true;
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

        if (PlayerControls.UP_P)
            changeSelection(-1);
        if (PlayerControls.DOWN_P)
            changeSelection(1);

        if (PlayerControls.LEFT_P || PlayerControls.RIGHT_P)
        {
            onBoxSide = !onBoxSide;
            regenList();
            return;
        }

        if (PlayerControls.INTERACT_P)
        {
            if (onBoxSide)
            {
                //if (selectedItem < boxTexts.length)
                //{
                    var item = PlayerStats.getBoxItems()[selectedItem];
                    if (item == null)
                        return;
                    if (PlayerStats.addItemToInventory(item)) //if item added successfully
                        PlayerStats.removeItemFromBox(selectedItem);
                    regenList();
                //}
            }
            else 
            {
                //if (selectedItem < invTexts.length)
                //{
                    var item = PlayerStats.getItems()[selectedItem];
                    if (item == null)
                        return;
                    if (PlayerStats.addItemToBox(item)) //if item added successfully
                        PlayerStats.removeItemFromInventory(selectedItem);

                    regenList();
                //}
            }
        }
    }

    function changeSelection(change:Int = 0)
    {
        //FlxG.sound.play(Paths.sound("snd_select"));

        selectedItem += change;

        var len:Int = (onBoxSide ? boxSize : invSize);

        if (selectedItem < 0)
            selectedItem = len-1;
        if (selectedItem > len-1)
            selectedItem = 0;

        var x = 25+(910*0.075);
        if (onBoxSide)
            x += (910*0.5);
        var y = 150 + (selectedItem*45);
        heart.x = (x - heart.width)-10;
        heart.y = y+10;
    }
}