// File containing all functions that gather data from the API


/**
 * Get the personal best time of the current map from the online leaderboard
 */
LeaderboardEntry@ GetPersonalBestEntry() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    LeaderboardEntry@ pbTimeTmp = LeaderboardEntry();
    pbTimeTmp.time = -1;
    pbTimeTmp.position = -1;
    pbTimeTmp.entryType = EnumLeaderboardEntryType::PB;
    pbTimeTmp.desc = "PB";

    if(!validMap){
        return pbTimeTmp;
    }

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    pbTimeTmp.time = top[0]["score"];
                    pbTimeTmp.position = top[0]["position"];
                    currentPbTime = pbTimeTmp.time;
                    currentPbPosition = pbTimeTmp.position;
                }
            }
        }
    }

    return pbTimeTmp;
}


/**
 * Return the leaderboard entry of a given position
 */
LeaderboardEntry@ GetSpecificTimeEntry(int position) {
    LeaderboardEntry@ positionEntry = LeaderboardEntry();
    if(!validMap){
        return positionEntry;
    }

    int offset = position - 1;

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+currentMapUid+"/top?length=1&offset="+offset+"&onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    int infoTop = top[0]["score"];
                    positionEntry.time = infoTop;
                    positionEntry.position = position;
                    positionEntry.entryType = EnumLeaderboardEntryType::POSITION;
                    return positionEntry;
                }
            }            
        }
    }

    return positionEntry;
}

/**
 *  Return the position of a given time. You still need to check if the time is valid (i.e. if it's different from the top 1, or from the PB)
 */
LeaderboardEntry@ GetSpecificPositionEntry(int time) {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    LeaderboardEntry@ positionEntry = LeaderboardEntry();
    positionEntry.time = -1;
    positionEntry.position = -1;
    positionEntry.entryType = EnumLeaderboardEntryType::TIME;

    if(!validMap){
        return positionEntry;
    }

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?score="+time+"&onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    positionEntry.time = top[0]["score"];
                    positionEntry.position = top[0]["position"];
                }
            }
        }
    }

    return positionEntry;
}


/**
 * Returns an array of LeaderboardEntry with the medals times, if we're able to get them
 */
array<LeaderboardEntry@> GetMedalsEntries(){

    array<LeaderboardEntry@> tmpArray;

    if(!showMedals){
        return tmpArray;
    }
    // We get the medals time
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    auto map = app.RootMap;

    int atTime;
    int goldTime;
    int silverTime;
    int bronzeTime;


    if(network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        atTime = map.TMObjective_AuthorTime;
        goldTime = map.TMObjective_GoldTime;
		silverTime = map.TMObjective_SilverTime;
		bronzeTime = map.TMObjective_BronzeTime;

        // We get the positions of the 4 medals and add them if they are valid and if we need to show them
        if(showAT){
            if(atTime < currentPbTime || currentPbTime == -1){
                auto atPosition = GetSpecificPositionEntry(atTime);
                atPosition.desc = "AT";
                atPosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(atPosition)) {
                    tmpArray.InsertLast(atPosition);
                }
            }
            
        }

        if(showGold){
            if(goldTime < currentPbTime || currentPbTime == -1){
                auto goldPosition = GetSpecificPositionEntry(goldTime);
                goldPosition.desc = "Gold";
                goldPosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(goldPosition)) {
                    tmpArray.InsertLast(goldPosition);
                }
            }
        }

        if(showSilver){
            if(silverTime < currentPbTime || currentPbTime == -1){
                auto silverPosition = GetSpecificPositionEntry(silverTime);
                silverPosition.desc = "Silver";
                silverPosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(silverPosition)) {
                    tmpArray.InsertLast(silverPosition);
                }
            }
        }

        if(showBronze){
            if(bronzeTime < currentPbTime || currentPbTime == -1){
                auto bronzePosition = GetSpecificPositionEntry(bronzeTime);
                bronzePosition.desc = "Bronze";
                bronzePosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(bronzePosition)) {
                    tmpArray.InsertLast(bronzePosition);
                }
            }
        }

    }

    return tmpArray;

}