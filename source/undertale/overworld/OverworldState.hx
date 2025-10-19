package undertale.overworld;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.math.FlxRect;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

using StringTools;
using flixel.addons.editors.ogmo.FlxOgmo3Loader;

class FlxOgmo3LoaderMods extends FlxOgmo3Loader //edit to allow loading with file.getContent
{
	override public function new(projectData:String, levelData:String)
    {
        #if sys
        if(FileSystem.exists(projectData) && FileSystem.exists(levelData)) 
        {
			project = File.getContent(projectData).parseProjectJSON();
            level = File.getContent(levelData).parseLevelJSON();
		}
        else #end
            super(projectData, levelData);

    }

    override public function loadTilemap(tileGraphic:FlxTilemapGraphicAsset, tileLayer:String = "tiles", ?tilemap:FlxTilemap):FlxTilemap
    {
        if (tilemap == null)
            tilemap = new FlxOgmo3Tilemap();

        var layer = level.getTileLayer(tileLayer);
        var tileset = project.getTilesetData(layer.tileset);
        switch (layer.arrayMode)
        {
            case 0:
                tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileGraphic, tileset.tileWidth, tileset.tileHeight, null, 0, 0, 0);
            case 1:
                tilemap.loadMapFrom2DArray(layer.data2D, tileGraphic, tileset.tileWidth, tileset.tileHeight, null, 0, 0, 0);
        }
        return tilemap;
    }

    public function getEntityProjectData(exportID:String) : ProjectEntityData
    {
        for (e in project.entities)
            if (e.exportID == exportID)
                return e;
        return null;
    }
}
//fix for the tile at 0,0 not being rendered
class FlxOgmo3Tilemap extends FlxTilemap
{
    override function loadMapHelper(tileGraphic:FlxTilemapGraphicAsset, tileWidth = 0, tileHeight = 0, ?autoTile:FlxTilemapAutoTiling,
        startingIndex = 0, drawIndex = 1, collideIndex = 1)
    {
        // anything < 0 should be treated as 0 for compatibility with certain map formats (ogmo)
        /*for (i in 0..._data.length) //die
        {
            if (_data[i] < 0)
                _data[i] = 0;
        }*/

        totalTiles = _data.length;
        auto = (autoTile == null) ? OFF : autoTile;
        _startingIndex = (startingIndex <= 0) ? 0 : startingIndex;

        if (auto != OFF)
        {
            _startingIndex = 1;
            drawIndex = 1;
            collideIndex = 1;
        }

        _drawIndex = drawIndex;
        _collideIndex = collideIndex;

        applyAutoTile();
        applyCustomRemap();
        randomizeIndices();
        cacheGraphics(tileWidth, tileHeight, tileGraphic);
        postGraphicLoad();
    }
}

class OverworldState extends MusicBeatState
{
    public var player:OverworldCharacter;

    var walls:FlxTilemap;
    var floor1:FlxTilemap;
    var floor2:FlxTilemap;
    var floor3:FlxTilemap;
    var foreground:FlxTilemap;
    var levelData:FlxOgmo3LoaderMods;

    public var camGame:FlxCamera;
    public var camHUD:FlxCamera;
    public var script:RoomScript;

    public var curRoom:String = "";
    public static var lastRoom:String = "";
    public static var lastX:Float = 0;
    public static var lastY:Float = 0;
    public static var lastFacing:Int = 2;

    var objects:FlxSpriteGroup;

    override public function new(roomName:String)
    {
        super();
        curRoom = roomName;

        var path:String = "";
        #if MODS_ALLOWED
		var moddyFile:String = Paths.modFolders("rooms/"+roomName+".json");
		if(FileSystem.exists(moddyFile)) {
			path = moddyFile;
		}
		#end

        if (path == "")
            Paths.file("rooms/"+roomName+".json");

        levelData = new FlxOgmo3LoaderMods(path.replace(".json", ".ogmo"), path);

        script = new RoomScript(roomName, this);
    }

    public var npcs:Map<String, OverworldCharacter> = [];
    
