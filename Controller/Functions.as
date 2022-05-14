// ############################## FUNCTIONS #############################

//Since this plugin request the leaderboard, we need to check if the user's current subscription has those permissions
bool UserCanUseThePlugin(){
    return (Permissions::ViewRecords());
}

string GetIconForPosition(int position){
    if(position == 1){
        return podiumIcon[0];
    }else if(position > 1 && position <= 10){
        return podiumIcon[1];
    }else if(position > 10 && position <= 100){
        return podiumIcon[2];
    }else if(position > 100 && position <= 1000){
        return podiumIcon[3];
    }else if(position > 1000 && position <= 10000){
        return podiumIcon[4];
    }else{
        return "";
    }
}


Json::Value FetchEndpoint(const string &in route) {
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }
    auto req = NadeoServices::Get("NadeoLiveServices", route);
    req.Start();
    while(!req.Finished()) {
        yield();
    }
    return Json::Parse(req.String());
}

Net::HttpRequest@ GetTMIO(const string &in url)
{
    auto ret = Net::HttpRequest();
    ret.Method = Net::HttpMethod::Get;
    ret.Url = url;
    ret.Start();
    return ret;
}

Json::Value GetTMIOAsync(const string &in url)
{
    print(url);
    auto req = GetTMIO(url);
    while (!req.Finished()) {
        yield();
    }
    print(req.ResponseCode());
    return Json::Parse(req.String());
}




string TimeString(int scoreTime, bool showSign = false) {
    string timeString = "";
    if(showSign){
        if(scoreTime < 0){
            timeString += "-";
        }else{
            timeString += "+";
        }
    }

    timeString += Time::Format(Math::Abs(scoreTime));

    return timeString;
}

bool MapHasNadeoLeaderboard(string mapId){
    auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/map/" + mapId);

    return info.GetType() == Json::Type::Object;
}

int GetTimeWithOffset(float offset = 0) {

    if(!validMap){
        return -1;
    }

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
                    return infoTop;
                }
            }
        }
    }

    return -1;
}

CutoffTime@ GetPersonalBest() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    CutoffTime@ pbTimeTmp = CutoffTime();
    pbTimeTmp.time = -1;
    pbTimeTmp.position = -1;
    pbTimeTmp.pb = true;
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

// Return the position of a given time. You still need to check if the time is valid (i.e. if it's different from the top 1, or from the PB)
CutoffTime@ GetSpecificTimePosition(int time) {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    CutoffTime@ pbTimeTmp = CutoffTime();
    pbTimeTmp.time = -1;
    pbTimeTmp.position = -1;
    pbTimeTmp.pb = false;

    if(!validMap){
        return pbTimeTmp;
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
                    pbTimeTmp.time = top[0]["score"];
                    pbTimeTmp.position = top[0]["position"];
                }
            }
        }
    }

    return pbTimeTmp;
}


int GetTotalPlayers() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if(!validMap){
        return -1;
    }

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;

        auto info = GetTMIOAsync("https://trackmania.io" + "/api/leaderboard/map/" + mapid);
        if(info.GetType() != Json::Type::Null) {
            return info["playercount"];
        }
    }
    return -1;
}

bool isAValidMedalTime(CutoffTime@ time) {
    if(time.position == -1 && time.time == -1) {
        return false;
    }

    if(time.position == currentPbPosition && time.time == currentPbTime) {
        return false;
    }

    // We consider that if the position is 0, it's either below the WR, or the WR is the only one with that medal
    if(time.position == 0) {
        return false;
    }

    return true;
}


