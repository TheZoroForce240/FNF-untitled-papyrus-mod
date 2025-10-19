function onCreate()
    setProperty('skipArrowStartTween', true)
    setProperty('skipCountdown', true)
    if songPath == 'bonetrousle' then 
        setProperty('battleScriptName', 'papyrus')
        setProperty('battleCharacterName', "papyrus")
    elseif songPath == 'megalovania' then 
        setProperty('battleScriptName', 'sans')
        setProperty('battleCharacterName', "sans")
    elseif songPath == 'your-best-friend' then 
        setProperty('battleScriptName', 'floweyBattle')
        setProperty('battleCharacterName', "floweyBattle")
    end
    
end

local arrWid = 160*0.7*0.8
local arrOffset = {-1.5, -0.5, 0.5, 1.5}

function onCreatePost()
    setProperty('dad.visible', false)
    setProperty('boyfriend.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('healthBarBG.visible', false)
    setProperty('healthBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)

    setTextFont('scoreTxt', "undertale-mars-needs-cunnilingus.ttf")

    setProperty('scoreTxt.y', 5)

    for i = 0,3 do 
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        if not middlescroll then 
            setPropertyFromGroup('playerStrums', i, 'alpha', 0)
            setPropertyFromGroup('playerStrums', i, 'y', getPropertyFromGroup('playerStrums', i, 'y')-70)
            setPropertyFromGroup('playerStrums', i, 'x', (640-(arrWid*0.5)) + (arrOffset[i+1]*arrWid))
        end
    end
    setObjectOrder('strumLineNotes', getObjectOrder('battleMenu')+1)
    setObjectOrder('notes', getObjectOrder('strumLineNotes')+1)
    setProperty('grpNoteSplashes.visible', false)

    setProperty('scoreTxt.y', getProperty('battleMenu.playerText.y'))
    setTextAlignment('scoreTxt', 'left')
    setProperty('scoreTxt.x', getProperty('battleMenu.healthText.x') + getProperty('battleMenu.healthText.width')+10)
end

function onStartAttack(attack)
    if attack == '' then 
        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'alpha', 1)
        end
    end
end
function onEndAttack()
    for i = 0,3 do
        setPropertyFromGroup('playerStrums', i, 'alpha', 0)
    end
end

local heartAng = {90, 0, 180, -90}
local splashCount = 0

function goodNoteHit(id, noteData, noteType, sustainNote)

    --custom note splash lol
    if not sustainNote and getPropertyFromGroup('notes', id, 'rating') == 'sick' and getPropertyFromClass('ClientPrefs', 'noteSplashes') then
        local sploosh = "heartSplash"..splashCount
        makeLuaSprite(sploosh, 'ut/heart', 0, 0)
        setObjectCamera(sploosh, 'hud')
        scaleObject(sploosh, 1.5, 1.5)
        setProperty(sploosh..'.angle', heartAng[noteData+1])
        setProperty(sploosh..'.antialiasing', false)
        addLuaSprite(sploosh, true)
        
        local beats = 1
        setProperty(sploosh..'.alpha', 0.6)
        doTweenAlpha(sploosh..'a', sploosh, 0, crochet*0.001*beats, 'cubeIn')
        runHaxeCode([[
            var strum = game.strumLineNotes.members[]]..(noteData+4)..[[];
            var heart = game.modchartSprites.get("]]..sploosh..[[");
            heart.color = 0xFFFF0000;
            var tween = FlxTween.tween(heart.scale, {x: 6, y: 6}, ]]..(crochet*0.001*beats)..[[, {ease: FlxEase.cubeOut, onUpdate: function(twn)
            {
                heart.updateHitbox();
                heart.x = strum.x + (strum.width*0.5) - (heart.width*0.5);
                heart.y = strum.y + (strum.height*0.5) - (heart.height*0.5);
            }});
            game.modchartTweens.set("]]..sploosh..[[", tween); //add to modchart tweens so it gets paused properly
        ]])
        splashCount = splashCount + 1
        if splashCount > 50 then 
            splashCount = 0
        end
    end
end