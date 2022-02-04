// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;


const array<string> podiumIcon = {
    "\\$071" + Icons::Kenney::PodiumAlt, // author trophy
    "\\$db4" + Icons::Kenney::PodiumAlt, // gold trophy
    "\\$899" + Icons::Kenney::PodiumAlt, // silver trophy
    "\\$964" + Icons::Kenney::PodiumAlt, // bronze trophy
	"\\$444" + Icons::Kenney::PodiumAlt, // no trophy	
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

        UI::BeginTable("Main", 3);
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Cutoff");

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::TableNextColumn();
        UI::Text("Position");
        UI::TableNextColumn();
        UI::Text("Time");


        for(uint i = 0; i < cutoffArray.Length; i++){
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(podiumIcon[i]);
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
            auto top = info["tops"][0]["top"];
            if(top.Length > 0) {
                int infoTop = top[0]["score"];
                return infoTop;
            }
        }
    }

    return -1;
}


void updateTimes(){

    // We get the 1st, 10th, 100th and 1000th leaderboard time
    array<CutoffTime@> cutoffArrayTmp;
    int i = 0;
    bool continueLoop = true;

    while(continueLoop){
        float offset = Math::Pow(10,i);
        CutoffTime@ cutoff = CutoffTime();
        cutoff.time = GetTimeWithOffset(offset-1);
        cutoff.position = offset;
        if(cutoff.time != -1){
            cutoffArrayTmp.InsertLast(cutoff);
        }else{
            continueLoop = false;
        }
        if(i == 4){
            //we can't ask for the leadereboard above 10k so we stop.
            continueLoop = false;
        }
        i++;
    }
    cutoffArray = cutoffArrayTmp;
}

void Main(){
#if TMNEXT

    // Add the audiences you need
    NadeoServices::AddAudience("NadeoLiveServices");
 
    // Wait until the services are authenticated
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
      yield();
    }

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    string currentMapUid = "";

    while(true){
        if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
            
            
            if(currentMapUid == "")
            {
                currentMapUid = app.RootMap.MapInfo.MapUid;
                updateTimes();
            }
            else if(currentMapUid != app.RootMap.MapInfo.MapUid)
            {
                currentMapUid = app.RootMap.MapInfo.MapUid;
                updateTimes();

            }else{
                //we don't need to update the leaderboard
                yield();
            }
        }else{
            yield();
        }

    }

#endif
}
