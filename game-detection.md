# Documentation on the game detection

All of the games are available on Steam and Epic Games. We assume that they only have the games on one platform. If someone happens to have the same game on Steam AND Epic games, we will patch the Steam version.

When starting the program, it should detect Steam installations first. Then Epic Games.

**Steam game detection:**

Steam keeps a Windows registry entry about the location of the installation path of Steam. This is always at this location:
`Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam`. From there, the value "InstallPath" needs to be read in order to get the path to the "Steam" folder. From there, you need to enter the "steamapps" folder and read the `libraryfolders.vdf` file. This file keeps track of all of the installed games and their install locations.

This is an example of the file. In this case, the Party Pack 7 is installed to `C:\Program Files (x86)\Steam\steamapps\common\The Jackbox Party Pack 7` and the Party Pack 8 is installed to `D:\SteamLibrary\steamapps\common\The Jackbox Party Pack 8`. The first string ID is the App ID and the second string is the size in Bytes.

So for the installation folder it is always `"path"` + `"/steamapps/common/<Game-Folder>"`

```
"libraryfolders"
{
	"contentstatsid"		"-3535227858174656567"
	"0"
	{
		"path"		"C:\\Program Files (x86)\\Steam"
		"label"		""
		"contentid"		"-3535227858174656567"
		"totalsize"		"0"
		"update_clean_bytes_tally"		"30288598426"
		"time_last_update_corruption"		"0"
		"apps"
		{
			"1211630"		"1617483583"
		}
	}
	"1"
	{
		"path"		"D:\\SteamLibrary"
		"label"		""
		"contentid"		"6753906106662550547"
		"totalsize"		"4000768323584"
		"update_clean_bytes_tally"		"1478568099"
		"time_last_update_corruption"		"0"
		"apps"
		{
			"1552350"		"1460590610"
		}
	}
}
```


**Epic Games game detection:**

Epic Games also keeps a Windows registry entry about the location of the installation path of Epic Games. This is always at this location:
`Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Epic Games\EpicGamesLauncher`. From there, the value "AppDataPath" needs to be read in order to get the path to the "Epic/EpicGamesLauncher/Data" folder. From there, you need to go back one folder (into "EpicGamesLauncherData") and enter the "Epic/UnrealEngineLauncher/" folder and read the `LauncherInstalled.dat` file. This file keeps track of all of the installed games and their install locations.


So for example, the information about where the games are installed are kept in:
`C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat`

This is an example of the file. In this case, the Party Pack 7 is installed to `C:\Program Files (x86)\Epic Games\JackboxPartyPack7` and the Party Pack 8 is installed to `D:\MyCustomInstallation\TJPP8`. The first string ID is the App ID and the second string is the size in Bytes.
```
{
	"InstallationList": [
        {
			"InstallLocation": "C:\\Program Files (x86)\\Epic Games\\JackboxPartyPack7",
			"NamespaceId": "fcefd39bedb14d6282fe2ac41edbd5f8",
			"ItemId": "7604bae254454f12a43923808c58b24f",
			"ArtifactId": "7fb6ce95c6d04a44a55fef16ea0db4c9",
			"AppVersion": "1.0.1",
			"AppName": "7fb6ce95c6d04a44a55fef16ea0db4c9"
		},
		{
			"InstallLocation": "D:\\MyCustomInstallation\\TJPP8",
			"NamespaceId": "44f0df6169284f7fa6d0cddadb3e0ff9",
			"ItemId": "d3b0d31f1e9741769c7b9b853a77bdeb",
			"ArtifactId": "67003fc4eaa444608acf083a08dc907e",
			"AppVersion": "1.0.1",
			"AppName": "67003fc4eaa444608acf083a08dc907e"
		}	
	]
}
```

This is the command to launch games from the command line with Epic Games: `start com.epicgames.launcher://apps/<APPNAME>?action=launch&silent=true`


Note that the folder names are different with the Epic Games version. But that is not that big of a deal, since the exact folder name is already in the LauncherInstalled.dat file. The exe name is always the same. I added the "AppName" to this game_data.json, which is for Epic Games.
For the Party Pack 8, Epic Games needs a different download link for the patch than a Steam one. All of the other patches work for every platform. Party Pack 8 is currently the only exception. I would suggest a string named "alternate_download" in the `locations.json`. If that string exists at a game, the launcher should download the alternate version instead, if it's an Epic Games installation.

What the Dub, Use Your Words, Quiplash, Quiplash 2 InterLASHional, Fibbage XL are not on Epic Games. The Party Packs + Drawful 2 are the only games available on Epic Games.
