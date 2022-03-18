using Godot;
using System;
using System.Net;

public class DownloadManager : Reference
{

    [Signal]
    delegate void finished();
    Node caller;
    String callback_func;
    Timer timer;
    private bool timed_out = false;
    int lastPercent = -1;

    public void Request(Node the_caller, String url, String outDir, String callback_func)
    {
        // Accept All requests to https (workaround)
        System.Net.ServicePointManager.ServerCertificateValidationCallback =
            ((sender, certificate, chain, sslPolicyErrors) => true);

        // The timer is used here because OnProgressChanged blocks Godot's main thread
        timer = new Timer();
        timed_out = false;
        the_caller.AddChild(timer);
        timer.WaitTime = .1f;
        timer.OneShot = false;
        timer.Connect("timeout",this, nameof(OnTimedOut));
        timer.Start();

        caller = the_caller;
        this.callback_func = callback_func;
        var source = new Uri(url);
        using (WebClient client = new WebClient())
        {
            client.DownloadProgressChanged += OnProgressChanged;
            client.DownloadFileCompleted += OnDownloaded;
            lastPercent = -1;
            client.DownloadFileAsync(source, outDir, outDir);
        }
        
       
    }

    private void OnTimedOut()
    {
        GD.Print("Timed out");
        timed_out = true;
    }

    private void OnProgressChanged(object sender, DownloadProgressChangedEventArgs e) 
    {
        int targetPercent = e.ProgressPercentage;
        if (lastPercent >= targetPercent) return;
        lastPercent = targetPercent;
        if (timed_out == false) return;
        timed_out = false;
        caller.Call("console_add_text", string.Format("Downloaded {0} of {1} MBytes. {2}% completed", e.BytesReceived / 1000000, e.TotalBytesToReceive / 1000000, e.ProgressPercentage));
    }

    private void OnDownloaded(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
    {
        timer.QueueFree();
        var client = (WebClient)sender;
        client.DownloadProgressChanged -= OnProgressChanged;
        client.DownloadFileCompleted -= OnDownloaded;
        caller.Call("console_add_text", "Download Finished!!!!!");

        if (e.Error != null)
        {
            GD.Print("ERR");
            GD.PushError("Error Downloading zip: "+e.Error.Message);
        }

        GD.Print("FINISHED VIA C#");
        EmitSignal("finished");
    }
}
