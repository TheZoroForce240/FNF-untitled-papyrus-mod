package undertale;

import undertale.overworld.OverworldState;
import undertale.overworld.OverworldCharacter;
import undertale.DialogueManager.DialogueData;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import undertale.DialogueManager.BoxDialogueDisplay;
import flixel.group.FlxSpriteGroup;

class BattleMenu extends FlxSpriteGroup
{
    public var dialogueBox:BoxDialogueDisplay;
    public var buttons:Array<BattleMenuButton> = [];
    public var heart:PlayerHeart;

    var currentMenu:MenuList;
    var generatedMenus:Array<MenuList> = [];

    var selectedButton:Int = 0;

    public var battleManager:BattleManager;
    public var script:BattleScript;
    public var character:BattleNPC;

    public var onStartAttack:Void->Void;

    //fnf arrows
    public var arrowBox:BattleBox;
    public var aBoxX:Float = 0;
    public var aBoxY:Float = 0;
    public var aBoxWidth:Float = 0;
    public var aBoxHeight:Float = 0;


    public var nextAttack:String = "pap1";
    public var nextTurnText:DialogueData = {text: ""};
    
    var fightPopup:FightPopup;


    var playerText:UTText;
    var levelText:UTText;
    var hpSpr:FlxSprite;
    var hpBar:FlxBar;
    var healthText:UTText;

    public var hp(default, set):Int = PlayerStats.hp;
    private function set_hp(value:Int)
    {
        healthText.text = value + " / " + hpMax; //update hp text
        PlayerStats.hp = value;
        return hp = value;
    }
    var hpMax:Int = PlayerStats.hpMax;

    override public function new(battleScriptName:String = "papyrus", characterName:String = "papyrus")
    {
        super();

        character = new BattleNPC(characterName);
        add(character);

        dialogueBox = new BoxDialogueDisplay();
        dialogueBox.screenCenter(X);
        add(dialogueBox);

        playerText = new UTText(dialogueBox.x, dialogueBox.y+dialogueBox.height+15, 0, PlayerStats.name);
        playerText.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 22);
        add(playerText);

