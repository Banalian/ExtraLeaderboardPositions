// ############################## MAIN #############################


void Main(){
#if TMNEXT

    if(!UserCanUseThePlugin()){
        print("Waiting 30 more seconds for permissions...");
        while(timerStartDelay > 0){
            yield();
        }
        if(!UserCanUseThePlugin()){
            warn("You currently don't have the permissions to use this plugin, You need a paid subscription.");
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
    HandleMigration();
    startupEnded = true;
    // Add the audiences you need
    NadeoServices::AddAudience("NadeoLiveServices");

    // Wait until the services are authenticated
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
      yield();
    }

    // Load the config to use the External API or not
    ExtraLeaderboardAPI::LoadURLConfig();

    LoadOPConfig();

    LoadCustomData();

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
 * Load custom data
 */
void LoadCustomData(){
#if DEPENDENCY_CHAMPIONMEDALS
    championColor = "\\$f47";
    possibleColors.InsertLast(championColor);
#endif
#if DEPENDENCY_WARRIORMEDALS
    warriorColor =  WarriorMedals::GetColorStr();
    possibleColors.InsertLast(warriorColor);
#endif
}


/**
 * Load OP Config
 */
void LoadOPConfig(){
    Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = "openplanet.dev/plugin/extraleaderboardpositions/config/globalsettings";
        req.Method = Net::HttpMethod::Get;
        
        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error loading plugin config : " + req.ResponseCode() + " - " + req.Error());
            return;
        }

        // get the json object from the response
        auto response = Json::Parse(req.String());
        auto config = response["config"];

        auto forceRefreshAPI = config["forceRefreshAfterSurroundFail"];
        forceRefreshAfterSurroundFail = forceRefreshAPI == "true";
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

    //check that we're in a supported type of mode
    if(currentMode == EnumCurrentMode::INVALID
        || currentMode == EnumCurrentMode::PLATFORM
    ){
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
