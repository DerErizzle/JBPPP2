# Documentation on the game detection

All of the games are available on Steam and Epic Games. We assume that they only have the games on one platform. If someone happens to have the same game on Steam AND Epic games, we will patch the Steam version.

When starting the program, it should detect Steam installations first. Then Epic Games.

**Steam game detection:**

The information about where the games are installed are kept in:
`C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf`


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

The information about where the games are installed are kept in:
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

```
{
  "games": [
    {
      "title": "Party Pack",
      "shortname": "pp1",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp1.png?raw=true",
      "appid": 331670,
      "appname": "Feverfew"
      "exe": "The Jackbox Party Pack.exe",
      "folder": "The Jackbox Party Pack",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 2",
      "shortname": "pp2",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp2.png?raw=true",
      "appid": 397460,
      "appname": "XXXXXXXXXX"
      "exe": "The Jackbox Party Pack 2.exe",
      "folder": "The Jackbox Party Pack 2",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 3",
      "shortname": "pp3",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp3.png?raw=true",
      "appid": 434170,
      "appname": "Orchid"
      "exe": "The Jackbox Party Pack 3.exe",
      "folder": "The Jackbox Party Pack 3",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 4",
      "shortname": "pp4",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp4.png?raw=true",
      "appid": 610180,
      "appname": "Orchid"
      "exe": "The Jackbox Party Pack 4.exe",
      "folder": "The Jackbox Party Pack 4",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 5",
      "shortname": "pp5",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp5.png?raw=true",
      "appid": 774461,
      "appname": "XXXXXXXXXX"
      "exe": "The Jackbox Party Pack 5.exe",
      "folder": "The Jackbox Party Pack 5",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 6",
      "shortname": "pp6",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp6.png?raw=true",
      "appid": 1005300,
      "appname": "XXXXXXXXXX"
      "exe": "The Jackbox Party Pack 6.exe",
      "folder": "The Jackbox Party Pack 6",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 7",
      "shortname": "pp7",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp7.png?raw=true",
      "appid": 1211630,
      "appname": "7fb6ce95c6d04a44a55fef16ea0db4c9"
      "exe": "The Jackbox Party Pack 7.exe",
      "folder": "The Jackbox Party Pack 7",
      "config": "config.jet"
    },
    {
      "title": "Party Pack 8",
      "shortname": "pp8",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/pp8.png?raw=true",
      "appid": 1552350,
      "appname": "67003fc4eaa444608acf083a08dc907e"
      "exe": "The Jackbox Party Pack 8.exe",
      "folder": "The Jackbox Party Pack 8",
      "config": "config.jet"
    },
    {
      "title": "Quiplash",
      "shortname": "qp1",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/qp1.png?raw=true",
      "appid": 351510,
      "exe": "Quiplash.exe",
      "folder": "Quiplash",
      "config": "jbg.config.jet"
    },
    {
      "title": "Quiplash 2 InterLASHional",
      "shortname": "qp2",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/qp2.png?raw=true",
      "appid": 1111940,
      "exe": "Quiplash 2 InterLASHional.exe",
      "folder": "Quiplash 2 InterLASHional",
      "config": "jbg.config.jet"
    },
    {
      "title": "Drawful 2",
      "shortname": "dr2",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/dr2.png?raw=true",
      "appid": 442070,
      "appname": "Daisy"
      "exe": "Drawful 2.exe",
      "folder": "Drawful 2",
      "config": "jbg.config.jet"
    },
    {
      "title": "Fibbage XL",
      "shortname": "fxl",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/fxl.png?raw=true",
      "appid": 448080,
      "exe": "Fibbage XL.exe",
      "folder": "Fibbage XL",
      "config": "jbg.config.jet"
    },
    {
      "title": "Use Your Words",
      "shortname": "uyw",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/uyw.png?raw=true",
      "appid": 521350,
      "exe": "uyw.exe",
      "folder": "Use Your Words",
      "config": "config.dat",
      "custom_config": true
      
    },
    {
      "title": "What the Dub",
      "shortname": "wtd",
      "icon": "https://github.com/DerErizzle/JBPPP2/blob/data/icons/wtd.png?raw=true",
      "appid": 1495860,
      "exe": "WhatTheDub.exe",
      "folder": "WhatTheDub",
      "config": "config.dat",
      "custom_config": true
    }
  ]
}
```
