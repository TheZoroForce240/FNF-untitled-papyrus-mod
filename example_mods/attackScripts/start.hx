var b = null;
var h = null;
function initAttack(box, heart)
{
    box.boxWidth = 300;
    box.boxHeight = 600;
    
    b = box;
    h = heart;
    startTimer(Conductor.stepCrochet*0.001, function(tmr:FlxTimer)
    {
        startTween(box, {boxHeight: 200}, Conductor.stepCrochet*0.001*15, {ease:FlxEase.cubeInOut});
        heart.blue = true;
        heart.blueGravityDir = 0;
        heart.gravityAdd = 6;
    });
    startTimer(Conductor.stepCrochet*0.001*2, function(tmr:FlxTimer)
    {
        //heart.blue = false;
        for (i in 0...12)
        {
            var wave = Math.sin(i*0.25)*90;
            var vel = 900;
            var y = -100 - (50*i);
            makeBone(box.x, y, "ut/bones/spr_s_bonestab_h", 0, vel, 100 + wave, 20, false, false);

            var rBone = makeBone(box.x+box.width, y, "ut/bones/spr_s_bonestab_h", 0, vel, 100 - wave, 20, false, false);
            rBone.x -= rBone.width;
        }

        createBlaster(box.x+box.width+200, 430, 90, 1, Conductor.stepCrochet*0.001*16);
        createBlaster(box.x-200, 430, -90, 1, Conductor.stepCrochet*0.001*16);
    });
   
}

function makeBone(x, y, sprName, velX, velY, width, height, blue, orange)
{
    var bone = new AttackObject(x, y, blue, orange, sprName);
    bone.setGraphicSize(width, height);
    bone.updateHitbox();
    bone.velocity.x = velX;
    bone.velocity.y = velY;
    b.attacks.add(bone);    
}

function createBlaster(x, y, ang, spawnTime, shootTime)
{
    var box = b;
    var heart = h;

    var scaleX = 3;
    var scaleY = 3;

    var xPos = x;
    var yPos = y;
    var blaster = new AttackObject(xPos*3, yPos*3); //create blaster

    blaster.doesDamage = false; //dont do damage
    blaster.frames = Paths.getSparrowAtlas("attacks/blaster");
    blaster.animation.addByPrefix('idle', 'blaster idle');
    blaster.animation.play('idle', true);
    blaster.animation.addByPrefix('shoot', 'blaster shoot', 12, false);
    blaster.scale.set(scaleX, scaleY);
    blaster.updateHitbox();
    blaster.antialiasing = false;

    //blaster.hitbox.visible = true;
    blaster.hitbox.makeGraphic(Std.int(blaster.width*0.5),Std.int(blaster.width*10)); //stretch out the blaster hitbox
    blaster.hitbox.updateHitbox();
    blaster.hitboxFollowSprite = false;

    var angleFromPlayer = ang;

    var targetX = xPos - Math.sin(angleFromPlayer*(Math.PI/180))*500;
    var targetY = yPos + Math.cos(angleFromPlayer*(Math.PI/180))*500;

    xPos -= blaster.width*0.5;
    yPos -= blaster.height*0.5;

    blaster.hitbox.x = targetX-(blaster.hitbox.width*0.5); //pretty stupid but the hitbox is way more consistant
    blaster.hitbox.y = targetY-(blaster.hitbox.height*0.5);
    blaster.hitbox.angle = angleFromPlayer;

    FlxTween.tween(blaster, {x: xPos, y: yPos, angle: angleFromPlayer}, spawnTime, {ease:FlxEase.cubeInOut});

    box.attacks.add(blaster);
    playSound('mus_sfx_segapower', 0.7); //play the sound

    var beam = new AttackObject(xPos-230, yPos+60, false, false, 'attacks/beam');
    beam.doesDamage = false;
    beam.updateHitbox();
    beam.origin.x = 1;
    beam.flipX = true;
    beam.x -= Math.sin(angleFromPlayer*(Math.PI/180))*(blaster.width*0.5);
    beam.y += Math.cos(angleFromPlayer*(Math.PI/180))*(blaster.height*0.5);
    beam.angle = angleFromPlayer+90;

    doTimer(new FlxTimer().start(shootTime-0.65, function(tmr:FlxTimer)
    {
        blaster.animation.play('shoot', false);
        
    }));
    doTimer(new FlxTimer().start(shootTime-0.5, function(tmr:FlxTimer)
    {
        playSound('mus_sfx_rainbowbeam_1', 0.7);
        beam.scale.y = 0.3;
        //beam.hitbox.scale.y = scaleX*0.6;
        blaster.doesDamage = true;
        FlxTween.tween(beam.scale, {y: scaleX*1.3, x: scaleY*2.6}, 0.25, {ease:FlxEase.cubeInOut});
        //FlxTween.tween(beam.hitbox.scale, {y: 3, x: 5}, 0.25, {ease:FlxEase.cubeInOut});
        //box.attacks.remove(blaster);
        box.attacks.add(beam);
        
        //box.attacks.add(blaster);
        FlxG.camera.shake(0.005, 0.15);

    }));
    doTimer(new FlxTimer().start(shootTime-0.4, function(tmr:FlxTimer)
    {
        //beam.angle += 45;
        blaster.acceleration.x = Math.sin(angleFromPlayer*(Math.PI/180))*7000;
        blaster.acceleration.y = -Math.cos(angleFromPlayer*(Math.PI/180))*7000;
        beam.acceleration.x = Math.sin(angleFromPlayer*(Math.PI/180))*7000;
        beam.acceleration.y = -Math.cos(angleFromPlayer*(Math.PI/180))*7000;
    }));
    doTimer(new FlxTimer().start(shootTime-0.1, function(tmr:FlxTimer)
    {
        FlxTween.tween(beam, {alpha: 0}, 0.5, {ease:FlxEase.cubeInOut});
        FlxTween.tween(beam.scale, {y: 0.3}, 0.5, {ease:FlxEase.cubeInOut});
        //blaster.doesDamage = false;
    }));
    doTimer(new FlxTimer().start(shootTime, function(tmr:FlxTimer)
    {
        blaster.doesDamage = false;
    }));
    doTimer(new FlxTimer().start(shootTime+0.5, function(tmr:FlxTimer)
    {
        box.attacks.remove(blaster);
        box.attacks.remove(beam);
    }));
}

