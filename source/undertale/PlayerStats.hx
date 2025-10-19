package undertale;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;

class PlayerStats
{
    public static var name:String = "Boyfrd";
    public static var hp:Int = 20;
    public static var hpMax:Int = 20;
    public static var lv:Int = 1;
    public static var exp:Int = 0;
    public static var gold:Int = 0;
    public static var timePlayed:Int = 0;
    public static var lastRoom:String = "papFightRoom";
    public static var lastRoomTitle:String = "Snowdin - Shed";
    public static var hasPhone:Bool = false;

    
    static var weapon:Item;
    static var armor:Item;
    static var items:Array<Item>;
    static var boxItems:Array<Item>;

    static var fun:Int;

    public static var saveFile:FlxSave;

    public static var extraData:Map<String, Dynamic> = [];

    static var timePlayedTimer:FlxTimer;

    public static function load()
    {
        if (saveFile == null)
        {
            saveFile = new FlxSave();
            saveFile.bind("saveFile", "Papyrus-FNF-Mod");

            FlxG.signals.postStateSwitch.add(function() //refresh timer
            {
                if (timePlayedTimer != null)
                    timePlayedTimer.cancel();
                timePlayedTimer = new FlxTimer().start(1, function(tmr)
                {
                    timePlayed++;
                }, 0);
            });
        }

        if (saveFile.data.init == null)
        {
            reset(); //no save so reset
            return;
        }
            

        if (saveFile.data.hp != null)
            hp = saveFile.data.hp;
        if (saveFile.data.lv != null)
            lv = saveFile.data.lv;
        if (saveFile.data.exp != null)
            exp = saveFile.data.exp;
        if (saveFile.data.gold != null)
            gold = saveFile.data.gold;
        if (saveFile.data.timePlayed != null)
            timePlayed = saveFile.data.timePlayed;
        if (saveFile.data.fun != null)
            fun = saveFile.data.fun;
        if (saveFile.data.lastRoom != null)
            lastRoom = saveFile.data.lastRoom;
        if (saveFile.data.lastRoomTitle != null)
            lastRoomTitle = saveFile.data.lastRoomTitle;
        if (saveFile.data.weapon != null)
            weapon = Item.createItem(saveFile.data.weapon);
        if (saveFile.data.armor != null)
            armor = Item.createItem(saveFile.data.armor);
        if (saveFile.data.extraData != null)
        {
            var shit:Map<String,Dynamic> = saveFile.data.extraData;
            for (key => value in shit)
            {
                extraData.set(key, value);
            }
        }

        if (saveFile.data.items != null)
        {
            var itemList:Array<String> = saveFile.data.items;
            items = [];
            for (i in itemList)
            {
                items.push(Item.createItem(i)); //string to item
            }
        }
        else 
            items = [];

        if (saveFile.data.boxItems != null)
        {
            var itemList:Array<String> = saveFile.data.boxItems;
            boxItems = [];
            for (i in itemList)
            {
                boxItems.push(Item.createItem(i)); //string to item
            }
        }
        else 
            boxItems = [];

        trace("load.");
    }
    public static function save()
    {
        saveFile.data.init = true;
        saveFile.data.hp = hp;
        saveFile.data.lv = lv;
        saveFile.data.exp = exp;
        saveFile.data.gold = gold;
        saveFile.data.timePlayed = timePlayed;
        saveFile.data.fun = fun;
        saveFile.data.lastRoom = lastRoom;
        saveFile.data.lastRoomTitle = lastRoomTitle;
        saveFile.data.weapon = weapon.name;
        saveFile.data.armor = armor.name;
        saveFile.data.extraData = extraData;

        saveFile.data.items = getItemList();
        saveFile.data.boxItems = getBoxList();

        saveFile.flush();
        trace("save.");
    }

    public static function reset()
    {
        
        hp = 20;
        hpMax = 20;
        lv = 1;
        gold = 0;
        exp = 0;
        timePlayed = 0;
        fun = FlxG.random.int(0, 100);
        lastRoom = "firstRoom";
        lastRoomTitle = "";
        items = [];
        boxItems = [];
        extraData.clear();
        setDefaultInventory();
        //save();
        trace("reset.");
    }

