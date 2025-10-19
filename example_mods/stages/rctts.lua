function onCreatePost()
    setProperty('dad.visible', false)
    setProperty('boyfriend.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('healthBarBG.visible', false)

    addHaxeLibrary('FlxBar', 'flixel.ui')
    runHaxeCode([[
        game.healthBar.setGraphicSize(166, 35);
        game.healthBar.updateHitbox();
        game.healthBar.x = 640 - (game.healthBar.width*0.5);
        game.healthBar.y -= 20;
        game.healthBar.flipX = true;
        game.healthBar.createFilledBar(0xFFff1800, 0xFFd601d8);
        game.healthBar.updateBar();

        var krBar = new FlxBar(game.healthBar.x, game.healthBar.y, null, 166, 35);
        game.variables["krBar"] = krBar;
        krBar.cameras = [game.camHUD];
        krBar.createFilledBar(0x00000000, 0xFFfff000);
        krBar.updateBar();
        game.add(krBar);
    ]])

    setProperty('healthGain', 0.2)
    setProperty('healthLoss', 1.0)

    setProperty('health', 2)

    

    for i = 0,3 do 
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        if not middlescroll then 
            setPropertyFromGroup('playerStrums', i, 'x', getPropertyFromGroup('playerStrums', i, 'x')-320)
        end
    end

    local noteLength = getProperty('unspawnNotes.length')
    for i = 0,noteLength-1 do 
        setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', true)
    end
end

local kr = 0
function onDamage(damage)
    kr = kr + 2
end

local krTimer = 0
function onUpdate(elapsed)



    if kr > 0 then 
        krTimer = krTimer + elapsed 
        if krTimer > 0.3 then 
            krTimer = krTimer - 0.3
            if getProperty('health') > (1/92)*4 then 
                setProperty('health', getProperty('health')-((1/92)*2))
            end
            kr = kr - 1
        end
    end

    runHaxeCode([[
        game.variables["krBar"].percent = (game.health-(((1/92)*2)*]]..kr..[[))*50;
    ]])

end