        levelText = new UTText(playerText.x + playerText.width+30, playerText.y, 0, "LV 1");
        levelText.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 22);
        add(levelText);

        hpSpr = new FlxSprite(playerText.x + 290, levelText.y+8).loadGraphic(Paths.image("ut/spr_hpname"));
        hpSpr.scale.set(1.5, 1.5);
        hpSpr.updateHitbox();
        add(hpSpr);

        hpBar = new FlxBar(hpSpr.x + hpSpr.width+15, playerText.y, LEFT_TO_RIGHT, Math.floor(2*hpMax), Math.floor(levelText.height), this, "hp", 0, hpMax);
        hpBar.createFilledBar(0xFFff1800, 0xFFfff000);
        hpBar.updateBar();
        add(hpBar);

        healthText = new UTText(hpBar.x + hpBar.width+20, playerText.y-3, 0, hp + " / " + hpMax);
        healthText.setFormat(Paths.font("undertale-mars-needs-cunnilingus.ttf"), 22);
        add(healthText);

        var buttonList:Array<String> = ["fight", "act", "item", "mercy"];
        for (i in 0...buttonList.length)
        {
            var b = new BattleMenuButton(buttonList[i]);
            b.screenCenter(X);
            b.y = dialogueBox.y+dialogueBox.height + 65;
            b.x = dialogueBox.x + (850/3.75)*i;
            add(b);
            buttons.push(b);
        }

        heart = new PlayerHeart(null);
        add(heart);

        battleManager = new BattleManager();
        battleManager.onEndAttack = endAttack;
        battleManager.onDamage = function(damage:Float)
        {
            var dmg:Int = Math.floor(PlayerStats.applyDefToDamage(character.atk, PlayerStats.def));
            if (dmg < 1)
                dmg = 1;
            hp -= dmg;
        }
        //add(battleManager);

        script = new BattleScript(battleScriptName, this);
        script.call("init", [this]);
        //add(script);

        arrowBox = new BattleBox(Std.int(Note.swagWidth*4), 1280, false, 0x44000000);
        arrowBox.screenCenter(X);
        arrowBox.y -= 500;
        add(arrowBox);
        arrowBox.visible = false;

        add(character.dialogue); //have on top

        //store default positions
        aBoxX = arrowBox.x;
        aBoxY = arrowBox.y;
        aBoxWidth = arrowBox.width;
        aBoxHeight = arrowBox.height;

        fightPopup = new FightPopup();
        fightPopup.y = 12;
        fightPopup.screenCenter(X);
        add(fightPopup);
        //fightPopup.y = dialogueBox.y + (200*0.5)-(fightPopup.height*0.5);


        generateMenus();
        resetMenu();
        script.call("start", []);
    }

    public var controlsActive:Bool = true;
    public var displayingCharacterDialogue:Bool = false;
    public var displayingDialogue:Bool = false;
    public var selectingButton:Bool = true;
    public var aboutToStartAttack:Bool = false;
    public var inAttack:Bool = false;
    public var exiting:Bool = false;

    override public function draw()
    {
        super.draw();
        battleManager.cameras = this.cameras;
        if (inAttack)
            battleManager.draw();
    }
    override public function destroy()
    {
        script.destroy();
        battleManager.destroy();
        super.destroy();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (displayingDialogue)
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
                displayingDialogue = false;
                startCharacterDialogue();
                return;
            }
        }
        else if (displayingCharacterDialogue)
        {
            if (PlayerControls.INTERACT_P && character.dialogue.manager.finishedLine)
            {
                character.dialogue.manager.startNext();
            }
            else if (PlayerControls.BACK_P)
            {
                character.dialogue.manager.skip();
            }

            if (character.dialogue.manager.finishedDialogue && PlayerControls.INTERACT_P)
            {
                displayingCharacterDialogue = false;
                character.dialogue.visible = false;
                if (!aboutToStartAttack)
                    endAttack();
                else
                    startNextAttack();
                return;
            }
        }

        if (inAttack)
        {
            battleManager.update(elapsed);
            return;
        }

        if (FlxG.keys.justPressed.I)
            character.takeDamage(100);

        if (controlsActive)
        {
            if (selectingButton)
            {
                if (PlayerControls.LEFT_P)
                    changeButton(-1);
                if (PlayerControls.RIGHT_P)
                    changeButton(1);
            }
            else 
            {
                if (currentMenu != null)
                {
                    //row/col change
                    var r:Int = 0;
                    var c:Int = 0;

                    if (PlayerControls.UP_P)
                        r--;
                    else if (PlayerControls.DOWN_P)
                        r++;
                    if (PlayerControls.LEFT_P)
                        c--;
                    else if (PlayerControls.RIGHT_P)
                        c++;

                    if (r != 0 || c != 0)
                        currentMenu.changeMenuOption(r, c);
                }
            }
            if (PlayerControls.INTERACT_P)
            {
                FlxG.sound.play(Paths.sound("snd_select"));
                if (selectingButton)
                {
                    selectingButton = false;
                    currentMenu = generatedMenus[selectedButton];
                    add(currentMenu);
                    currentMenu.changeMenuOption(0,0);
                    dialogueBox.manager.clear();
                    dialogueBox.text.visible = false;
                }
                else 
                {
                    if (currentMenu != null)
                        currentMenu.selectOption();
                }
            }
            else if (PlayerControls.BACK_P)
            {
                if (!selectingButton)
                {
                    if (currentMenu != null)
                    {
                        FlxG.sound.play(Paths.sound("snd_select"));
                        remove(currentMenu);
                        if (currentMenu.prevMenu != null)
                        {
                            add(currentMenu.prevMenu);
                            currentMenu = currentMenu.prevMenu; //go back a menu
                            currentMenu.changeMenuOption(0, 0);
                        }
                        else 
                        {
                            selectingButton = true; //back to selecting buttons
                            changeButton(0);
                            resetMenu();
                        }
                    }
                }
            }
        }
    }

    public function changeButton(change:Int = 0)
    {
        selectedButton = boundVal(selectedButton+change, buttons.length);
        for (i in 0...buttons.length)
        {
            var button = buttons[i];
            
            if (i == selectedButton)
            {
                button.animation.play("selected");
                heart.x = button.x + (button.width*0.15)-(heart.width*0.5);
                heart.y = button.y + (button.height*0.5)-(heart.height*0.5);
                //trace(heart.x);
                //trace(heart.y);
            }
            else
                button.animation.play("idle");
        }
        if (change != 0)
            FlxG.sound.play(Paths.sound("snd_squeak"));
    }

    function boundVal(val:Int, length:Int)
    {
        if (val > length-1)
            val = 0;
        else if (val < 0)
            val = length-1;
        return val;
    }


    function generateMenus()
    {
        script.call("startTurn", []);
        generatedMenus = [];
        for (i in 0...buttons.length)
        {
            switch(buttons[i].name)
            {
                case "fight":
                    var menu = new MenuList(this);
                    script.call("generateFightMenu", [menu]);
                    generatedMenus.push(menu);
                case "act": 
                    var menu = new MenuList(this);
                    script.call("generateActMenu", [menu]);
                    generatedMenus.push(menu);
                case "item":
                    var menu = new MenuList(this);

                    var itemOptions:Array<BattleMenuOption> = [];
                    var items = PlayerStats.getItems();

                    var list:Array<Array<BattleMenuOption>> = [];
                    var rowIdx:Int = -1;

                    for (i in 0...items.length)
                    {
                        itemOptions.push(new BattleMenuOption("* "+items[i].data.name, function()
                        {
                            useItem(items[i].name, i);
                        }));

                        if (i % 2 == 0)
                        {
                            rowIdx++;
                            list.push([]);
                        }
                        list[rowIdx].push(itemOptions[i]); //add to list
                    }

                    

                    if (itemOptions.length > 4)
                    {
                        var list1:Array<Array<BattleMenuOption>> = [list[0], list[1]]; //setup with first 2
                        var list2:Array<Array<BattleMenuOption>> = [list[2]];
                        if (list.length > 3)
                            list2.push(list[3]); //push last row if it can

                        var extraPage = new MenuList(this);
                        extraPage.setList(list2);                        

                        var nextPageButton = new BattleMenuOption("  Next Page", function()
                        {
                            changeMenu(extraPage);
                        });

                        list1.push([nextPageButton]);
                        menu.setList(list1);

                    }
                    else 
                    {
                        menu.setList(list);
                    }


                    generatedMenus.push(menu);
                case "mercy":
                    var menu = new MenuList(this);
                    script.call("generateMercyMenu", [menu]);
                    generatedMenus.push(menu);
            }
        }
    }

    public function fight(target:String)
    {
        heart.visible = false;
        controlsActive = false;
        if (currentMenu != null)
            remove(currentMenu);
        fightPopup.onEndFight = function(dmg:Int)
        {
            character.takeDamage(dmg);
            new FlxTimer().start(1.5, function(t)
            {
                heart.visible = true;
                startCharacterDialogue();
            });
        }
        fightPopup.startFight();
    }
    public function mercy(target:String)
    {
        startCharacterDialogue();
    }

    public function showDialogue(d:Array<DialogueData>)
    {
        resetMenu();
        controlsActive = false;
        remove(currentMenu);
        //dialogueBox.setDialogue([
        //    {text: '* PAPYRUS 8 ATK 2 DEF\n* He likes to say:\n  "Nyeh heh heh!"'},
        //]);
        dialogueBox.setDialogue(d);
        displayingDialogue = true;
        dialogueBox.manager.startNext();
    }

    public function changeMenu(newMenu:MenuList)
    {
        if (currentMenu == null)
            return;
        remove(currentMenu);
        newMenu.prevMenu = currentMenu;
        currentMenu = newMenu;
        add(currentMenu);
        currentMenu.changeMenuOption(0, 0);
    }

    public function startNextAttack()
    {
        controlsActive = false;
        if (currentMenu != null)
            remove(currentMenu);
        for (i in 0...buttons.length)
        {
            buttons[i].animation.play("idle");
        }
        //resetMenu();

        
        
        if (nextAttack != "")
            battleManager.startAttack();

        if (onStartAttack != null)
            onStartAttack();

        aboutToStartAttack = false;
    }

    public function endAttack()
    {
        if (nextAttack == "")
        {
            FlxTween.tween(arrowBox, {boxWidth: 850, boxHeight: 200, x: dialogueBox.x, y: dialogueBox.y}, 0.5, {ease:FlxEase.cubeOut, onComplete: function(twn:FlxTween)
            {
                arrowBox.visible = false;
                dialogueBox.visible = true;
                heart.visible = true;
                inAttack = false;
                generateMenus();
                resetMenu();
            }}); //tween into the new size
            return;
        }
        battleManager.box.centered = false;
        battleManager.add(battleManager.box);
        //FlxTween.tween(battleManager.heart, {x: heart.x, y: heart.y}, 0.5, {ease:FlxEase.cubeOut});
        FlxTween.tween(battleManager.box, {boxWidth: 850, boxHeight: 200, x: dialogueBox.x, y: dialogueBox.y}, 0.5, {ease:FlxEase.cubeOut, onComplete: function(twn:FlxTween)
        {
            dialogueBox.visible = true;
            heart.visible = true;
            heart.color = battleManager.heart.color;
            battleManager.clearAttack();
            inAttack = false;
            generateMenus();
            resetMenu();
        }}); //tween into the new size
    }


    var characterDialogue:Array<DialogueData> = [];

    public function setCharacterDialogue(d:Array<DialogueData>)
    {
        characterDialogue = d;
    }

    public function exitBattle()
    {
        exiting = true;
        MusicBeatState.switchState(new OverworldState(OverworldState.lastRoom));
    }

    public function startCharacterDialogue()
    {
        if (character.died)
        {
            if (!exiting)
            {
                script.call("characterDied", []);
            }
            exiting = true;
            return;
        }


        script.call("characterStartDialogue", []);
        character.dialogue.manager.setDialogue(characterDialogue);
        character.dialogue.manager.startNext();
        character.dialogue.visible = true;
        displayingCharacterDialogue = true;
        
        if (!inAttack)
            aboutToStartAttack = true;
        else 
            return; //already in attack (mid attack dialogue)

        if (currentMenu != null)
            remove(currentMenu);

        inAttack = true;
        if (nextAttack != "")
        {
            battleManager.loadAttack(nextAttack);
            var prevX = battleManager.box.x;
            var prevY = battleManager.box.y;
            var prevW = battleManager.box.width;
            var prevH = battleManager.box.height;
    
            battleManager.box.x = dialogueBox.x;
            battleManager.box.y = dialogueBox.y;
            battleManager.box.boxWidth = 850;
            battleManager.box.boxHeight = 200;
            battleManager.box.updateBoxSize();
    
            dialogueBox.visible = false;
            heart.visible = false;
    
            FlxTween.tween(battleManager.box, {boxWidth: prevW, boxHeight: prevH, x: prevX, y: prevY}, 0.5, {ease:FlxEase.cubeOut}); //tween into the new size
            //FlxTween.tween(battleManager.heart, {x: prevHX, y: prevHY}, 0.5, {ease:FlxEase.cubeOut});
        }
        else 
        {
            arrowBox.x = dialogueBox.x;
            arrowBox.y = dialogueBox.y;
            arrowBox.boxWidth = 850;
            arrowBox.boxHeight = 200;
            arrowBox.updateBoxSize();
            arrowBox.visible = true;

            FlxTween.tween(arrowBox, {boxWidth: aBoxWidth, boxHeight: aBoxHeight, x: aBoxX, y: aBoxY}, 0.5, {ease:FlxEase.cubeOut}); //tween into the new size  

            dialogueBox.visible = false;
            heart.visible = false;
        }


    }

    public function resetMenu()
    {
        controlsActive = true;
        selectingButton = true;
        dialogueBox.setDialogue([nextTurnText]);
        dialogueBox.manager.startNext();
        changeButton(0);
        dialogueBox.text.visible = true;
    }

    public function useItem(name:String, idx:Int)
    {
        var item = Item.createItem(name);

        switch(item.data.type)
        {
            case "heal": 
                hp += item.data.heal;
                var hpHealText:String = "* You recovered "+item.data.heal+" HP";
                if (hp >= hpMax)
                {
                    hp = hpMax;
                    hpHealText = "* Your HP was maxed out.";
                }
                showDialogue([
                    {text: item.getItemDialogueText() + "\n" +hpHealText}
                ]);
                FlxG.sound.play(Paths.sound("snd_heal_c"));
                PlayerStats.removeItemFromInventory(idx);
        }

        script.call("onUseItem", [name]);
    }

}


