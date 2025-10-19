package undertale;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class FightPopup extends FlxSpriteGroup
{
    public var onEndFight:Int->Void;
    var fightSprite:FlxSprite;
    var fightLine:FlxSprite;
    override public function new()
    {
        super();

        fightSprite = new FlxSprite().loadGraphic(Paths.image("ut/spr_dumbtarget"));
        fightSprite.scale.set(1.5,1.5);
        fightSprite.updateHitbox();
        add(fightSprite);
        fightSprite.alpha = 0;

        fightLine = new FlxSprite();
        fightLine.loadGraphic(Paths.image("ut/targetLine"));
        fightLine.loadGraphic(Paths.image("ut/targetLine"), true, Math.floor(fightLine.width / 2), Math.floor(fightLine.height));
        fightLine.scale.set(1.5,1.5);
        fightLine.updateHitbox();
        fightLine.animation.add("idle", [1]);
        fightLine.animation.add("flash", [0, 1], 12, true);
        fightLine.animation.play("idle");
        add(fightLine);
        fightLine.visible = false;
        active = false;
    }

    var canPress:Bool = false;

    public function startFight()
    {
        active = true;
        fightSprite.scale.x = 1.5;
        fightSprite.alpha = 1;
        fightLine.animation.play("idle");
        new FlxTimer().start(0.25, function(t)
        {
            canPress = true;
            fightLine.visible = true;
            fightLine.x = 640-(850*0.5);
            fightLine.velocity.x = 800;
        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (canPress)
        {
            if (PlayerControls.INTERACT_P)
            {
                fightLine.animation.play("flash");
                fightLine.velocity.x = 0;
                canPress = false;
                FlxG.sound.play(Paths.sound("snd_laz"));
                new FlxTimer().start(0.5, function(t)
                {
                    var percent = Math.abs(((fightLine.x+(fightLine.width*0.5))-FlxG.width*0.5)*0.001);
                    percent = (0-percent)+1;
                    trace(percent);

                    if (onEndFight != null)
                        onEndFight(Math.ceil(PlayerStats.atk*percent));

                    new FlxTimer().start(1.0, function(t)
                    {
                        FlxTween.tween(fightSprite.scale, {x: 0.5}, 0.5);
                        FlxTween.tween(fightSprite, {alpha: 0}, 0.5);
                        fightLine.visible = false;
                        active = false;
                    });
                });
            }
            if (fightLine.x > 640+(850*0.5))
            {
                canPress = false; //miss
                if (onEndFight != null)
                    onEndFight(0);
                FlxTween.tween(fightSprite.scale, {x: 0.5}, 0.5);
                FlxTween.tween(fightSprite, {alpha: 0}, 0.5);
                fightLine.visible = false;
                active = false;
            }
        }

    }

}