function createBlasterAroundBox(targetX, targetY, ang, type)
{
    var box = b;
    var heart = h;

    var scaleX = 3;
    var scaleY = 3;

    var xPos = (box.x+(box.width*0.5)) + (box.width * Math.sin(ang*(Math.PI/180)));
    var yPos = (box.y+(box.height*0.5)) + (box.height * Math.cos(ang*(Math.PI/180)));
    var blaster = new AttackObject(xPos*3, yPos*3); //create blaster

    blaster.doesDamage = false; //dont do damage
    blaster.frames = Paths.getSparrowAtlas("attacks/blaster");
    blaster.animation.addByPrefix('idle', 'blaster idle');
    blaster.animation.play('idle', true);
    blaster.animation.addByPrefix('shoot', 'blaster shoot', 12, false);
    blaster.scale.set(scaleX, scaleY);
    blaster.updateHitbox();
    blaster.antialiasing = false;

    blaster.hitbox.makeGraphic(Std.int(blaster.width*0.5),Std.int(blaster.width*10)); //stretch out the blaster hitbox
    blaster.hitbox.updateHitbox();
    blaster.hitboxFollowSprite = false;

    var angleShit = Math.atan2(yPos-targetY, xPos-targetX)/(Math.PI/180);
    //angleFromPlayer += 90;
    xPos -= blaster.width*0.5;
    yPos -= blaster.height*0.5;
    var angleFromPlayer = angleShit+90;

    blaster.hitbox.x = targetX-(blaster.hitbox.width*0.5); //pretty stupid but the hitbox is way more consistant
    blaster.hitbox.y = targetY-(blaster.hitbox.height*0.5);
    blaster.hitbox.angle = angleFromPlayer;

    FlxTween.tween(blaster, {x: xPos, y: yPos, angle: angleFromPlayer}, 0.5, {ease:FlxEase.cubeInOut});

    box.attacks.add(blaster);
    playSound('mus_sfx_segapower', 0.7); //play the sound

    var beam = new AttackObject(xPos-230, yPos+60, false, false, 'attacks/beam');
    beam.doesDamage = false;
    beam.updateHitbox();
    beam.origin.x = 1;
    beam.flipX = true;
    beam.x -= Math.sin(angleFromPlayer*(Math.PI/180))*(blaster.width*0.5);
    beam.y += Math.cos(angleFromPlayer*(Math.PI/180))*(blaster.height*0.5);
    beam.angle = angleFromPlayer+90;

    doTimer(new FlxTimer().start(0.85, function(tmr:FlxTimer)
    {
        blaster.animation.play('shoot', false);
        
    }));
    doTimer(new FlxTimer().start(1, function(tmr:FlxTimer)
    {
        playSound('mus_sfx_rainbowbeam_1', 0.7);
        beam.scale.y = 0.3;
        //beam.hitbox.scale.y = scaleX*0.6;
        blaster.doesDamage = true;
        FlxTween.tween(beam.scale, {y: scaleX*1.3, x: scaleY*2.6}, 0.25, {ease:FlxEase.cubeInOut});
        //FlxTween.tween(beam.hitbox.scale, {y: 3, x: 5}, 0.25, {ease:FlxEase.cubeInOut});
        //box.attacks.remove(blaster);
        box.attacks.add(beam);
        
        //box.attacks.add(blaster);
        FlxG.camera.shake(0.005, 0.15);

    }));
    doTimer(new FlxTimer().start(1.1, function(tmr:FlxTimer)
    {
        //beam.angle += 45;
        blaster.acceleration.x = Math.sin(angleFromPlayer*(Math.PI/180))*7000;
        blaster.acceleration.y = -Math.cos(angleFromPlayer*(Math.PI/180))*7000;
        beam.acceleration.x = Math.sin(angleFromPlayer*(Math.PI/180))*7000;
        beam.acceleration.y = -Math.cos(angleFromPlayer*(Math.PI/180))*7000;
    }));
    doTimer(new FlxTimer().start(1.4, function(tmr:FlxTimer)
    {
        FlxTween.tween(beam, {alpha: 0}, 0.5, {ease:FlxEase.cubeInOut});
        FlxTween.tween(beam.scale, {y: 0.3}, 0.5, {ease:FlxEase.cubeInOut});
        //blaster.doesDamage = false;
    }));
    doTimer(new FlxTimer().start(1.5, function(tmr:FlxTimer)
    {
        blaster.doesDamage = false;
    }));
    doTimer(new FlxTimer().start(2, function(tmr:FlxTimer)
    {
        box.attacks.remove(blaster);
        box.attacks.remove(beam);
    }));
}

function onUpdate(elapsed)
    {
        if (h.gravityAdd > 0)
        {
            h.gravityAdd -= elapsed*25;
        }
    
    }