// Namespace for the Extra Leaderboard API related stuff

namespace ExtraLeaderboardAPI
{
    string API_URL = "";
    bool Active = false;

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
            warn("External API is disabled");
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
            return null;
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
        for(uint i = 0; i < allPositionToGet.Length; i++){
            request.positions.InsertLast(allPositionToGet[i]);
        }
        if(currentPbTime != -1){
            request.scores.InsertLast(currentPbTime);
        }

        if(showBronze){
            request.medals.InsertLast(MedalType::BRONZE);
        }
        if(showSilver){
            request.medals.InsertLast(MedalType::SILVER);
        }
        if(showGold){
            request.medals.InsertLast(MedalType::GOLD);
        }
        if(showAT){
            request.medals.InsertLast(MedalType::AT);
        }
#if DEPENDENCY_CHAMPIONMEDALS
        if(showChampionMedals){
            int champTime = ChampionMedals::GetCMTime();
            if(champTime != 0){
                request.scores.InsertLast(champTime);
            }
        }
#endif

        return request;
    }
    
}