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
 * Format the time for logging with both integer value and readable string representation
 */
string TimeLogString(int time) {
    if (time >= 0)
        return time + " [" + Time::Format(time) + "]";
    else
        return time + "";
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
        if((timePbLocal < currentPbEntry.time && currentMode == EnumCurrentMode::RACE) || (timePbLocal > currentPbEntry.time && currentMode == EnumCurrentMode::STUNT)){
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


string Vec3ColorToString(const vec3 &in color){
    return Text::FormatOpenplanetColor(color);
}

vec3 StringToVec3Color(const string &in color){
    //take the last 3 characters of the string (value between 0 and F for each char)
    //and convert them to a float between 0 and 1
    uint length = color.Length;
    if(length < 3){
        return vec3();
    }
    const string r = color.SubStr(length - 3, 1);
    const string g = color.SubStr(length - 2, 1);
    const string b = color.SubStr(length - 1, 1);
    return vec3(
        Text::ParseUInt(r, 16),
        Text::ParseUInt(g, 16),
        Text::ParseUInt(b, 16)
    ) / 15.0f;
}

/**
 * Check if the player is idle or not, based on the speed and the time since the last movement
 */
bool IsIdle(){
    auto state = VehicleState::ViewingPlayerState();
    if(state is null) return false;

    uint64 now = Time::get_Now();

    float currentSpeed = state.WorldVel.Length() * 3.6;
    if(currentSpeed >= hiddingSpeedSetting) {
        lastMovement = now;
        return false;
    }

    return now - lastMovement > unhideDelay;
}