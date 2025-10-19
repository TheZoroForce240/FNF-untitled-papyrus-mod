
var menu = null;
var doneBlueAttack = false;
var justAskedToSing = false;
var justChecked = false;
var askedToSing = false;
var justFinishedBlueAttack = false;

var randomFlavourTexts = [
    "* Papyrus is preparing a bone attack.",
    "* Papyrus prepares a non-bone attack\n then spends a minute fixing his\n mistake.",
    "* Papyrus is cackling.",
    '* Papyrus whispers "Nyeh heh heh!" ',
    "* Papyrus is rattling his bones.",
    "* Papyrus is trying hard to play it cool.",
    "* Papyrus is considering his options.",
    "* Smells like bones.",
    "* Papyrus remembered a bad joke Sans told and is frowning."
];

var papDialogues = [
    [{text: "BEHOLD!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "YEAH! DON'T MAKE \nME USE MY SPECIAL \nATTACK!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "I CAN ALMOST \nTASTE MY FUTURE \nPOPULARITY!!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "PAPYRUS: HEAD OF \nTHE ROYAL GUARD!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "PAPYRUS: \nUNPARALLELED \nSPAGHETTORE!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "UNDYNE WILL BE \nREALLY PROUD OF \nME!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "THE KING WILL TRIM A \nHEDGE IN THE SHAPE \nOF MY SMILE!!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "MY BROTHER WILL ... WELL, HE WON'T CHANGE VERY MUCH.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "I'LL HAVE LOTS OF ADMIRERS!! BUT...", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "HOW WILL I KNOW IF PEOPLE SINCERELY LIKE ME???", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "SOMEONE LIKE YOU IS REALLY RARE...", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "I DON'T THINK THEY'LL LET YOU GO...", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "AFTER YOU'RE CAPTURED AND SENT AWAY.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "URGH... WHO CARES! GIVE UP!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "GIVE UP OR FACE MY... SPECIAL ATTACK!!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "YEAH!!! VERY SOON I WILL USE MY SPECIAL ATTACK!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "NOT TOO LONG AND I WILL USE THAT SPECIAL ATTACK!!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "THIS IS YOUR LAST CHANCE... BEFORE MY SPECIAL ATTACK!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "BEHOLD...! MY SPECIAL ATTACK!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
    [{text: "*SIGH* HERE'S AN ABSOLUTELY NORMAL ATTACK.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}],
];

var attackList = [
    "pap2",
    "pap2",
    "pap3",
    "pap3",
    "pap4",
    "pap4",
    "pap5",
    "pap5",
    "pap6",
    "pap6",
    "pap7",
    "pap7",
    "pap8",
    "pap8",
    "pap9",
    "pap9",
    "pap10",
    "pap10",
    "papSpecialFake",
    "papSpecial",
];


function init(m)
{
    menu = m;
    //setup stats
    menu.character.hp = 680;
    menu.character.maxHP = 680;
    menu.character.atk = 8;
    menu.character.def = 8;
}
var battleProgress = -1;
function generateFightMenu(list)
{
    //create option
    var fightPap = new BattleMenuOption("* Papyrus", function() //on select
    { 
        if (!doneBlueAttack)
            menu.nextAttack = "blueAttack";
        menu.fight("papyrus");
    });
    //add option to list
    list.setList([
        [fightPap]
    ]);
}
function generateActMenu(list)
{
    var pap = new BattleMenuOption("* Papyrus", function() 
    { 
        //create a new menu after selecting
        var newList = new MenuList(menu);

        var checkOption = new BattleMenuOption("* Check", function() //begin dialogue
        {
            menu.showDialogue([
                {text: '* PAPYRUS 8 ATK 2 DEF\n* He likes to say:\n  "Nyeh heh heh!"'},
            ]);
            justChecked = true;
        });

        var asdOption = new BattleMenuOption("* Sing", function() //begin dialogue
        {
            justAskedToSing = true;
            menu.startCharacterDialogue();
        });

        newList.setList([
            [checkOption, asdOption]
        ]);

        menu.changeMenu(newList); //change to new menu
    });

    list.setList([
        [pap]
    ]);
}
function generateMercyMenu(list)
{
    //create option
    var mercyPap = new BattleMenuOption("* Papyrus", function() //on select
    { 
        if (!doneBlueAttack)
            menu.nextAttack = "blueAttack";
        menu.mercy("papyrus");
    });
    //add option to list
    list.setList([
        [mercyPap]
    ]);
}
function startTurn()
{
    if (justFinishedBlueAttack)
    {
        FlxG.sound.playMusic(Paths.inst("bonetrousle"), 1, true);
        doneBlueAttack = true;
    }

    if (doneBlueAttack)
    {
        battleProgress++;
        if (battleProgress % 2 == 1)
            menu.nextAttack = "";
        else 
            menu.nextAttack = attackList[battleProgress];
    
        
        if (justFinishedBlueAttack)
        {
            menu.nextTurnText = {text: "* You're blue now.", sound: "SND_TXT2"};
        }
        else 
        {
            menu.nextTurnText = {text: randomFlavourTexts[(battleProgress-1)%randomFlavourTexts.length], sound: "SND_TXT2"};
        }
    }
    else 
    {
        menu.nextTurnText = {text: "* Papyrus blocks the way!", sound: "SND_TXT2"};
        menu.nextAttack = "pap1";
    }

    justFinishedBlueAttack = false;
}
function characterStartDialogue()
{
    if (justFinishedBlueAttack)
    {
        menu.setCharacterDialogue([
            {text: "YOU'RE BLUE NOW.", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
            {text: "THAT'S MY ATTACK!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
            {text: "NYEH HEH HEH\nHEH HEH HEH\nHEH HEH HEH!!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}
        ]);
    }
    else if (menu.nextAttack == "blueAttack")
    {
        menu.setCharacterDialogue([
            {text: "SO YOU WON'T\nFIGHT...", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
            {text: "THEN, LET'S SEE\nIF YOU CAN HANDLE\nMY FABLED\n'BLUE ATTACK!'", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
        ]);
    }
    else if (justAskedToSing && !doneBlueAttack)
    {
        menu.setCharacterDialogue([
            {text: "YOU WANT ME TO SING WITH YOU!?", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
            {text: "WELL... \nMAYBE LATER...      \nAFTER I CAPTURE YOU!!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24},
        ]);
        askedToSing = true;
        justAskedToSing = false;
    }
    else if (justChecked && !doneBlueAttack)
    {
        menu.setCharacterDialogue([
            {text: "NYEH HEH HEH!", font: "papyrus-ut.ttf", sound: "snd_txtpap", fontSize: 24}
        ]);
        justChecked = false;
    }
    else if (doneBlueAttack)
    {
        if (battleProgress < papDialogues.length)
            menu.setCharacterDialogue(papDialogues[battleProgress]);
    }
    else 
    {    
        
    }

}

function onStartAttack(name)
{
    if (name == 'blueAttack')
    {
        justFinishedBlueAttack = true;
        new FlxTimer().start(8, function(tmr:FlxTimer)
        {
            FlxG.sound.music.fadeOut(1.5);
        });
        new FlxTimer().start(12, function(tmr:FlxTimer)
        {
            menu.startCharacterDialogue();
        });
    }
}

function onUseItem(itemName)
{

}

function onSongStart()
{
    FlxG.sound.playMusic(Paths.music("mus_papyrus"), 1, true);
}