    public static function setDefaultInventory()
    {
        PlayerStats.setWeapon(Item.createItem("Microphone"));
        PlayerStats.setArmor(Item.createItem("Red Cap"));
        //PlayerStats.addItemToInventory(Item.createItem("Butterscotch Pie"));
        //PlayerStats.addItemToInventory(Item.createItem("Nice Cream"));
        //PlayerStats.addItemToInventory(Item.createItem("Snowman Piece"));
        //PlayerStats.addItemToInventory(Item.createItem("Cinnamon Bunny"));
        //PlayerStats.addItemToInventory(Item.createItem("Cinnamon Bunny"));
        //PlayerStats.addItemToInventory(Item.createItem("Cinnamon Bunny"));
        //PlayerStats.addItemToInventory(Item.createItem("Cinnamon Bunny"));
    }
    public static function getFormattedTimePlayed(?time:Int)
    {
        if (time == null)
            time = timePlayed;
        var date = Date.fromTime(time*1000);

        var secs = Std.string(date.getSeconds());
        if (secs.length <= 1)
            secs = "0"+secs;
        
        return date.getMinutes()+":"+secs;
    }
    public static function removeItemFromInventory(idx:Int)
    {
        if (items[idx] != null)
            items.remove(items[idx]);
    }
    public static function removeItemFromBox(idx:Int)
    {
        if (boxItems[idx] != null)
            boxItems.remove(boxItems[idx]);
    }
    public static function setWeapon(i:Item)
    {
        weapon = i;
        trace(weapon.data);
    }
    public static function setArmor(i:Item)
    {
        armor = i;
        trace(armor.data);
    }
    public static function addItemToInventory(i:Item)
    {
        if (items == null)
            items = [];

        if (items.length < 8)
        {
            items.push(i);
            return true;
        }
            
        return false; //item was not added successfully
    }
    public static function addItemToBox(i:Item)
    {
        if (boxItems == null)
            boxItems = [];

        if (boxItems.length < 10)
        {
            boxItems.push(i);
            return true;
        }
            
        return false; //item was not added successfully
    }
    public static function getItemList()
    {
        var itemList:Array<String> = [];
        for (i in items)
            itemList.push(i.name);
        return itemList;
    }
    public static function getBoxList()
    {
        var itemList:Array<String> = [];
        for (i in boxItems)
            itemList.push(i.name);
        return itemList;
    }
    public static function getItems()
    {
        return items;
    }
    public static function getBoxItems()
    {
        return boxItems;
    }
    

    //https://undertale.fandom.com/wiki/Stats
    //some stuff from the wiki lol
    static final expLevels:Array<Array<Int>> = [
        //hp, atk, def, exp to next, exp total
        [20, 0, 0, 10, 0],
        [20, 0, 0, 10, 0], //1
        [24, 2, 0, 20, 10], //2
        [28, 4, 0, 40, 30], //3
        [32, 6, 0, 50, 70], //4
        [36, 8, 1, 80, 120], //5, etc
        [40,10,	1, 100, 200],
        [44,12,	1, 200,	300],
        [48,14,	1, 300,	500],
        [52,16,	2, 400,	800],
        [56,18,	2, 500,	1200],
        [60,20,	2, 800,	1700],
        [64,22,	2, 1000, 2500],
        [68,24,	3, 1500, 3500],
        [72,26,	3, 2000, 5000],
        [76,28,	3, 3000, 7000],
        [80,30,	3, 5000, 10000],
        [84,32,	4, 10000, 15000],
        [88,34,	4, 25000, 25000],
        [92,36,	4, 49999, 50000],
        [99,38,	4, -1, 99999]
    ];

    public static function addEXP(e:Int) : Bool
    {
        exp += e;

        if (expLevels[lv] != null && expLevels[lv][3] != -1)
        {
            if (exp >= expLevels[lv][3])
            {
                lv++; //increase lv
                addEXP(e); //attempt to level up again in case its gone up multiple levels
                hpMax = expLevels[lv][0];
                return true;
            }
        }

        return false;
    }
    public static function getEXPTillNext()
    {
        if (expLevels[lv] != null && expLevels[lv][3] != -1)
        {
            return Std.string(expLevels[lv][3]-exp);
        }
        return "N/A";
    }


    public static function applyDefToDamage(dmg:Int, def:Int)
    {
        var d = def;
        if (d <= 0)
            d = 0;
        var reducedDmg = Math.round(dmg - (d/5));
        return reducedDmg;
    }

    public static var atk(get, null):Int;
    public static function get_atk()
    {
        var atk:Int = 10; //apprently atk and def are 10 by default but show as 0????
        if (expLevels[lv] != null) //add level atk
            atk += expLevels[lv][1];
        if (weapon != null) //add weapon atk
            atk += weapon.data.atk;
        return atk;
    }
    public static var def(get, null):Int;
    public static function get_def()
    {
        var def:Int = 10;
        if (expLevels[lv] != null)
            def += expLevels[lv][2];
        if (armor != null)
            def += armor.data.def;
        return def;
    }

    public static function getLevelATK()
    {
        var atk:Int = 0;
        if (expLevels[lv] != null) //add level atk
            atk += expLevels[lv][1];
        return atk;
    }
    public static function getWeaponATK()
    {
        var atk:Int = 0;
        if (weapon != null) //add weapon atk
            atk += weapon.data.atk;
        return atk;
    }

    public static function getLevelDEF()
    {
        var def:Int = 0;
        if (expLevels[lv] != null) 
            def += expLevels[lv][2];
        return def;
    }
    public static function getArmorDEF()
    {
        var def:Int = 0;
        if (armor != null)
            def += armor.data.def;
        return def;
    }

    public static function getWeaponName()
    {
        if (weapon != null)
            return weapon.name;
        return "None";
    }
    public static function getArmorName()
    {
        if (armor != null)
            return armor.name;
        return "None";
    }
}