// File containing various unrelated functions that are general enough.

/**
 * Check if the current LeaderboardEntry is a valid medal time or not, for the "normal" mode if the user has a better time than the medal
 */
bool isAValidMedalTime(LeaderboardEntry@ time) {
    if(time.position == -1 && time.time == -1) {
        return false;
    }

    if(time.position == currentPbEntry.position && time.time == currentPbEntry.time) {
        return false;
    }

    // We consider that if the position is 0, it's either below the WR, or the WR is the only one with that medal
    if(time.position == 0) {
        return false;
    }

    return true;
}


/**
 * Check if the current map has a Nadeo leaderboard or not
 * 
 * Needs to be called from a yieldable function
 */
bool MapHasNadeoLeaderboard(const string &in mapId){
    auto info = FetchEndpoint(NadeoServices::BaseURLLive() + "/api/token/map/" + mapId);

    return info.GetType() == Json::Type::Object;
}

/**
 * Force a refresh of the leaderboard ( requested by the user )
 * also remove the "failed request" lock
 */
void ForceRefresh(){
    // don't interfere if refresh already running
    if (!refreshPosition) {
        timer = 0;
        failedRefresh = false;
        refreshPosition = true;
    }
}

/**
 * Check if the user can use the plugin or not, based on different conditions
 */
bool UserCanUseThePlugin(){
    //Since this plugin request the leaderboard, we need to check if the user's current subscription has those permissions
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


/**
 * Fetch an endpoint from the Nadeo Live Services
 * 
 * Needs to be called from a yieldable function
 */
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


/**
 * Format the time string in a readable format
 */
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

/**
 * Check if the new time is a new PB
 */
bool newPBSet(int timePbLocal) {
    if(!validMap){
        return false;
    }
    bool isLocalPbDifferent = timePbLocal != currentPbEntry.time;
    if(isLocalPbDifferent){
        if(timePbLocal == -1){
            return false;
        }
        if(currentPbEntry.time == -1){
            return true;
        }
        if(timePbLocal < currentPbEntry.time){
            return true;
        }else{
            return false;
        }
    }else{
        return false;
    }
}


/**
 * return the string representation of a number based on some settings like shorter numbers, etc
 */
string NumberToString(int number){
    string numberString = "";
    // explicit cast to int to avoid warning
    int shortenAboveInt = shortenAbove;

    if(number < shortenAboveInt || !shorterNumberRepresentation){
        numberString = "" + number;
    } else if(number < 1000000){
        numberString = "" + number / 1000 + "k";
    } else {
        numberString = "" + number / 1000000 + "M";
    }

    return numberString;
}