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
    pbTimeTmp.positionData = currentPbPositionData;

    if(!validMap){
        return pbTimeTmp;
    }

    // Check that we're in a map
    if (network.ClientManiaAppPlayground is null || network.ClientManiaAppPlayground.Playground is null || network.ClientManiaAppPlayground.Playground.Map is null) {
        return pbTimeTmp;
    }

    string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
    auto info = FetchEndpoint(NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?onlyWorld=true");
    if(info.GetType() == Json::Type::Null) {
        // error fetching data
        return pbTimeTmp;
    }

    auto tops = info["tops"];
    if(tops.GetType() != Json::Type::Array || tops.Length == 0) {
        // error fetching data, empty object or array
        return pbTimeTmp;
    }

    auto top = tops[0]["top"];
    if(top.Length == 0) {
        // error fetching data, empty array
        return pbTimeTmp;
    }

    pbTimeTmp.time = top[0]["score"];
    pbTimeTmp.position = top[0]["position"];
    trace("Nadeo returned: score: " + tostring(pbTimeTmp.time) + " position: " + tostring(pbTimeTmp.position));

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

    // find the related positionData
    for (uint i = 0; i < allPositionData.Length; i++) {
        if (int(allPositionData[i].position) == position) {
            positionEntry.positionData = allPositionData[i];
            break;
        }
    }
    int offset = position - 1;

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        auto info = FetchEndpoint(NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/"+currentMapUid+"/top?length=1&offset="+offset+"&onlyWorld=true");

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

        auto info = FetchEndpoint(NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?score="+time+"&onlyWorld=true");

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

        // we only do a try here because we don't want to fail the refresh if the dependencies somehow throw an error
#if DEPENDENCY_CHAMPIONMEDALS
        TryAddMedalPosition(showChampionMedals, ChampionMedals::GetCMTime(), "Champion", championMedalPositionData, tmpArray);
#endif
#if DEPENDENCY_WARRIORMEDALS
        TryAddMedalPosition(showWarriorMedals, WarriorMedals::GetWMTime(), "Warrior", warriorMedalPositionData, tmpArray);
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        TryAddMedalPosition(showSBVilleATMedal, SBVilleCampaignChallenges::getChallengeTime(), "SBVille AT", sbVillePositionData, tmpArray);
#endif
#if DEPENDENCY_S314KEMEDALS
        TryAddMedalPosition(showS314keMedals, s314keMedals::GetS314keMedalTime(), "S314ke", s314keMedalPositionData, tmpArray);
#endif

        // We get the positions of the 4 medals and add them if they are valid and if we need to show them
        AddMedalPosition(showAT, atTime, "AT", atPositionData, tmpArray);
        AddMedalPosition(showGold, goldTime, "Gold", goldPositionData, tmpArray);
        AddMedalPosition(showSilver, silverTime, "Silver", silverPositionData, tmpArray);
        AddMedalPosition(showBronze, bronzeTime, "Bronze", bronzePositionData, tmpArray);
    }

    return tmpArray;

}


void AddMedalPosition(bool showMedal, int medalTime, const string &in desc, PositionData &positionData, array<LeaderboardEntry@> &tmpArray) {
    if (showMedal) {
        if ((medalTime != 0) && (medalTime < currentPbEntry.time || currentPbEntry.time == -1)) {
            auto position = GetSpecificPositionEntry(medalTime);
            position.desc = desc;
            position.entryType = EnumLeaderboardEntryType::MEDAL;
            position.positionData = positionData;
            if (isAValidMedalTime(position)) {
                tmpArray.InsertLast(position);
            }
        }
    }
}

void TryAddMedalPosition(bool showMedal, int medalTime, const string &in desc, PositionData &positionData, array<LeaderboardEntry@> &tmpArray) {
    try 
    {
        AddMedalPosition(showMedal, medalTime, desc, positionData, tmpArray);
    }
    catch
    {
        warn("Something went wrong while trying to add the " + desc + " medal position. Skipping it.");
        warn("Error message : " + getExceptionInfo());
    }
}