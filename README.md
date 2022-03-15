# Configuration Manager

The content of this branch is downloaded by every JPPP Launcher on the fly, be careful when modifying them!!!
After updating those files, every user will not need to update their program, just reopen it, and the updates will reach them!


# Adding a new Game

**game_data.json**:

* title: 

Is the Full name of the game ( GUI Only )

* shortname:

used to identify the game name in the locations.json, for example: DrawFul 2 is `dr2`
also must be the same name of the image in the `icons/` folder

* icon:

the raw github url to the icons/image.png

* appid:

steam's game id, can be easily got by going to the game on steam and right click -> properties
used for identifying the game in the program

* appname:

Epic Games's game id, used for detection, note: Epic games will be only be detected if you dont have the game on steam

* exe:

The name of the executable file inside steamapps/common/GAMENAME/GAMENAME.exe

* folder:

the name of the game folder in steamapps/common/

* config:

the name of the configuration file inside steamapps/common/GAMENAME/CONFIGFILE.FORMAT

* custom_config:

actually used in `Use Your Words` and `What The Dub` because they dont have configuration files,
but the modder can create one, which is used to keep track of the game version

**Custom configuration file**

This file is used to keep track of the patch version, must be located under `GAMENAME/config.dat`
the content of the file must be in JSON:

```
{
    "buildVersion":"1.1-ES"
}
```

the numbers must be a float value:
Valid float: 1.2 - 25.4 - 14.3
Invalid float: 1.1.1 - 23.3.0

the ES is a pattern for a country in the above case ES - Spain

----

After filling those fields, dont forget to put the icon inside icons/ folder with the same name as `shortname` and must be **PNG** and same size of the others

# Adding/Updating a new language

The most imparnt for the program is the locations files, this tell to it where the patch files are located!

**locations.json**:

File structure
```
    "COUNTRY": {
        "country-file": "COUNTRY-FILE",
        "version": {
            "SHORTNAME": "RAW_GITHUB_URL"
        },
        "patch-locale": "PATCH_LOCALE",
        "patch": {
            "SHORTNAME": "RAW_GITHUB_URL",
        }
    },
```

* COUNTRY:

The name of the country - all lowercase
used for showing the country name in select language screen

* COUNTRY-FILE:

The country file inside `flags/file.jpg`
used to show the country flag in the select language screen
file must be: `jpg` & size: `160x96`


* SHORTNAME:

same name used in `game_data.json`'s shortname tag

* PATCH_LOCALE:

Same name used in the configuration file of the mod

* RAW_GITHUB_URL:

The url to the mod files

**IMPORTANT**

the `version` tag points to the configuration file of the mod
the `patch` tag points to the actual mod files in .zip format  