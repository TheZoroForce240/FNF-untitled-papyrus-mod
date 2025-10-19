package undertale;

import flixel.FlxG;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

typedef ItemData =
{
    var name:String; //short name used in battle menu
    var type:String;
    var ?atk:Int;
    var ?def:Int;
    var ?heal:Int;
    var desc:String;
    var ?useText:String;
}

class Item
{
    public var data:ItemData;
    public var name:String; //base name
    public static function createItem(name:String) //load an item from json file
    {
        var jsonStr:String = "";
        #if MODS_ALLOWED
		var moddyFile:String = Paths.modFolders("items/"+name+".json");
		if(FileSystem.exists(moddyFile)) {
			jsonStr = File.getContent(moddyFile);
		}
		#end
        if (jsonStr == "")
        {
            var path = Paths.file("items/"+name+".json");
			#if sys
            if(FileSystem.exists(path)) 
            {
                jsonStr = File.getContent(path);
            }
			#else
            if(Assets.exists(path)) 
            {
                jsonStr = Assets.getText(path);
            }
			#end
        }

        if (jsonStr == "")
        {
            var item:Item = new Item("Null Item", {name: "nullItem", type: "heal", heal: -1, desc: "how did you get this"});
            return item;
        }

        var item:Item = new Item(name, cast Json.parse(jsonStr));
        return item;
    }

    public function new(name:String, data:ItemData)
    {
        this.name = name;
        this.data = data;
    }

    public function getItemDialogueText()
    {
        var text:String = data.useText;

        if (name == "Nice Cream")
        {
            var randomTexts = ["You're super spiffy!", "Are those claws natural?", "Love yourself! I love you!", 
            "You look nice today!", "(An illustration of a hug)", "Have a wonderful day!", "Is this as sweet as you?", "You're just great!"];
            text = "* "+randomTexts[FlxG.random.int(0, randomTexts.length-1)];
        }

        return text;
    }
}