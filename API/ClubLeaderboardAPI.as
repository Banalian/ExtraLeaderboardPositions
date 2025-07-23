namespace ClubLeaderboardAPI 
{
    int counterTriesAPI = 0;
    int maxTriesAPI = 3;
    bool failedAPI = false;

    Json::Value@ GetClubLeaderboard(uint clubID, string mapUID, int length = 100){
        if(!useExternalAPI){
            warn("External club API is disabled by user");
            return null;
        }
        if(failedAPI){
            warn("External club API failed too many times, disabling it for the rest of the session");
            return null;
        }
        if(clubID == 0){
            warn("Request is null");
            return null;
        }
        if(mapUID == ""){
            warn("No map selected");
            return null;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();
        auto req = NadeoServices::Get("NadeoLiveServices", "https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/Personal_Best/map/" + mapUID + "/club/" + clubID + "/top?length=" + length + "&offset=0");

        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error calling API at url ' " + req.Url + "' : " + req.ResponseCode() + " - " + req.Error());
            counterTriesAPI++;
            if(counterTriesAPI >= maxTriesAPI){
                failedAPI = true;
                warn("Too many tries, disabling club API for the rest of the session");
            }
            return null;
        } else {
            counterTriesAPI = 0;
            failedAPI = false;
        }

        // get the json object from the response
        Json::Value@ response = Json::Parse(req.String())["top"];
        array<string> playerIds = {};
        for (uint i = 0; i < response.Length; i++) {
            playerIds.InsertLast(string(response[i]["accountId"]));
        }

        dictionary usernames = NadeoServices::GetDisplayNamesAsync(playerIds);
        for (uint i = 0; i < playerIds.Length; i++)
        {
            response[i]["username"] = string(usernames[response[i]["accountId"]]);
        }
        return response;
    }

    MwId GetMainUserId() {
    auto app = cast<CTrackMania>(GetApp());
    if (app.ManiaPlanetScriptAPI.UserMgr.MainUser !is null) {
        return app.ManiaPlanetScriptAPI.UserMgr.MainUser.Id;
    }
    if (app.ManiaPlanetScriptAPI.UserMgr.Users.Length >= 1) {
        return app.ManiaPlanetScriptAPI.UserMgr.Users[0].Id;
    } else {
        return MwId();
    }
}

}