void AddMedalsPosition(uint totalPositions){

    if(!showMedals){
        return;
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
                auto atPosition = GetSpecificTimePosition(atTime);
                atPosition.desc = "AT";
                atPosition.percentage = ((100.0f * atPosition.position) / totalPositions);
                atPosition.isMedal = true;
                if(isAValidMedalTime(atPosition)) {
                    cutoffArrayTmp.InsertLast(atPosition);
                }
            }

        }

        if(showGold){
            if(goldTime < currentPbTime || currentPbTime == -1){
                auto goldPosition = GetSpecificTimePosition(goldTime);
                goldPosition.desc = "Gold";
                goldPosition.percentage = ((100.0f * goldPosition.position) / totalPositions);
                goldPosition.isMedal = true;
                if(isAValidMedalTime(goldPosition)) {
                    cutoffArrayTmp.InsertLast(goldPosition);
                }
            }
        }

        if(showSilver){
            if(silverTime < currentPbTime || currentPbTime == -1){
                auto silverPosition = GetSpecificTimePosition(silverTime);
                silverPosition.desc = "Silver";
                silverPosition.percentage = ((100.0f * silverPosition.position) / totalPositions);
                silverPosition.isMedal = true;
                if(isAValidMedalTime(silverPosition)) {
                    cutoffArrayTmp.InsertLast(silverPosition);
                }
            }
        }

        if(showBronze){
            if(bronzeTime < currentPbTime || currentPbTime == -1){
                auto bronzePosition = GetSpecificTimePosition(bronzeTime);
                bronzePosition.desc = "Bronze";
                bronzePosition.percentage = ((100.0f * bronzePosition.position) / totalPositions);
                bronzePosition.isMedal = true;
                if(isAValidMedalTime(bronzePosition)) {
                    cutoffArrayTmp.InsertLast(bronzePosition);
                }
            }
        }

    }

}

array<float> GetPercentagesAbovePB(int targets, float pbPercent){
    float nearest = Math::Floor(pbPercent);
    if(pbPercent > 10){
        int nearestFive = Math::Floor(pbPercent / 5) * 5;
        int nearestTen = nearestFive - 5;
        return {nearest, nearestFive, nearestTen};
    }
    else if (pbPercent > 6){
        return {nearest, nearest - 1, 5};
    }
    else if (pbPercent > 3){
        return {nearest, nearest - 1, 1};
    }
    else if (pbPercent > 2){
        return {nearest, 1};
    }
    else {
        return {nearest};
    }
}

void UpdateTimes(){
    // We get the 1st, 10th, 100th and 1000th leaderboard time, as well as the personal best time
    cutoffArrayTmp = array<CutoffTime@>();

    int totalPlayers = GetTotalPlayers();

    auto personalBest = GetPersonalBest();
    personalBest.percentage = (100.0f * personalBest.position / totalPlayers);
    cutoffArrayTmp.InsertLast(personalBest);

    print(totalPlayers);

    for(uint i = 0; i< allPositionToGet.Length; i++){
        CutoffTime@ best = CutoffTime();
        best.time = -1;
        best.position = -1;
        best.pb = false;

        int position = allPositionToGet[i];
        int offset = position - 1;

        best.position = position;
        best.percentage = ((100.0f * position) / totalPlayers);

        best.time = GetTimeWithOffset(offset);

        if(best.time != -1){
            cutoffArrayTmp.InsertLast(best);
        }
    }

    if(addTargetRankings){
        int targetsToGet = 3;
        float pbPercentage = 100.0f * currentPbPosition / totalPlayers;
        array<float> extraPosPercentage = GetPercentagesAbovePB(3, pbPercentage);
        for(uint i = 0; i< extraPosPercentage.Length; i++){
            CutoffTime@ best = CutoffTime();
            best.time = -1;
            best.position = -1;
            best.pb = false;
            best.percentage = extraPosPercentage[i];

            int position = totalPlayers * extraPosPercentage[i] / 100;
            int offset = position - 1;

            best.position = position;

            best.time = GetTimeWithOffset(offset);

            if(best.time != -1){
                cutoffArrayTmp.InsertLast(best);
            }
        }
    }


    if(currentComboChoice == -1){
        timeDifferenceCutoff = cutoffArrayTmp[0];
    }else{
        timeDifferenceCutoff.time = -1;
        timeDifferenceCutoff.position = -1;
        timeDifferenceCutoff.pb = false;
        for(uint i = 1; i< cutoffArrayTmp.Length; i++){
            if(cutoffArrayTmp[i].position == currentComboChoice){
                timeDifferenceCutoff = cutoffArrayTmp[i];
                break;
            }
        }
    }

    AddMedalsPosition(totalPlayers);

    for(uint i = 0; i < cutoffArrayTmp.Length; i++){
        auto percentage = cutoffArrayTmp[i].percentage;
        if(percentage % 1 == 0) {
            cutoffArrayTmp[i].percentageDisplay = Text::Format("%.0f%%", percentage);
        }
        else {
            cutoffArrayTmp[i].percentageDisplay = Text::Format("%.02f%%", percentage);
        }
    }

    //sort the array
    cutoffArrayTmp.SortAsc();
    cutoffArray = cutoffArrayTmp;
}
