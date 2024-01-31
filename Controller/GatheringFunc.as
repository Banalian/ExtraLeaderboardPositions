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

        auto info = FetchLiveEndpoint(NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?onlyWorld=true");

        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    pbTimeTmp.time = top[0]["score"];
                    pbTimeTmp.position = top[0]["position"];
                }
            }
        }
    }

    return pbTimeTmp;
}


/**
 * Return the leaderboard entry of a given position
 */
array<LeaderboardEntry@> GetFriendsEntry(string friends) {
    array<LeaderboardEntry@> positionsEntry;
    if(!validMap || friends == ""){
        return positionsEntry;
    }

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
		string mapid = currentMapId;//network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapId;
        auto info = FetchEndpoint("https://prod.trackmania.core.nadeo.online/mapRecords/?accountIdList=" + friends + "&mapIdList=" + mapid);
		trace(friends);
        if(info.GetType() != Json::Type::Null) {
			trace(info.Length);
			for(uint i = 0; i < info.Length; i++){
				LeaderboardEntry@ positionEntry = LeaderboardEntry();
				auto friend = info[i];
				auto infoTop = friend["recordScore"];
				positionEntry.time = infoTop["time"];
				positionEntry.position = i+1;
				positionEntry.id = friend["accountId"];
				for(uint j = 0; j < allFriendsToGet.Length; j++){
					if(allFriendsToGet[j] == friend["accountId"]){
						positionEntry.name = allFriendsName[j];
						break;
					}
				}
				positionEntry.entryType = EnumLeaderboardEntryType::POSITION;
				positionsEntry.InsertLast(positionEntry);
			}
        }
    }

    return positionsEntry;
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

        auto info = FetchLiveEndpoint(NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?score="+time+"&onlyWorld=true");

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