    override public function create()
    {
        script.call("init", [this]);
        //setup tilemaps
        var image = Paths.image("overworld/"+levelData.getLevelValue("tileset"));
        walls = levelData.loadTilemap(image, "walls");
        floor1 = levelData.loadTilemap(image, "floor1");
        floor2 = levelData.loadTilemap(image, "floor2");
        floor3 = levelData.loadTilemap(image, "floor3");
        foreground = levelData.loadTilemap(image, "foreground");

        camGame = new FlxCamera(160, 0, 960, 720);
		camHUD = new FlxCamera(160, 0, 960, 720);
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        //FlxG.worldBounds.set(0, 0, walls.width, walls.height);
        

        add(floor1);
        add(floor2);
        add(floor3);

        objects = new FlxSpriteGroup();
        add(objects);


        player = new OverworldCharacter(0, 0, "bf frisk", 2);
        player.player = true;
        
        var foundSpawn:Bool = false;

        levelData.loadEntities(function(entity:EntityData) //load in objects
        {
            switch(entity.name)
            {
                case "bf": 
                    if (!foundSpawn)
                        player.setPosition(entity.x, entity.y);
                case "save": 
                    var savePoint = new SavePoint(entity.x, entity.y, player);
                    savePoint.onInteract = function()
                    {
                        var title:String = entity.values.roomTitle;
                        PlayerStats.lastRoomTitle = title;
                        PlayerStats.lastRoom = curRoom;
                        openMenu(new SaveMenu(this));
                        //trace('save!');
                    }
                    objects.add(savePoint);
                case "box": 
                    var box = new InteractableSprite(entity.x, entity.y, player);
                    box.loadGraphic(Paths.image("overworld/utBox"));
                    box.onInteract = function()
                    {
                        openMenu(new BoxMenu(this));
                    }
                    objects.add(box);
                default: 
                    var data = levelData.getEntityProjectData(entity._eid);

                    if (data != null)
                    {
                        //trace(data.tags[0]);
                        var dynData:Dynamic = data; //not all things are in the struct by default
                        //trace(dynData);
                        switch(data.tags[0])
                        {
                            case "object": 
                                var obj = new FlxSprite(entity.x, entity.y);
                                var tex:String = cast dynData.texture;
                                obj.loadGraphic(Paths.image("overworld/"+tex.replace(".png", "")));
                                objects.add(obj);
                            case "npc": 
                                var obj = new OverworldCharacter(entity.x, entity.y, entity.values.name, entity.values.facing);
                                npcs.set(entity.values.name, obj);
                                objects.add(obj);
                            case "roomTrigger": 
                                var box = new InteractableSprite(entity.x, entity.y, player);
                                box.makeGraphic(entity.width,entity.height);
                                box.visible = false;
                                box.onOverlap = function()
                                {
                                    trace(entity.values.roomName);
                                    changeRoom(entity.values.roomName);
                                }
                                add(box);
                            case "interactTrigger": 
                                var box = new InteractableSprite(entity.x, entity.y, player);
                                box.makeGraphic(entity.width,entity.height);
                                box.visible = false;
                                box.onInteract = function()
                                {
                                    //trace('open box');
                                    /*if (entity.values.name == "papDoor")
                                    {
                                        openMenu(new DialogueHUDMenu(this, [
                                            {text: "* (It's locked from the inside.)", sound: "SND_TXT1"}
                                        ]));
                                    }*/
                                    script.call("interactTriggered", [entity.values.name]);
                                    //trace(entity.values.name);
                                }
                                add(box);
                            case "eventTrigger":
                                var box = new InteractableSprite(entity.x, entity.y, player);
                                box.makeGraphic(entity.width,entity.height);
                                box.visible = false;
                                box.onOverlap = function()
                                {
                                    script.call("eventTriggered", [entity.values.eventName]);
                                    trace(entity.values.eventName);
                                    /*if (entity.values.eventName == "papFightStart")
                                    {
                                        MusicBeatState.switchState(new FreeplayState());
                                    }*/
                                }
                                add(box);
                            case "roomSpawn": 
                                if (lastRoom == entity.values.roomName)
                                {
                                    player.setPosition(entity.x, entity.y);
                                    foundSpawn = true; //set location
                                }
                        }
                    }
            }
        }, "objects");


        objects.add(player);
        add(foreground);
        add(walls);
        walls.visible = false;

        FlxG.camera.follow(player, LOCKON, 1);
        FlxG.camera.zoom = 3;
        walls.follow();
        //FlxG.camera.deadzone = new FlxRect(0, 0, floor1.width, floor1.height);

        if (lastRoom == curRoom)
        {
            player.x = lastX;
            player.y = lastY;
        }

        lastRoom = curRoom;
        player.direction = lastFacing;

        
        script.call("onCreatePost", []);

        super.create();
    }

