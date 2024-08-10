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

        if(ShouldRequestMedal(MedalType::BRONZE)){
            request.medals.InsertLast(MedalType::BRONZE);
        }
        if(ShouldRequestMedal(MedalType::SILVER)){
            request.medals.InsertLast(MedalType::SILVER);
        }
        if(ShouldRequestMedal(MedalType::GOLD)){
            request.medals.InsertLast(MedalType::GOLD);
        }
        if(ShouldRequestMedal(MedalType::AT)){
            request.medals.InsertLast(MedalType::AT);
        }
#if DEPENDENCY_CHAMPIONMEDALS
        // We rewrite the logic of the ShouldRequestMedal function since we don't want to modify the medal enum
        int champTime = ChampionMedals::GetCMTime();
        if(
            champTime != 0 && // if the medal exists
            showMedals && showChampionMedals && // if the user wants to show it
            (((champTime < currentPbEntry.time) || currentPbEntry.time == -1) || showMedalWhenBetter) // if the medal is better than the PB or if the user wants to show it anyway
    
        ){
            request.scores.InsertLast(champTime);
        }
#endif
#if DEPENDENCY_WARRIORMEDALS
        // We rewrite the logic of the ShouldRequestMedal function since we don't want to modify the medal enum
        int warTime = WarriorMedals::GetWMTime();
        if(
            warTime != 0 && // if the medal exists
            showMedals && showWarriorMedals && // if the user wants to show it
            (((warTime < currentPbEntry.time) || currentPbEntry.time == -1) || showMedalWhenBetter) // if the medal is better than the PB or if the user wants to show it anyway
    
        ){
            request.scores.InsertLast(warTime);
        }
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        // Same as above
        int sbVilleTime = SBVilleCampaignChallenges::getChallengeTime();
        if(
            sbVilleTime != 0 && // if the medal exists
            showMedals && showSBVilleATMedal && // if the user wants to show it
            (((sbVilleTime < currentPbEntry.time) || currentPbEntry.time == -1) || showMedalWhenBetter) // if the medal is better than the PB or if the user wants to show it anyway
    
        ){
            request.scores.InsertLast(sbVilleTime);
        }
#endif

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
    }

    // Check if the medal is better than the PB or if the user wants to show it anyway
    if(shouldShow && currentPbEntry.time != -1){
        shouldShow =  medalTime < currentPbEntry.time || showMedalWhenBetter;
    }

    return shouldShow;
}
