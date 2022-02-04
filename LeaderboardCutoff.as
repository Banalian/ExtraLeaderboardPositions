// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;


const array<string> medals = {
    "\\$071" + Icons::Trophy, // author trophy
    "\\$db4" + Icons::Trophy, // gold trophy
    "\\$899" + Icons::Trophy, // silver trophy
    "\\$964" + Icons::Trophy, // bronze trophy
	"\\$444" + Icons::Trophy, // no trophy	
};

const string resetColor = "\\$z";


class CutoffTime{

    int time;
    float position;

    void DrawText(){
        UI::Text("" + position + ": " + time);
    }
}


array<CutoffTime@> cutoffArray;


void RenderMenu() {
    if (UI::MenuItem("LeaderBoard Cutoff")) {
        print("You clicked me!!");
    }
}

void Render() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;

    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoInputs;
    }


    if(windowVisible && app.CurrentPlayground !is null){
        UI::Begin("Leaderboard Cutoff", windowFlags);

        UI::BeginGroup();

        UI::BeginTable("Main", 2);
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Cutoff");


        for(uint i = 0; i < cutoffArray.Length; i++){
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("" + cutoffArray[i].position);
            UI::TableNextColumn();
            UI::Text(TimeString(cutoffArray[i].time));
        }

        UI::EndTable();

        UI::EndGroup();

        UI::End();
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
        float offset = Math::Pow(10,i);
        CutoffTime@ cutoff = CutoffTime();
        cutoff.time = GetTimeWithOffset(offset-1);
        cutoff.position = offset;
        cutoffArray.InsertLast(cutoff);
    }

#endif
}
