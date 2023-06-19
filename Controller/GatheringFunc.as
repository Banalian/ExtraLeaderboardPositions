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
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[currScope]["top"];
                if(playerContinent == ""){
                    playerContinent = tops[1]["zoneName"];
                    playerCountry = tops[2]["zoneName"];
                    if(tops.Length > 3)
                        playerRegion = tops[3]["zoneName"];
                    updateAllZonesToSearch();
                }
                if(top.Length > 0) {
                    pbTimeTmp.time = top[0]["score"];
                    currentPbTime = pbTimeTmp.time;
                    pbTimeTmp.position = top[0]["position"];
                    currentPbPosition = pbTimeTmp.position;
                }
            }
        }
    }

    return pbTimeTmp;
}

// Gets the list of Top 10k players on the map and their respective regions - DANIEL1730
void UpdatePlayerLists(){
    if(currScope == 1){
        pluginName = playerContinent + " Leaderboard positions";
    }else if(currScope == 2){
        pluginName = playerCountry + " Leaderboard positions";
    }else if(currScope == 3){
        pluginName = playerRegion + " Leaderboard positions";
    }

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    int offset = 0;

     //check that we're in a map
    while(offset < 1900){
        if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
            auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+currentMapUid+"/top?length=100&offset="+offset+"&onlyWorld=true");
        
            if(info.GetType() != Json::Type::Null) {
                auto tops = info["tops"];
                if(tops.GetType() == Json::Type::Array) {
                    auto top = tops[0]["top"];
                    if(top.Length > 0) {
                        for(int i = 0; i < top.Length; i++){
                            string zone = top[i]["zoneName"];
                            for(int j = 0; j < allZonesToSearch.Length; j++){
                                if(zone == allZonesToSearch[j]){
                                    regionalPlayers.InsertLast(top[i]["accountId"]);
                                    regionalTimes.InsertLast(top[i]["score"]);
                                }
                            }
                        }
                    }
                }            
            }
            offset += 100;
            print(offset / 100);
        }else{
            break;
        }
    }
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


    if(currScope == 0){
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
    }else if(regionalTimes.Length > position-1){
        positionEntry.position = position;
        positionEntry.time = regionalTimes[(position-1)];
        positionEntry.entryType = EnumLeaderboardEntryType::POSITION;
    }else{
        return null;
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

    if(currScope == 0){
        //check that we're in a map
        if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
            string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
            
            auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?score="+time);
        
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
    }else{
        for(int i = 0; i < regionalTimes.Length; i++){
            if(time <= regionalTimes[i]){
                positionEntry.time = time;
                positionEntry.position = i;
                break;
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

#if DEPENDENCY_CHAMPIONMEDALS
        if(showChampionMedals){
            int championTime = ChampionMedals::GetCMTime();
            if(championTime != 0){
                auto championPosition = GetSpecificPositionEntry(championTime);
                championPosition.desc = "Champion";
                championPosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(championPosition)) {
                    tmpArray.InsertLast(championPosition);
                }
            }
        }
#endif

#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        if(showSBVilleATMedal){
            int SBVilleATTime = SBVilleCampaignChallenges::getChallengeTime();
            if(SBVilleATTime != 0){
                auto SBVillePosition = GetSpecificPositionEntry(SBVilleATTime);
                SBVillePosition.desc = "SBVille AT";
                SBVillePosition.entryType = EnumLeaderboardEntryType::MEDAL;
                if(isAValidMedalTime(SBVillePosition)) {
                    tmpArray.InsertLast(SBVillePosition);
                }
            }
        }
#endif

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