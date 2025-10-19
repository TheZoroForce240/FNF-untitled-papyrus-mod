package undertale;

import flixel.util.FlxPool;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import undertale.DialogueManager.BubbleDialogueDisplay;

class BattleNPC extends FlxSpriteGroup
{
    public var atk:Int = 1;
    public var def:Int = 1;
    public var hp:Int = 100;
    private var hpVisual:Int = 100;
    public var maxHP:Int = 100;
    public var sprite:FlxSprite;
    public var dialogue:BubbleDialogueDisplay;
    public var healthBar:FlxBar;
    public var spareable:Bool = false;
    public var died:Bool = false;
    override public function new(name:String)
    {
        super();
        sprite = new FlxSprite();
        sprite.frames = Paths.getSparrowAtlas(name);
        sprite.animation.addByPrefix("idle", "idle", 24, true);
        sprite.animation.addByPrefix("hurt", "hurt", 24, true);
        sprite.animation.play("idle", true);
        sprite.animation.pause();
        sprite.scale.set(3, 3);
        sprite.updateHitbox();
        add(sprite);
        sprite.screenCenter(X);
        sprite.y -= sprite.height;

        dialogue = new BubbleDialogueDisplay();
        dialogue.character = this;
        dialogue.x = sprite.x + sprite.width+5;
        dialogue.y = sprite.y + (sprite.height*0.5)-(dialogue.height*0.5);
        //add(dialogue);
        dialogue.visible = false;

        healthBar = new FlxBar(sprite.x, sprite.y+(sprite.height*0.5), LEFT_TO_RIGHT, Std.int(sprite.width), 20, this, "hpVisual", 0, maxHP, true);
        healthBar.createFilledBar(0xFF3d3f3e, 0xFF00FF00);
        add(healthBar);
        healthBar.visible = false;

        cacheDust();
    }

    var doShake:Bool = false;
    var shakePos:Float = 0;
    var shakeFlip:Bool = false;
    var shakeStrength:Float = 15;
    var shakeTime:Float = 0;
    var shake:Float = 0;

    override public function update(elapsed:Float)
    {
        if (doShake)
        {
            shake -= elapsed;
            shakeTime += elapsed;
            if (shakeTime >= 1/15)
            {
                shakeTime -= 1/15;
                if (shakeFlip)
                    sprite.x = shakePos + (shake*2*shakeStrength);
                else 
                    sprite.x = shakePos - (shake*2*shakeStrength);
                shakeFlip = !shakeFlip;
            }


            if (shake <= 0)
            {
                doShake = false;
                sprite.x = shakePos;
            }
        }

        super.update(elapsed);
    }

    public function updateDialoguePosition()
    {
        dialogue.x = sprite.x + sprite.width+5;
        dialogue.y = sprite.y + (sprite.height*0.5)-(dialogue.height*0.5);
    }

    public function takeDamage(dmg:Int)
    {
        if (died)
            return;
        healthBar.visible = true;
        FlxG.sound.play(Paths.sound("snd_damage"));

        healthBar.setRange(0, maxHP);
        hpVisual = hp;

        dmg = Std.int(PlayerStats.applyDefToDamage(dmg, def));
        hp -= dmg;
        FlxTween.tween(this, {hpVisual: hp}, 1);

        sprite.animation.play("hurt");
        shake = 1;
        shakePos = sprite.x;
        doShake = true;

        var numbers:Array<FlxSprite> = [];
        if (dmg <= 0)
        {   
            var miss = new FlxSprite().loadGraphic(Paths.image("ut/damage/miss"));
            miss.scale.set(1.5,1.5);
            miss.updateHitbox();
            add(miss);
            numbers.push(miss);
        }
        else 
        {
            var splitDMG = Std.string(dmg).split("");
            for (n in splitDMG)
            {
                var number = new FlxSprite().loadGraphic(Paths.image("ut/damage/"+n));
                number.color = 0xFFFF0000;
                number.scale.set(1.5,1.5);
                number.updateHitbox();
                add(number);
                numbers.push(number);
            }
        }

        centerNumbers(numbers);

        new FlxTimer().start(1.0, function(tmr)
        {
            sprite.animation.play("idle");
        });

        new FlxTimer().start(1.5, function(tmr)
        {
            healthBar.visible = false;
            for (i in numbers)
                remove(i);

            if (hp <= 0 && !died)
            {
                died = true;
                dust();
            }
                
        });
    }

    private function centerNumbers(numbers:Array<FlxSprite>)
    {
        for (i in 0...numbers.length)
        {
            numbers[i].y = healthBar.y-numbers[i].height;
            numbers[i].x = healthBar.x + (healthBar.width*0.5) - (numbers[i].width*numbers.length*0.5);
            numbers[i].x += numbers[i].width*i;

            var num = numbers[i];
            FlxTween.tween(num, {y: num.y-20}, 0.1, {ease: FlxEase.cubeOut, onComplete: function(twn)
            {
                FlxTween.tween(num, {y: num.y+20}, 0.4, {ease: FlxEase.cubeIn});
            }});
            //numbers[i].x -= numbers[i].width*numbers.length;
            //numbers[i].x -= numbers[i].width*0.5;
        }
    }

    var pool:Array<FlxSprite> = [];

    public function cacheDust()
    {
        //il figure this out later lol
        /*var framePixels = sprite.updateFramePixels().clone();

        for (row in 0...framePixels.height)
        {
            for (col in 0...framePixels.width)
            {
                var pixel = framePixels.getPixel32(col, row);
                if (pixel != 0x00000000)
                {
                    var spr = new FlxSprite().makeGraphic(1,1,pixel);
                    spr.scale.x = sprite.scale.x;
                    spr.scale.y = sprite.scale.y;
                    spr.x = sprite.x+(col*sprite.scale.x);
                    spr.y = sprite.y+(row*sprite.scale.y);
                    spr.ID = row;
                    pool.push(spr);
                }

            }
        }
        //framePixels.dispose();*/
    }

    public function dust()
    {
        var framePixels = sprite.updateFramePixels().clone();
        
        for (row in 0...framePixels.height)
        {
            for (col in 0...framePixels.width)
            {
                var pixel = framePixels.getPixel32(col, row); //read every pixel lol
                
                //trace(pixel);
                if (pixel != 0x00000000) //check if not transparent
                {
                    var dustPart = new FlxSprite(0,0).makeGraphic(1,1,pixel);

                    dustPart.scale.x = sprite.scale.x;
                    dustPart.scale.y = sprite.scale.y;
                    add(dustPart);

                    dustPart.x = sprite.x+(col*sprite.scale.x);
                    dustPart.y = sprite.y+(row*sprite.scale.y);

                    FlxTween.tween(dustPart, {x: dustPart.x + FlxG.random.float(-5, 5), y: dustPart.y - 100 + FlxG.random.float(-10, 10), alpha: 0}, 1, 
                    {startDelay: row*0.01, onComplete: function(t)
                    {
                        remove(dustPart);
                        dustPart.destroy();
                    }});
                }
            }
        }
        framePixels.dispose();
        FlxG.sound.play(Paths.sound("snd_vaporized"));
        sprite.visible = false;
    }
}