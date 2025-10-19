var h = null;
function initAttack(box, heart)
{
    heart.blue = true;
    h = heart;
    doTimer(new FlxTimer().start(1.25, function(tmr:FlxTimer)
    {
        doSlam(FlxG.random.int(0, 3), box, heart);
    }, 0)); //0 means loop forever
}
function doSlam(dir, box, heart)
{
    heart.blueGravityDir = dir;
    heart.gravityAdd = 6;
    doTimer(new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        playSound('snd_b');
    }));
    doTimer(new FlxTimer().start(0.2, function(tmr:FlxTimer)
    {
        //playSound('snd_impact');
    }));
    var sprName = 'spr_s_bonestab_v_wide';
    if (dir == 1 || dir == 3)
        sprName = 'spr_s_bonestab_h_tall';
    var bones = new AttackObject(box.x, box.y, false, false, 'ut/bones/'+sprName);
    if (dir == 1 || dir == 3)
        bones.setGraphicSize(50, box.height);
    else
        bones.setGraphicSize(box.width, 50);
    bones.updateHitbox();
    bones.centerOrigin();
    switch(dir)
    {
        case 0: 
            bones.y = box.y + box.height;
            //bones.y += bones.height;
        case 1: 
            bones.x -= bones.width;
            //bones.angle = 90;
        case 2: 
            bones.y -= bones.height;
        case 3: 
            bones.x = box.x + box.width;
            //bones.x += bones.height;
           // bones.angle = 90;
    }
    
    doTimer(new FlxTimer().start(0.5, function(tmr:FlxTimer)
    {
        switch(dir)
        {
            case 0: 
                bones.velocity.y = -500;
            case 1: 
                bones.velocity.x = 500;
            case 2: 
                bones.velocity.y = 500;
            case 3: 
                bones.velocity.x = -500;
        }
       
        box.attacks.add(bones);
        playSound('snd_spearrise');
    }));
    doTimer(new FlxTimer().start(0.6, function(tmr:FlxTimer)
    {
        bones.velocity.y = 0;
        bones.velocity.x = 0;
    }));
    doTimer(new FlxTimer().start(1, function(tmr:FlxTimer)
    {
        bones.velocity.y = 0;
        box.attacks.remove(bones);
    }));
}
function onUpdate(elapsed)
{
    if (h.gravityAdd > 0)
    {
        h.gravityAdd -= elapsed*25;
    }

}