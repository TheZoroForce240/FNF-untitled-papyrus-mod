@echo off
color 0a
cd ..
mkdir .haxelib
@echo on
echo Installing dependencies.
haxelib install hxcpp
haxelib install lime 8.1.1
haxelib install openfl 9.1.0
haxelib install flixel 5.2.2
haxelib install flixel-addons 3.0.2
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib install hxvlc 1.8.2
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib install hscript
echo Finished!
pause
