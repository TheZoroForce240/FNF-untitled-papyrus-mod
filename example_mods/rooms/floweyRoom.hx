var room = null;
function init(r)
{
    room = r;
}
var flowey = null;
function onCreatePost()
{
    flowey = room.npcs.get("flowey");
    flowey.x -= 2;
    flowey.ignoreAnims = true;
    flowey.animation.addByPrefix("talk", "talk", 8, true);
    if (PlayerStats.extraData.exists("encounteredFlowey"))
    {
        flowey.visible = false;
    }
}

var curDial = null;

function eventTriggered(name)
{
    if (name == "floweyIntro")
    {
        if (PlayerStats.extraData.exists("encounteredFlowey"))
        {
            //room.changeRoom("papFightRoom");//need to setup cutscene
            room.player.player = false; //prevent movement
            new FlxTimer().start(1, function(t)
            {
                var black = new FlxSprite();
                black.makeGraphic(1280,720,0xFF000000);
                black.cameras = [room.camHUD];
                black.screenCenter();
                room.add(black);
                black.alpha = 0; 
                FlxTween.tween(black, {alpha: 1}, 2.5); //fade out

                new FlxTimer().start(2.5, function(t)
                {
                    //show text
                    var text = new UTText(0,0,0,"Later...");
                    text.setFormat(Paths.font("DeterminationMono.ttf"), 64, 0xFFFFFFFF);
                    text.cameras = [room.camHUD];
                    text.screenCenter();
                    text.x = (960*0.5)-(text.width*0.5);
                    room.add(text);

                    new FlxTimer().start(1.0, function(t)
                    {
                        var black2 = new FlxSprite(); //fade out again
                        black2.makeGraphic(1280,720,0xFF000000);
                        black2.cameras = [room.camHUD];
                        black2.screenCenter();
                        room.add(black2);
                        black2.alpha = 0;

                        FlxTween.tween(black2, {alpha: 1}, 1.5);
                        new FlxTimer().start(2.0, function(t)
                        {
                            //finally exit the room
                            room.changeRoom("papFightRoom");
                        });
                    });
                });
            });
            return;
        }
            

        FlxG.sound.playMusic(Paths.inst("your-best-friend"), 1, true);
        curDial = new DialogueHUDMenu(room, [
            {text: "* Howdy!##########\n* I'm FLOWEY.##########\n* FLOWEY the FLOWER!##########", sound: "snd_floweytalk1", fontSize: 42, face: "flowey", 
            formats: [{startIndex: 25, endIndex: 30, color: 0xFFFFFF00}, {startIndex: 45, endIndex: 50, color: 0xFFFFFF00}, {startIndex: 56, endIndex: 61, color: 0xFFFFFF00}]},
            {text: "* You're new to the\n  UNDERGROUND,####### aren'tcha?", sound: "snd_floweytalk1", fontSize: 42, face: "flowey"},
            {text: "* Golly,####### you must be\n  so confused.", sound: "snd_floweytalk1", fontSize: 42, face: "flowey"},
            {text: "* Someone ought to teach\n  you how things work\n  around here!", sound: "snd_floweytalk1", fontSize: 42, face: "flowey"},
            {text: "* I guess little old me\n  will have to do.", sound: "snd_floweytalk1", fontSize: 42, face: "flowey"},
            {text: "* Ready?#######\n* Here we go!#####", sound: "snd_floweytalk1", fontSize: 42, face: "flowey"},
        ]);
        curDial.dialogueBox.y = 20;
        curDial.onComplete = function()
        {
            room.startBattle("your-best-friend");
        }
        PlayerStats.extraData.set("encounteredFlowey", true);
        room.openMenu(curDial);
    }
}

function onUpdate(elapsed)
{
    if (curDial != null)
    {
        if (!curDial.finished)
        {   
            if (curDial.dialogueBox.manager.face == "flowey")
            {
                if (!curDial.dialogueBox.manager.finishedDialogue)
                {
                    if (curDial.dialogueBox.manager.finishedLine)
                    {
                        flowey.animation.play("downIdle", true);
                    }
                    else 
                    {
                        flowey.animation.play("talk", false);
                    }
                }
                else 
                {
                    flowey.animation.play("downIdle", true);
                }
            }
        }
    }
}