
var menu = null;
function init(m)
{
    menu = m;
    menu.character.sprite.animation.addByPrefix("evil", "evil", 8, true);
    menu.character.sprite.animation.addByPrefix("nice", "nice", 8, true);
    menu.character.sprite.animation.addByPrefix("idle", "idle", 8, true);
    menu.character.sprite.animation.addByPrefix("pissed", "pissed", 8, true);
    menu.character.sprite.animation.addByPrefix("side0", "side0", 8, true);
    menu.character.sprite.animation.addByPrefix("sassy", "sassy", 8, true);
    menu.character.sprite.animation.addByPrefix("leave", "leave", 16, false);
    menu.character.y -= 50;
    menu.character.updateDialoguePosition();
}
function start()
{
    menu.startCharacterDialogue();
    for (i in 0...menu.buttons.length)
    {
        menu.buttons[i].visible = false;
    }
    menu.displayingCharacterDialogue = false;
    new FlxTimer().start(4.5, function(tmr:FlxTimer)
    {
        menu.character.dialogue.manager.startNext();
        menu.character.dialogue.visible = false;
        menu.startNextAttack();
    });
}
var battleProgress = -1;
function generateFightMenu(list)
{

}
function generateActMenu(list)
{
    
}
function generateMercyMenu(list)
{

}
function startTurn()
{
    battleProgress++;
    menu.nextAttack = "blank";
    if (battleProgress == 3)
    {
        menu.startCharacterDialogue();
        menu.displayingCharacterDialogue = false;
        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            menu.character.dialogue.manager.startNext();
            new FlxTimer().start(2, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
                new FlxTimer().start(2, function(tmr:FlxTimer)
                {
                    menu.character.dialogue.manager.startNext();
                    new FlxTimer().start(2, function(tmr:FlxTimer)
                    {
                        //menu.character.dialogue.manager.startNext();
                        //menu.character.dialogue.visible = false;
                        menu.nextAttack = "";
                        menu.startNextAttack();
                        menu.arrowBox.x = menu.battleManager.box.x;
                        menu.arrowBox.y = menu.battleManager.box.y;
                        menu.arrowBox.boxWidth = 200;
                        menu.arrowBox.boxHeight = 200;
                        menu.arrowBox.updateBoxSize();
                        menu.arrowBox.visible = true;
                        menu.battleManager.box.visible = false;
                        menu.battleManager.heart.visible = false;
                        FlxTween.tween(menu.arrowBox, {boxWidth: menu.aBoxWidth, boxHeight: menu.aBoxHeight, 
                            x: menu.aBoxX, y: menu.aBoxY}, 0.5, {ease:FlxEase.cubeOut}); //tween into the new size  

                        battleProgress++;
                        menu.startCharacterDialogue();
                        menu.displayingCharacterDialogue = false;
                        new FlxTimer().start(1.5, function(tmr:FlxTimer)
                        {
                            menu.character.dialogue.manager.startNext();
                        });
                    });
                });
            });
        });
    }
    else if (battleProgress == 5)
    {
        trace('end shit');
        menu.startCharacterDialogue();
        new FlxTimer().start(2.5, function(tmr:FlxTimer)
        {
            menu.character.dialogue.manager.startNext();
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
                new FlxTimer().start(2.5, function(tmr:FlxTimer)
                {
                    menu.character.dialogue.manager.startNext();
                    menu.character.dialogue.visible = false;
                    menu.startNextAttack();
                });
            });
        });
    }
    //menu.startCharacterDialogue();
}
function characterStartDialogue()
{
    switch(battleProgress)
    {
        /*case 0: 
            menu.setCharacterDialogue([
                {text: "See that heart?#########\nThat is your SOUL,########\nthe very culmination\nof your being!", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 1: 
            menu.setCharacterDialogue([
                {text: "Your SOUL starts off\nweak,####### but can grow\nstrong if you gain\na lot of LV.", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "What's LV Stand for?#########\nWhy,####### LOVE,#### of course!", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "You want some\nLOVE,#### don't you?", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"}
            ]);
        case 2: 
            menu.setCharacterDialogue([
                {text: "Don't worry,#######\nI'll share...", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 3:
            menu.setCharacterDialogue([
                {text: "What.#######\nare you doing!?!", sound: "snd_floweytalk1", fontSize: 20, face: "idle", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "Why are you\nsinging!?!?", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.035, font: "dotumche-pixel.ttf"},
                {text: "I'm trying to\nhelp you here!", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.035, font: "dotumche-pixel.ttf"},
            ]);
        case 4:
            menu.setCharacterDialogue([
                {text: "So,########\nas I was saying,######\nyou need to LOVE to\nsurvive down here.", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);*/

        case 0: 
            menu.setCharacterDialogue([
                {text: "See that heart?#########\nThat is your SOUL,########\nthe very culmination\nof your being!", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 1: 
            menu.setCharacterDialogue([
                {text: "Your SOUL starts off\nweak,####### but can grow\nstrong if you gain\na lot of LV.", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "What's LV stand for?#########\nWhy,####### LOVE,#### of course!", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "You want some\nLOVE,#### don't you?", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 2:
            menu.setCharacterDialogue([
                //bf starts singing mid dialogue
                {text: "Don't worry,#####\nI can##.##.##.##.##.##.##.", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "What are you even\ndoing???", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.05, font: "dotumche-pixel.ttf"},
            ]);
        case 3:
            menu.setCharacterDialogue([
                {text: "Hey!##########################\nAre you gonna listen \nnow!?", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.025, font: "dotumche-pixel.ttf"},
                {text: "...", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.05, font: "dotumche-pixel.ttf"},
                {text: "So,#####\nas I was saying,", sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: 'I can share you\nsome "LOVE"!', sound: "snd_floweytalk1", fontSize: 20, face: "side0", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 4:
            menu.setCharacterDialogue([
                //bf starts singing mid dialogue again
                {text: 'Just let me gi-', sound: "snd_floweytalk1", fontSize: 20, face: "nice", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "######Is this a joke?#########################\nI'm trying to help\nyou here!", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
        case 5:
            menu.setCharacterDialogue([
                {text: "Well if you're not\ngonna take this\nseriously,", sound: "snd_floweytalk1", fontSize: 20, face: "sassy", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "Then I'm leaving!", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.045, font: "dotumche-pixel.ttf"},
                {text: "You can deal\nwith this crap\non your own!", sound: "snd_floweytalk1", fontSize: 20, face: "pissed", speed: 0.045, font: "dotumche-pixel.ttf"},
            ]);
    }


}

function onStartAttack(name)
{
    //if (menu.nextAttack == "blank")
    //{

    switch(battleProgress)
    {
        case -1: 

        case 0: 
            battleProgress++;
            menu.startCharacterDialogue();
            menu.displayingCharacterDialogue = false;
            menu.nextAttack = "";
            new FlxTimer().start(4.5, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(8, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(9, function(tmr:FlxTimer)
            {
                //menu.character.dialogue.manager.startNext();
                //menu.endAttack();
                //menu.character.dialogue.visible = false;
                menu.nextAttack = "";
                menu.startNextAttack();
                menu.arrowBox.x = menu.battleManager.box.x;
                menu.arrowBox.y = menu.battleManager.box.y;
                menu.arrowBox.boxWidth = 200;
                menu.arrowBox.boxHeight = 200;
                menu.arrowBox.updateBoxSize();
                menu.arrowBox.visible = true;
                menu.battleManager.box.visible = false;
                menu.battleManager.heart.visible = false;
                FlxTween.tween(menu.arrowBox, {boxWidth: menu.aBoxWidth, boxHeight: menu.aBoxHeight, 
                    x: menu.aBoxX, y: menu.aBoxY}, 0.5, {ease:FlxEase.cubeOut}); //tween into the new size  
            });
            new FlxTimer().start(11, function(tmr:FlxTimer)
            {
                battleProgress++;
                menu.startCharacterDialogue();
                menu.displayingCharacterDialogue = false;
                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    menu.character.dialogue.setFace("idle");
                });
                new FlxTimer().start(3, function(tmr:FlxTimer)
                {
                    menu.character.dialogue.manager.startNext();
                });
            });
        case 1: 

        case 4: 
            /*battleProgress++;
            menu.displayingCharacterDialogue = false;
            menu.nextAttack = "";
            new FlxTimer().start(4.5, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(8, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(9, function(tmr:FlxTimer)
            {
                //menu.character.dialogue.manager.startNext();
                //menu.endAttack();
                //menu.character.dialogue.visible = false;
                menu.nextAttack = "";
                menu.startNextAttack();
                menu.arrowBox.x = menu.battleManager.box.x;
                menu.arrowBox.y = menu.battleManager.box.y;
                menu.arrowBox.boxWidth = 200;
                menu.arrowBox.boxHeight = 200;
                menu.arrowBox.updateBoxSize();
                menu.arrowBox.visible = true;
                menu.battleManager.box.visible = false;
                menu.battleManager.heart.visible = false;
                FlxTween.tween(menu.arrowBox, {boxWidth: menu.aBoxWidth, boxHeight: menu.aBoxHeight, 
                    x: menu.aBoxX, y: menu.aBoxY}, 0.5, {ease:FlxEase.cubeOut}); //tween into the new size  
            });
            new FlxTimer().start(11, function(tmr:FlxTimer)
            {
                battleProgress++;
                menu.startCharacterDialogue();
                menu.displayingCharacterDialogue = false;
                new FlxTimer().start(3, function(tmr:FlxTimer)
                {
                    menu.character.dialogue.manager.startNext();
                });
            });*/
        case 5: 
            menu.character.sprite.animation.play("leave", true);
            menu.character.sprite.animation.finishCallback = function(name)
            {
                menu.character.sprite.visible = false;
            }
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
            {
                FlxG.sound.music.fadeOut(1.5);
                new FlxTimer().start(1.5, function(tmr:FlxTimer)
                {
                    trace('end');
                    menu.exitBattle();
                });
            });
    }

        /*if (battleProgress == 2)
        {
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                battleProgress++;
                menu.startCharacterDialogue();
                menu.displayingCharacterDialogue = false;
            });
            
            new FlxTimer().start(4, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(6, function(tmr:FlxTimer)
            {
                menu.character.dialogue.manager.startNext();
            });
            new FlxTimer().start(8, function(tmr:FlxTimer)
            {
                menu.character.dialogue.visible = false;
            });
        }
        else 
        {
            battleProgress++;
            menu.startCharacterDialogue();
        } */
    //}    
}

function onUseItem(itemName)
{

}

function onSongStart()
{
    
}