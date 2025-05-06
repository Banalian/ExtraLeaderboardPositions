// Namespace for the Extra Leaderboard API related stuff

namespace ExtraLeaderboardAPI
{
    string API_URL = "";
    bool Active = false;

    int counterTriesAPI = 0;
    int maxTriesAPI = 3;
    bool failedAPI = false;

    /**
     * load the configuration of the plugin.
     */
    void LoadURLConfig(){
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = "openplanet.dev/plugin/extraleaderboardpositions/config/urls";
        req.Method = Net::HttpMethod::Get;

        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error loading plugin config : " + req.ResponseCode() + " - " + req.Error());
            Active = false;
            return;
        }

        // get the json object from the response
        auto response = Json::Parse(req.String());
        auto externalAPI = response["api"];
        // if the json's "active" is true, set the url, else disable the api calls
        if(externalAPI["active"] == "true"){
            API_URL = externalAPI["url"];
            Active = true;
        }else{
            string reason = externalAPI["reason"];
            warn("External API is disabled by config for now, reason : " + reason);
            Active = false;
        }
    }

    /**
     *  Return a list of LeaderboardEntry objects, given a map id and a list of requests
     */
    ExtraLeaderboardAPIResponse@ GetExtraLeaderboard(ExtraLeaderboardAPIRequest@ request){
        if(!Active){
            warn("External API is disabled by config");
            return null;
        }
        if(!useExternalAPI){
            warn("External API is disabled by user");
            return null;
        }
        if(failedAPI){
            warn("External API failed too many times, disabling it for the rest of the session");
            return null;
        }
        if(request is null){
            warn("Request is null");
            return null;
        }
        if(request.mapId == ""){
            warn("No map selected");
            return null;
        }
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = request.GenerateUrl();
        req.Method = Net::HttpMethod::Get;

        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error calling API at url ' " + req.Url + "' : " + req.ResponseCode() + " - " + req.Error());
            counterTriesAPI++;
            if(counterTriesAPI >= maxTriesAPI){
                failedAPI = true;
                warn("Too many tries, disabling API for the rest of the session");
            }
            return null;
        } else {
            counterTriesAPI = 0;
            failedAPI = false;
        }

        // get the json object from the response
        auto response = Json::Parse(req.String());
        ExtraLeaderboardAPIResponse@ result = ExtraLeaderboardAPIResponse();
        return result.fromJson(response);
    }

    /**
     * Prepare the ExtraLeaderboardAPIRequest object based on current parameters
     */
    ExtraLeaderboardAPIRequest@ PrepareRequest(bool getPlayerCount = false, bool getMapInfo = false){
        ExtraLeaderboardAPIRequest@ request = ExtraLeaderboardAPIRequest();
        if(currentMapUid == ""){
            warn("No map selected");
            return null;
        }
        request.mapId = currentMapUid;
        request.getPlayerCount = getPlayerCount;
        request.getMapInfo = getMapInfo;
        for(uint i = 0; i < allPositionData.Length; i++){
            request.positions.InsertLast(allPositionData[i].position);
        }


        for(uint i = 1; i <= MedalType::AT; i++){
            if(ShouldRequestMedal(MedalType(i))){
                request.medals.InsertLast(MedalType(i));
            }
        }
        // This is the same as above, but for custom medals
        for(uint i = MedalType::AT + 1; i < MedalType::COUNT; i++){
            if(ShouldRequestMedal(MedalType(i))){
                request.scores.InsertLast(GetCustomMedalTime(MedalType(i)));
            }
        }

        return request;
    }
}


/**
 * Check if a medal should be requested based on settings and current PB
 * Assumes that we're in a map.
 * Isn't in toolbox since it's some "private" function only used in this namespace(and above function)
 */
bool ShouldRequestMedal(MedalType medal){
    if (!showMedals) return false;

    auto app = GetApp();
    auto map = app.RootMap;

    bool shouldShow = false;
    int medalTime = -1;
    switch(medal){
        case MedalType::BRONZE:
               shouldShow = showBronze;
               medalTime = map.TMObjective_BronzeTime;
               break;
         case MedalType::SILVER:
               shouldShow = showSilver;
                medalTime = map.TMObjective_SilverTime;
               break;
        case MedalType::GOLD:
                shouldShow = showGold;
                medalTime = map.TMObjective_GoldTime;
                break;
        case MedalType::AT:
                shouldShow = showAT;
                medalTime = map.TMObjective_AuthorTime;
                break;
#if DEPENDENCY_CHAMPIONMEDALS
        case MedalType::CHAMPION:
                shouldShow = showChampionMedals;
                medalTime = ChampionMedals::GetCMTime();
                break;
#endif
#if DEPENDENCY_WARRIORMEDALS
        case MedalType::WARRIOR:
                shouldShow = showWarriorMedals;
                medalTime = WarriorMedals::GetWMTime();
                break;
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        case MedalType::SBVILLE:
                shouldShow = showSBVilleATMedal;
                medalTime = SBVilleCampaignChallenges::getChallengeTime();
                break;
#endif
#if DEPENDENCY_S314KEMEDALS
        case MedalType::S314KE:
                shouldShow = showS314keMedals;
                medalTime = s314keMedals::GetS314keMedalTime();
                break;
#endif
        default:
                error("Unknown medal type :" + medal);
                return false;
    }

    // Check if the medal is better than the PB or if the user wants to show it anyway
    if(shouldShow && currentPbEntry.time != -1){
        shouldShow =  medalTime < currentPbEntry.time || showMedalWhenBetter;
    }

    if( medalTime <= 0 
        && ( false
#if DEPENDENCY_CHAMPIONMEDALS
        || medal == MedalType::CHAMPION
#endif
#if DEPENDENCY_WARRIORMEDALS
        || medal == MedalType::WARRIOR
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        || medal == MedalType::SBVILLE
#endif
#if DEPENDENCY_S314KEMEDALS
        || medal == MedalType::S314KE
#endif
        )
    ){
        // If the medal is not set, we don't show it
        // base medals are always set, but might be hidden. this will be handled elsewhere
        shouldShow = false;
    }

    return shouldShow;
}

int GetCustomMedalTime(MedalType medal){
    if(medal <= MedalType::AT || medal >= MedalType::COUNT){
        error("GetCustomMedalTime: medal is not a custom medal : " + medal);
        return -1;
    }

    switch(medal){
#if DEPENDENCY_CHAMPIONMEDALS
        case MedalType::CHAMPION:
            return ChampionMedals::GetCMTime();
#endif
#if DEPENDENCY_WARRIORMEDALS
        case MedalType::WARRIOR:
            return WarriorMedals::GetWMTime();
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        case MedalType::SBVILLE:
            return SBVilleCampaignChallenges::getChallengeTime();
#endif
#if DEPENDENCY_S314KEMEDALS
        case MedalType::S314KE:
            return s314keMedals::GetS314keMedalTime();
#endif
        case MedalType::COUNT:
            // This should never happen, it's here to appease the compiler since without any dependency, the switch is empty
            error("GetCustomMedalTime: medal is not a custom medal : " + medal);
            return -1;
        default:
            error("GetCustomMedalTime: medal is not a custom medal : " + medal);
            return -1;
    }
}