    public function changeRoom(newRoom:String)
    {
        lastX = player.x;
        lastY = player.y;
        lastFacing = player.direction;
        lastRoom = curRoom;
        CustomFadeTransition.doUTTrans = true;
        MusicBeatState.switchState(new OverworldState(newRoom));
    }
    public function startBattle(song:String)
    {
        FlxG.sound.music.volume = 0;
        FlxG.sound.music.pause();
        lastX = player.x;
        lastY = player.y;
        lastFacing = player.direction;
        CustomFadeTransition.doUTTrans = true;

        objects.remove(player, true);
        player.player = false;

        var blackBG = new FlxSprite().makeGraphic(1,1,0xFF000000);
        blackBG.setGraphicSize(1280, 720);
        blackBG.updateHitbox();
        blackBG.screenCenter();
        add(blackBG);

        add(player); //have player on top
        var heart = new PlayerHeart(null);
        //heart.scale.set(0.5,0.5);
        heart.updateHitbox();
        heart.cameras = [camHUD];
        heart.x = player.x + player.width*0.5 - heart.width*0.5;
        heart.y = player.y + player.height*0.5 - heart.height*0.5;
        heart.x -= camGame.scroll.x;
        heart.y -= camGame.scroll.y;
        add(heart);

        var targetX = 68;
        var targetY = 655;
        var loop = 0;

        new FlxTimer().start(1/15, function(tmr)
        {
            if (loop % 2 == 0)
            {
                heart.visible = true;
                FlxG.sound.play(Paths.sound("snd_test"));
                if (loop == 4)
                {
                    FlxG.sound.play(Paths.sound("snd_battlefall"));
                    player.visible = false;
                    FlxTween.tween(heart, {x: targetX, y: targetY}, 0.5, {onComplete: function(twn)
                    {
                        var songLowercase:String = Paths.formatToSongPath(song);
                        PlayState.SONG = Song.loadFromJson(songLowercase, songLowercase);
                        PlayState.isStoryMode = false;
                        CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
                        PlayState.storyDifficulty = 1;
                        LoadingState.loadAndSwitchState(new PlayState());
                    }});
                }
            }
            else 
                heart.visible = false;
            loop++;
        }, 5);

    }


    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        objects.sort(FlxSort.byY); //keep objects layered
        
        if (player != null)
        {            
            FlxG.collide(player, walls);
        
            if (player.x < 0)
                player.x = 0;
            else if (player.x > walls.width)
                player.x = walls.width;
        }

        script.call("onUpdate", [elapsed]);

        if (!inMenu && PlayerControls.MENU_P)
        {
            openMenu(new PlayerHUDMenu(this));
        }

        if (FlxG.keys.justPressed.F5)
        {
            changeRoom(curRoom); //reload room
        }
    }


    var inMenu:Bool = false;
    var currentMenu:OverworldHUDMenu;
    public function openMenu(menu:OverworldHUDMenu)
    {
        if (!inMenu)
        {
            currentMenu = menu;
            currentMenu.cameras = [camHUD];
            add(currentMenu);
            inMenu = true;
            player.player = false;
        }
    }
    public function closeMenu()
    {
        inMenu = false;
        player.player = true;
        remove(currentMenu);
    }
}