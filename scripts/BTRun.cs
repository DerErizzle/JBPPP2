using Godot;
using System;
using Godot.Collections;
using System.Diagnostics;
public class BTRun : Button
{
    Dictionary game_data;

    public void _on_bt_run_pressed()
    {
        try
        {
            if (game_data.Contains("epic"))
            {
                string strCmdText = string.Format("/C start com.epicgames.launcher://apps/{0}?action=launch&silent=true",(string)game_data["appname"]);
                System.Diagnostics.Process.Start("CMD.exe",strCmdText);
            }
            else
            {
                OS.Execute("CMD.exe", new string[]{"/c","start",string.Format("steam://rungameid/{0}",game_data["appid"])},false);
            }
            GD.Print(game_data);
        }
        catch(Exception e)
        {
            GD.Print("Error opening game: ", e.Message);
        }
    }

}

// extends Button

// var game_data:Dictionary

// func _on_bt_run_pressed() -> void:
// 	var output := []
	
// 	if not game_data.has("epic"): 
// 		OS.execute("CMD.exe",["/c","start","steam://rungameid/%s" % game_data.appid],false,output)
// 		return
// 	else:
// #		print(Manager.epic_data.InstallationList)
// #		OS.shell_open("res://CMD/%s.bat" % shortname)
// 		var game_path:String = game_data.path+"/%s" % game_data.exe
// 		var string:String = "\"%s\"" % game_path.replace("/","\\")
		
// 		var err = OS.execute(string,[],true,output)
// 		if err != OK:
// 			print("ERROR OPENING: ", err)
// 		return
		
// 		print("OUT: ", output)
