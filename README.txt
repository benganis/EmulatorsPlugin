Thanks for downloading EmulatorsPlugIn.

It was made by bgan1982@mac.com (Ben)

For the latest version, please visit:

http://code.google.com/p/emulatorsplugin/
http://wiki.awkwardtv.org/wiki/EmulatorsPlugIn

------------------------------------------------------------------------

Installation Directions:

Step 1.  Install the latest versions of these emulators on your Apple TV
in the following locations:

     /Applications/Boycott Advance.app
     /Applications/Genesis Plus.app
     /Applications/Mugrat.app
     /Applications/Nestopia.app
     /Applications/sixtyforce.app
     /Applications/Snes9X.app
     /Applications/zsnes.app

(Optional) Also install Emulator Enhancer:

     /Users/frontrow/Library/Application Support/Emulator Enhancer/EmulatorEnhancer.bundle

Step 2.  Copy the ROMs you wish to install into the following directory
structure on your Apple TV:

     /Users/frontrow/ROMs/Coleco
     /Users/frontrow/ROMs/GBA
     /Users/frontrow/ROMs/Genesis
     /Users/frontrow/ROMs/N64
     /Users/frontrow/ROMs/NES
     /Users/frontrow/ROMs/SNES

As of version 2.0, you can now have sub-folders.

Step 3.  Install the EmulatorsPlugIn into the PlugIns folder:

     /System/Library/CoreServices/Finder.app/Contents/PlugIns/Emulators.frappliance

Step 4.  Restart FrontRow:

     ps ax | awk '/Finder/ && !/awk/ {print $1}'

Step 5.  Set your Emulators to have desired settings such as Full Screen,
Controller Map, etc.  You can use my default settings by selecting:

     Options -> Reset Emulators Preferences

Now you should be good to go.

------------------------------------------------------------------------

Customization:

To add additional Emulators, ROM folders, other Applications,  
AppleScripts, and other options, edit the EmulatorsPlugIn Preferences:

     /Users/frontrow/Library/Preferences/com.bgan1982.EmulatorsPlugIn.plist

It is initially created with my default values, and can be erased and 
reset at any time by selecting:

     Options -> Reset PlugIn Preferences

Here are descriptions for keys in the plist:

identifier      : The executable name of an emulator.
name            : The emulator name that will appear in the menu.
path            : The path to ROMs folder for the current emulator. If
                  this tag is missing or empty, it will run the executable  
                  without bringing up a ROM list.
preferred-order : A real number which gives the order of the categories.
                  Make sure these are unique.

alt-identifier      (optional) : Executable name of a child process.
   For example, ZSNES.app launches the 'zsnes' process.

startup-script      (optional) : An AppleScript that will run when the executable is launched.
up-button-script    (optional) : An AppleScript that will run when the up key is pressed.
down-button-script  (optional) : An AppleScript that will run when the down key is pressed.
left-button-script  (optional) : An AppleScript that will run when the left key is pressed.
right-button-script (optional) : An AppleScript that will run when the right key is pressed.
file-extensions     (optional) : A comma separated list of which file extensions to display.
   All files which do not end in these extensions will be filtered out of the ROM list.

AppleScripts require that the following components be installed, which
are available from the 1.0 recovery partition:

     /System/Library/CFMSupport
     /System/Library/Components/AppleScript.component
     /System/Library/Components/DictionaryService.component
     /System/Library/CoreServices/CarbonSpellChecker.bundle
     /System/Library/Frameworks/AppKitScripting.framework
     /System/Library/Frameworks/AppleScriptKit.framework
     /System/Library/Frameworks/Scripting.framework
     /System/Library/Frameworks/OSAKit.framework
     /System/Library/PrivateFrameworks/AppleScript.framework
     /System/Library/ScriptingAdditions

To streamline scripting, when a ROM is played, a temporary file is 
written to:

     /Users/frontrow/.pathToROM
