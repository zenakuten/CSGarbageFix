class MutCSGarbageFix extends Mutator;

enum EMasterServer
{
    MS_333Networks,
    MS_Errorist,
    MS_333NetworksAndErrorist,
    MS_OpenSpy
};

var config bool bCollectGarbage;
var config bool bFixCacheSizeMegs;
var config bool bFixReduceMouseLag;
var config bool bFixServerBrowser;
var config bool bFixNetSettings;
var config bool bFixMasterServer;
var config EMasterServer SelectedMasterServer;

replication
{
    reliable if (ROLE == ROLE_Authority)
        bCollectGarbage, bFixCacheSizeMegs, bFixReduceMouseLag, bFixServerBrowser, bFixNetSettings, bFixMasterServer, SelectedMasterServer;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("GarbageFix", "bCollectGarbage", "Collect garbage", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixCacheSizeMegs", "Fix CacheSizeMegs", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixReduceMouseLag", "Fix ReduceMouseLag", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixServerBrowser", "Fix the server browser", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixNetSettings", "Fix net settings", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixMasterServer", "Update player's master server", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "SelectedMasterServer", "Master server to use:", 0, 1, "Select", "MS_333Networks;333Networks;MS_Errorist;Errorist;MS_333NetworksAndErrorist;333Networks+Errorist;MS_OpenSpy;OpenSpy");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bCollectGarbage":	return "obj garbage";
		case "bFixCacheSizeMegs": return "CacheSizeMegs=1";
		case "bFixReduceMouseLag": return "ReduceMouseLag=False; this reduces latency and increases FPS";
		case "bFixServerBrowser": return "Fix the server browser not loading with high netspeed (MaxSimultaneousPings=200), bStandardServersOnly=False";
		case "bFixNetSettings": return "KeepAliveTime=0.2, Max(Internet)ClientRate=1000000, bDynamicNetSpeed=False, Netspeed 1000000";
		case "bFixMasterServer": return "Update the player's master server";
        case "SelectedMasterServer": return "333Networks/Errorist lower ping to EU, OpenSpy lower ping to NA";
	}

	return Super.GetDescriptionText(PropName);
}

simulated function Tick(float dt)
{
    local PlayerController PC;
    super.Tick(dt);
    if(level.NetMode != NM_DedicatedServer)
    {
        PC = Level.GetLocalPlayerController();
        if(PC != None)
        {
            if(bCollectGarbage)
            {
                PC.ConsoleCommand("obj garbage");
            }
            if(bFixCacheSizeMegs)
            {
                PC.ConsoleCommand("set Engine.GameEngine CacheSizeMegs 1");
            }
            if(bFixReduceMouseLag)
            {
                PC.ConsoleCommand("set D3DDrv.D3DRenderDevice ReduceMouseLag False");
                PC.ConsoleCommand("set D3D9Drv.D3D9RenderDevice ReduceMouseLag False");
                PC.ConsoleCommand("set OpenGLDrv.OpenGLRenderDevice ReduceMouseLag False");
                PC.ConsoleCommand("set PixoDrv.PixoRenderDevice ReduceMouseLag False");
            }
            if(bFixServerBrowser)
            {
                PC.ConsoleCommand("set XInterface.GUIController MaxSimultaneousPings 200");
                PC.ConsoleCommand("set GUI2K4.UT2k4ServerBrowser bStandardServersOnly False");
            }
            if(bFixNetSettings)
            {
                PC.ConsoleCommand("set IpDrv.TcpNetDriver KeepAliveTime 0.2");
                PC.ConsoleCommand("set IpDrv.TcpNetDriver MaxClientRate 1000000");
                PC.ConsoleCommand("set IpDrv.TcpNetDriver MaxInternetClientRate 1000000");
				PC.ConsoleCommand("set Engine.Player ConfiguredInternetSpeed 1000000");
				PC.ConsoleCommand("set Engine.Player ConfiguredLanSpeed 1000000");
				PC.ConsoleCommand("Netspeed 1000000");
            }
            if(bFixMasterServer)
			{
				if(SelectedMasterServer == MS_333Networks)
					PC.ConsoleCommand("set IpDrv.MasterServerLink MasterServerList ((Address=\"ut2004master.333networks.com\",Port=28902))");
				else if(SelectedMasterServer == MS_Errorist)
					PC.ConsoleCommand("set IpDrv.MasterServerLink MasterServerList ((Address=\"ut2004master.errorist.eu\",Port=28902))");
				else if(SelectedMasterServer == MS_333NetworksAndErrorist)
					PC.ConsoleCommand("set IpDrv.MasterServerLink MasterServerList ((Address=\"ut2004master.333networks.com\",Port=28902),(Address=\"ut2004master.errorist.eu\",Port=28902))");
				else if(SelectedMasterServer == MS_OpenSpy)
					PC.ConsoleCommand("set IpDrv.MasterServerLink MasterServerList ((Address=\"utmaster.openspy.net\",Port=28902))");
				else
					Log("Warning: could not determine which master server to use");
			}
            Disable('Tick');
        }
    }
}

defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="CSGarbageFix"
    Description="Runs console commands on behalf of clients to reduce crashes, fix networking, and improve performance."
    RemoteRole=ROLE_SimulatedProxy
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=false
    bAlwaysRelevant=true
}