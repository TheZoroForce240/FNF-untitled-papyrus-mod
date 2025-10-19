
var room = null;
function init(r)
{
    room = r;
}
var inCutscene = false;
var snow = null;
function onCreatePost()
{
    snow = new FlxBackdrop(Paths.image("overworld/snowyStuff"));
    snow.alpha = 0.5;
    snow.velocity.x = -10;
    room.add(snow);
}
function eventTriggered(name)
{
    if (name == "papFightStart")
    {
        //room.startBattle("bonetrousle");
        inCutscene = true;
        snow.alpha = 1;
        room.player.player = false;
        room.player.alpha = 0;
        room.player.color = 0xFF000000;
        room.remove(room.player);
        room.add(room.player); //reorder on top of snow

        FlxG.camera.follow(null);

        FlxTween.tween(room.camGame.scroll, {x: room.camGame.scroll.x+100}, 1);

        new FlxTimer().start(2, function(tmr)
        {
            FlxTween.tween(room.player, {alpha: 1}, 2);
            new FlxTimer().start(2, function(tmr)
            {
                //FlxTween.tween(room.player, {alpha: 1}, 2);
                new FlxTimer().start(3, function(tmr)
                {
                    //room.startBattle("bonetrousle");

                    var curDial = new DialogueHUDMenu(room, [
                        {text: "HUMAN.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 48},
                        {text: "ALLOW ME TO TELL\nYOU ABOUT SOME\nCOMPLEX FEELINGS.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 48},
                    ]);
                    curDial.onComplete = function()
                    {
                        room.startBattle("bonetrousle");
                    }
                    room.openMenu(curDial);
                });
            });
        });
    }
}
function interactTriggered(name)
{
    if (name == "papDoor")
    {
        room.openMenu(new DialogueHUDMenu(room, [
            {text: "* (It's locked from the inside.)", sound: "SND_TXT1"}
        ]));
    }
}

function onUpdate(elapsed)
{
    if (!inCutscene)
    {
        var a = (0-(Math.abs(room.player.x-800)/700))+1;
        snow.alpha = a;
    }

}