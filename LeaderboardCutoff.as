// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the table, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;


void RenderMenu()
{
    if (UI::MenuItem("LeaderBoard Cutoff")) {
        print("You clicked me!!");
    }
}


Json::Value FetchEndpoint(const string &in route) {
    auto req = NadeoServices::Get("NadeoLiveServices", route);
    req.Start();
    while(!req.Finished()) {
        yield();
    }
    return Json::Parse(req.String());
}


string TimeString(int scoreTime) {
    return Time::Format(scoreTime);
}

int GetTimeWithOffset(float offset = 0) {

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/top?length=1&offset="+offset+"&onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            int infoTop = info["tops"][0]["top"][0]["score"];
            return infoTop;
        }
        return -1;
    }

    return -1;
}

void Main(){
#if TMNEXT

    // Add the audiences you need
    NadeoServices::AddAudience("NadeoLiveServices");
 
    // Wait until the services are authenticated
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
      yield();
    }

    // We get the 1st, 10th, 100th and 1000th leaderboard time
    for(int i = 0; i < 4; i++) {

        float offset = Math::Pow(10,i)-1;
        print( (offset+1) + " Place has a time of : " + TimeString(GetTimeWithOffset(offset)));

    }

#endif
}
