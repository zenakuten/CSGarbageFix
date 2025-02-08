class MutCSGarbageFix extends Mutator;

var config bool bCollectGarbage;
var config bool bFixCacheMegSize;
var config bool bFixServerBrowser;
var config bool bFixReduceMouseLag;
var config bool bFixNetSettings;

replication
{
    reliable if (ROLE == ROLE_Authority && bNetInitial)
        bCollectGarbage, bFixCacheMegSize, bFixServerBrowser, bFixReduceMouseLag, bFixNetSettings;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("GarbageFix", "bCollectGarbage", "Collect garbage", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixCacheMegSize", "Fix cache meg size", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixServerBrowser", "Fix server browser", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixReduceMouseLag", "disable reduce mouse lag", 0, 1, "Check");
	PlayInfo.AddSetting("GarbageFix", "bFixNetSettings", "fix keepalive, clientrate", 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bCollectGarbage":	return "Collect garbage";
		case "bFixCacheMegSize": return "Fix cache meg size";
		case "bFixServerBrowser": return "Fix the server browser not loading with high netspeed";
		case "bFixReduceMouseLag": return "disable reduce mouse lag";
	}

	return Super.GetDescriptionText(PropName);
}

simulated function PostNetBeginPlay()
{
    local PlayerController PC;
    super.PostNetBeginPlay();
    if(level.NetMode != NM_DedicatedServer)
    {
        PC = Level.GetLocalPlayerController();
        if(PC != None)
        {
            if(bCollectGarbage)
                PC.ConsoleCommand("obj garbage");
            if(bFixCacheMegSize)
                PC.ConsoleCommand("set Engine.GameEngine cachesizemegs 1");
            if(bFixServerBrowser)
            {
                PC.ConsoleCommand("set XInterface.GUIController MaxSimultaneousPings 40");
                PC.ConsoleCommand("set GUI2K4.UT2k4ServerBrowser bStandardServersOnly False");
            }
            if(bFixReduceMouseLag)
            {
                PC.ConsoleCommand("set D3DDrv.D3DRenderDevice ReduceMouseLag false");
                PC.ConsoleCommand("set D3D9Drv.D3D9RenderDevice ReduceMouseLag false");
                PC.ConsoleCommand("set OpenGLDrv.OpenGLRenderDevice ReduceMouseLag false");
                PC.ConsoleCommand("set PixoDrv.PixoRenderDevice ReduceMouseLag false");
            }
            if(bFixNetSettings)
            {
                PC.ConsoleCommand("set IpDrv.TcpNetDriver KeepAliveTime 0.2");
                PC.ConsoleCommand("set IpDrv.TcpNetDriver MaxClientRate 1000000");
                PC.ConsoleCommand("set IpDrv.TcpNetDriver MaxInternetClientRate 1000000");
            }
        }
    }
}

defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="GarbageFix"
    Description="Clean up garbage for clients"
}