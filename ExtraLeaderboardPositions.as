// ############################## MAIN #############################


void Main(){
#if TMNEXT

    if(!UserCanUseThePlugin()){
        print("Waiting 30 more seconds for permissions...");
        while(timerStartDelay > 0){
            yield();
        }
        if(!UserCanUseThePlugin()){
            warn("You currently don't have the permissions to use this plugin, You need the gold edition");
            warn("If you do have the permissions, the plugin checks every 30 seconds and should work when you finished loading into the main menu");
            timerStartDelay = 30 *1000;
            while(true){
                yield();
                if(timerStartDelay < 0){
                    if(UserCanUseThePlugin()){
                        break;
                    }
                    timerStartDelay = 30 *1000;
                }
            }
        }
        print("Permission granted!");
    }
    startupEnded = true;
    // Add the audiences you need
    NadeoServices::AddAudience("NadeoLiveServices");

    // Wait until the services are authenticated
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
      yield();
    }

    // Load the config to use the External API or not
    ExtraLeaderboardAPI::LoadURLConfig();

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    while(true){

        if(refreshOPConfig){
            ExtraLeaderboardAPI::LoadURLConfig();
            refreshOPConfig = false;
        }

        //if we're on a new map, the timer is over or a new pb has been made we update the times
        if(refreshPosition){
            if(CanRefresh()){
                string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
                if(MapHasNadeoLeaderboard(mapid)){
                    validMap = true;
                    RefreshLeaderboard();
                }else{
                    validMap = false;
                    ClearLeaderboard();
                }
            }else{
                ClearLeaderboard();
            }

            refreshPosition = false;
        }
        yield();

    }

#endif
}

/**
 * Checks if we are in a position to refresh the times or not
 */
bool CanRefresh(){
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    //check that we're in a map
    if (network.ClientManiaAppPlayground is null || network.ClientManiaAppPlayground.Playground is null || network.ClientManiaAppPlayground.Playground.Map is null){
        return false;
    }

    // check that we're not in an invalid gamemode
    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
    string gamemode = ServerInfo.CurGameModeStr;

    if(invalidGamemodes.Find(gamemode) != -1){
        return false;
    }

    //we don't want to update the times if we know the current refresh has already failed.
    //This should not deadlock because other parts of the plugin will be able to unlock this
    if(failedRefresh){
        return false;
    }

    return true;
}

void ClearLeaderboard() {
    if(leaderboardArray.Length > 0){
        leaderboardArray = array<LeaderboardEntry@>();
    }
    currentPbEntry = LeaderboardEntry();
    currentPbEntry.entryType = EnumLeaderboardEntryType::PB;
    currentPbEntry.desc = "PB";
    timeDifferenceEntry = LeaderboardEntry();
}
