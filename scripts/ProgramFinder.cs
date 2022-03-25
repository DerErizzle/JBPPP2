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
}