class BattleMenuButton extends FlxSprite
{
    public var name:String;
    override public function new(name:String)
    {
        super();
        this.name = name;

        loadGraphic(Paths.image("ut/buttons/"+name));
        loadGraphic(Paths.image("ut/buttons/"+name), true, Math.floor(width / 2), Math.floor(height));

        animation.add("idle", [0], 24, false);
        animation.add("selected", [1], 24, false);
        animation.play("idle");
        antialiasing = false;

        setGraphicSize(170);
        updateHitbox();
    }
}

class BattleMenuOption extends UTText
{
    public var onSelect:Void->Void;
    override public function new(text:String, onSelect:Void->Void = null)
    {
        super();
        this.text = text;
        font = Paths.font("DeterminationMono.ttf");
        size = 40;
        this.onSelect = onSelect;
    }
}

class MenuList extends FlxSpriteGroup
{
    public var list:Array<Array<BattleMenuOption>>;
    public var prevMenu:MenuList;

    var selectedMenuRow:Int = 0;
    var selectedMenuCol:Int = 0;

    var battleMenu:BattleMenu;
    override public function new(battleMenu:BattleMenu)
    {
        super();
        this.battleMenu = battleMenu;
    }

    public function setList(list:Array<Array<BattleMenuOption>>)
    {
        this.list = list;
        for (i in 0...list.length)
        {
            for (j in 0...list[i].length)
            {
                list[i][j].x = battleMenu.dialogueBox.x + (850*0.45*(j))+100;
                list[i][j].y = battleMenu.dialogueBox.y + 36 + (50*i);
                add(list[i][j]);
            }
        }

        changeMenuOption(0,0);
    }

    public function changeMenuOption(rowChange:Int = 0, colChange:Int = 0)
    {
        if (list == null || list.length == 0)
            return;
        selectedMenuRow = boundVal(selectedMenuRow+rowChange, list.length);
        selectedMenuCol = boundVal(selectedMenuCol+colChange, list[selectedMenuRow].length);

        for (i in 0...list.length) //update positions
        {
            for (j in 0...list[i].length)
            {
                list[i][j].x = battleMenu.dialogueBox.x + (850*0.45*(j))+100;
                list[i][j].y = battleMenu.dialogueBox.y + 36 + (50*i);
            }
        }

        var option = list[selectedMenuRow][selectedMenuCol];
        battleMenu.heart.x = option.x-(battleMenu.heart.width*2);
        battleMenu.heart.y = option.y + (option.height*0.5) - (battleMenu.heart.height*0.5);
    }
    public function selectOption()
    {
        if (list == null)
            return;
        if (list[selectedMenuRow][selectedMenuCol].onSelect != null)
            list[selectedMenuRow][selectedMenuCol].onSelect();
    }
    function boundVal(val:Int, length:Int)
    {
        if (val > length-1)
            val = length-1;
        else if (val < 0)
            val = 0;
        return val;
    }
}