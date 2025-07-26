namespace ClubLeaderboardAPI 
{

    string CurrentUserId = cast<CTrackMania@>(GetApp()).LocalPlayerInfo.WebServicesUserId;

    array<LeaderboardEntry@> GetClubLeaderboardMembers(string mapUid) {
        array<LeaderboardEntry@> result = {};
        array<string> processedUsers = {};

        for(uint i = 0; i < allClubData.Length; i++){
            Json::Value@ clubLeaderboard = GetClubLeaderboardData(allClubData[i].position, mapUid);
            for (int j = 0; j < clubLeaderboard.Length; j++) {
                LeaderboardEntry@ entry = ParseJsonToLeaderboardEntry(clubLeaderboard[j], allClubData[i]);
                if (entry.desc != CurrentUserId && processedUsers.Find(entry.desc) == -1) {
                    processedUsers.InsertLast(entry.desc);
                    entry.positionData = allClubData[i];
                    result.InsertLast(entry);
                } 
            }
        }

        RequestUsernames(result);
        return result;
    }
    
    Json::Value@ GetClubLeaderboardData(uint clubID, string mapUID) {
        if (clubID == 0 || mapUID == "") {
            warn("Invalid parameters for club leaderboard data retrieval");
            return Json::Array();
        }

        auto req = NadeoServices::Get("NadeoLiveServices", GenerateUrl(clubID, mapUID, clubMembersToRetrieve));

        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error calling API at url ' " + req.Url + "' : " + req.ResponseCode() + " - " + req.Error());
            return Json::Array();
        } 

        // get the json object from the response
        Json::Value@ response = Json::Parse(req.String());
        if (response is null || response.GetType() != Json::Type::Object || !response.HasKey("top")) {
            warn("Invalid response from club leaderboard API: " + req.String());
            return Json::Array();
        }
        return response["top"];
    }

    LeaderboardEntry@ ParseJsonToLeaderboardEntry(Json::Value@ json, PositionData@ clubPositionData) {
        if (json is null || json.GetType() != Json::Type::Object) {
            warn("Invalid JSON object for leaderboard entry");
            return null;
        }

        LeaderboardEntry@ entry = LeaderboardEntry();
        entry.time = json["score"];
        entry.desc = json["accountId"];
        entry.entryType = EnumLeaderboardEntryType::CLUB;
        entry.positionData = clubPositionData;

        return entry;
    }

    void RequestUsernames(array<LeaderboardEntry@> entries) {
        array<string> playerIds = {};
        for (uint i = 0; i < entries.Length; i++) {
            playerIds.InsertLast(entries[i].desc);
        }

        dictionary usernames = NadeoServices::GetDisplayNamesAsync(playerIds);
        for (uint i = 0; i < entries.Length; i++) {
            if (usernames.Exists(entries[i].desc)) {
                entries[i].desc = string(usernames[entries[i].desc]);
            } else {
                warn("Username not found for ID: " + entries[i].desc);
            }
        }
    }

    string GenerateUrl(uint clubID, string mapUID, int length) {
        if (clubID == 0 || mapUID == "") {
            warn("Invalid parameters for URL generation");
            return "";
        }
        return NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/" + mapUID + "/club/" + clubID + "/top?length=" + length + "&offset=0";
    }

}