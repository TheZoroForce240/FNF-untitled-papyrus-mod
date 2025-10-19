package undertale;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class BattleManager extends FlxGroup
{
    public var box:BattleBox;
    public var heart:PlayerHeart;
    private var attackScript:AttackScript;

    public var onDamage:Float->Void = null;
    public var onEndAttack:Void->Void = null;

    public function new()
    {
        super();
    }

    public function loadAttack(scriptName:String)
    {
		attackScript = new AttackScript(scriptName, this);
        add(attackScript);
		if (attackScript.interp == null)
			return;
		box = new BattleBox(200, 200, true);
		add(box);
		add(box.platforms);
		heart = new PlayerHeart(box);
		add(heart);
        add(box.playerAttacks);
		add(box.attacks);
		attackScript.call("initAttack", [box, heart]);
        heart.onDamage = onDamage;
    }

    public function startAttack()
    {
		if (attackScript == null || attackScript.interp == null)
			return;
		attackScript.call("startAttack", []);
    }

    public var defaultEase:Float->Float = FlxEase.cubeInOut;
    public function switchAttack(scriptName:String, time:Float = 0.5, ease:Float->Float = null)
    {
        if (ease == null)
            ease = defaultEase;
        //temp store positions
        var heartX = heart.x;
        var heartY = heart.y;
        var boxWidth = box.boxWidth;
        var boxHeight = box.boxHeight;

        clearAttack();
        loadAttack(scriptName);
        startAttack();

        heart.x = heartX;
        heart.y = heartY;
        var currentBoxWidth = box.boxWidth;
        var currentBoxHeight = box.boxHeight;
        box.boxWidth = boxWidth;
        box.boxHeight = boxHeight;
        FlxTween.tween(box, {boxWidth: currentBoxWidth}, time, {ease:ease}); //tween into the new size
        FlxTween.tween(box, {boxHeight: currentBoxHeight}, time, {ease:ease});
    }

    public function endAttack(time:Float = 0.5, ease:Float->Float = null) //tween out attack first
    {
        if (time <= 0)
        {
            clearAttack();
            if (onEndAttack != null)
                onEndAttack();
            return;
        }
        FlxTween.tween(box, {alpha: 0}, time, {ease:ease});
        FlxTween.tween(heart, {alpha: 0}, time, {ease:ease, onComplete:function(twn:FlxTween){
            clearAttack();
            if (onEndAttack != null)
                onEndAttack();
        }});
    }

    public function clearAttack() //instant clear
    {
		if (box != null)
        {
            remove(box);        
            remove(box.platforms);
            remove(box.playerAttacks);
            remove(box.attacks);
            //box.destroy(); //stop tweens from crashing i think
            //box = null;
        }
        if (heart != null)
        {
            remove(heart);
            //heart.destroy();
            //heart = null;
        } 
        if (attackScript != null)
        {
            remove(attackScript);
            attackScript.destroy();
            //attackScript = null;
        }
        
    }

    override public function destroy()
    {
        clearAttack();
        super.destroy();
    }
}