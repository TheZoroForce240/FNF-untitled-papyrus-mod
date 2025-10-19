package undertale.menus;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.FlxG;

class TitlePopup extends MusicBeatState
{
    override public function create()
    {
        super.create();

        new FlxTimer().start(1.0, function(t)
        {
            var logo = new FlxSprite().loadGraphic(Paths.image("mainmenu/ut"));
            logo.screenCenter();
            add(logo);
    
            var snd = FlxG.sound.play(Paths.music("mus_intronoise"));
    
            snd.onComplete = function()
            {
    
            }
    
            new FlxTimer().start(1.0, function(t)
            {
                //showTxt();
                var fall = FlxG.sound.play(Paths.sound("snd_fall2"));
                var bfIn = new FlxSprite().loadGraphic(Paths.image("mainmenu/bfIn"));
                bfIn.screenCenter();
                add(bfIn);
    
                bfIn.y -= 1000;
    
                FlxTween.tween(bfIn, {y: 450-((bfIn.height+logo.height*0.5)), angle: 720}, fall.length*0.001, {ease: FlxEase.cubeIn});
    
                new FlxTimer().start(fall.length*0.001, function(t)
                {
                    var exp = new FlxSprite();
                    exp.frames = Paths.getSparrowAtlas("mainmenu/explosion");
                    exp.animation.addByPrefix('explosion', 'explosion', 24, false);
                    exp.animation.play("explosion");
                    exp.scale.set(3,3);
                    exp.updateHitbox();
                    exp.screenCenter();
                    add(exp);
                    FlxG.sound.play(Paths.sound("snd_badexplosion"));
                    FlxTween.tween(logo, {y: bfIn.y+bfIn.height+10}, 0.5, {ease: FlxEase.cubeOut});
                    showTxt();
                });
            });
        });




    }

    function showTxt()
    {
        var text = new UTText(0, 550, 0, "[press z or enter]");
        text.setFormat(Paths.font("crypt-of-tomorrow-ut-font.ttf"), 16, 0xFF999999);
        add(text);
        text.screenCenter(X);
    }

    override public function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (PlayerControls.INTERACT_P)
        {
            exit();
        }
    }

    function exit()
    {
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        MusicBeatState.switchState(new MainMenu());
    }
}