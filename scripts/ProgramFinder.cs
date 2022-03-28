using Godot;
using System;
using Microsoft.Win32;

public class ProgramFinder : Reference
{
    string FindSteam()
    {
        string result = "";
        
        try
        {
            result = (string)Registry.LocalMachine.OpenSubKey("SOFTWARE").OpenSubKey("WOW6432Node").OpenSubKey("Valve").OpenSubKey("Steam").GetValue("InstallPath");

        }
        catch (System.Exception)
        {
            result = "";
        }
        
        return result;
    }

    string FindEpic()
    {
        string result = "";

        try
        {
            result = (string)Registry.LocalMachine.OpenSubKey("SOFTWARE").OpenSubKey("WOW6432Node").OpenSubKey("Epic Games").OpenSubKey("EpicGamesLauncher").GetValue("AppDataPath");
        }
        catch (System.Exception)
        {
            
            result = "";
        }

        return result;
    }
}
