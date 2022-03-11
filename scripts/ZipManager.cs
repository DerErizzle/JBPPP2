using Godot;
using System;
using System.Text;
using Ionic.Zip;
using Ionic.Zlib;
using System.Collections.Generic;

struct tData {
    public List<int> zip_indexes;
    public String outPath;
    public String zipPath;

}
public class ZipManager : Reference
{
    
    System.Threading.Mutex mutex = new System.Threading.Mutex();
    int jobs_done = 0;
	Node theOwner;
        async public void Extract(Node theOwner, string zipPath, String outPath) 
		{
		
			int procCount = OS.GetProcessorCount()-1;
        this.theOwner = theOwner;
		theOwner.CallDeferred("console_add_text","Extracting files...");
        float startTime = OS.GetTicksMsec();

        var threads = new System.Threading.Thread[procCount];
        List<List<int>> pathPool = new List<List<int>>();
        for (int i = 0; i < procCount; i++)
        {
            pathPool.Add(new List<int>());
        }

        ZipFile zip = ZipFile.Read(@zipPath);
        
        GD.Print(zip.Count);

        for (int i = 0; i < zip.Count; i++)
        {

            int threadIndex = i%procCount;

            List<int> list = pathPool[threadIndex];
            list.Add(i);

            // GD.Print(String.Format("insert item: {0} > {2} < in Thread: {1}",i,i%OS.GetProcessorCount(),path));   
        }

        jobs_done = 0;
        for (int i = 0; i < threads.Length; i++)
        {
            threads[i] = new System.Threading.Thread(JobExtract);
            tData sharedData = new tData();
            sharedData.zip_indexes = pathPool[i];
            sharedData.outPath = outPath;
            sharedData.zipPath = zipPath;
            threads[i].Start(sharedData);
        }

        
        while(jobs_done < threads.Length)
        {
            GD.Print("Jobs DOne: ", jobs_done);
            await ToSignal(theOwner.GetTree(),"idle_frame");
        }

        GD.Print("Finished");
        float endTime = OS.GetTicksMsec() - startTime;
        GD.Print("Done in: ", endTime);

		theOwner.EmitSignal("threads_done");
    }

    void JobExtract(object data)
    {
        
        tData d = (tData)data;
        ZipFile zip = ZipFile.Read(d.@zipPath);
        for (int i = 0; i < d.zip_indexes.Count; i++)
        {
			// theOwner.CallDeferred("console_add_text",string.Format("Extracting: {0}", zip[d.zip_indexes[i]].FileName));
            zip[d.zip_indexes[i]].Extract(d.outPath, ExtractExistingFileAction.OverwriteSilently);
        }

        mutex.WaitOne();
        jobs_done += 1;
        mutex.ReleaseMutex();

    }

}
