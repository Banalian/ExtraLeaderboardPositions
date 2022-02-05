// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

const array<string> podiumIcon = {
    "\\$071" + Icons::Kenney::PodiumAlt, // 1st : green
    "\\$db4" + Icons::Kenney::PodiumAlt, // 10th and below : gold
    "\\$899" + Icons::Kenney::PodiumAlt, // 100th and below : silver
    "\\$964" + Icons::Kenney::PodiumAlt, // 1000th and below : bronze
	"\\$444" + Icons::Kenney::PodiumAlt, // 10000th and below : nothing	
};

const string resetColor = "\\$z";

const string pluginName = "Extra Leaderboard positions";

string currentMapUid = "";

float timer = 0;
float updateFrequency = 300*1000;
bool refreshPosition = false;




class CutoffTime{

    int time;
    int position;
    bool pb = false;

    int opCmp(CutoffTime@ other){
        return position - other.position;
    }
}


array<CutoffTime@> cutoffArray;


void RenderMenu() {
    if (UI::MenuItem(pluginName)) {
        windowVisible = !windowVisible;
    }
}

void Render() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;

    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoInputs;
    }

    if(cutoffArray.Length == 0){
        return;
    }

    //if this is true, we're probably on a map not uploaded to nadeo's server. we don't want to show the window
    if(cutoffArray.Length == 1 && cutoffArray[0].position == -1){
        return;
    }
        

    if(windowVisible && app.CurrentPlayground !is null){
        UI::Begin(pluginName, windowFlags);

        UI::BeginGroup();

        UI::Text("Extra leaderboard positions");
        
        UI::BeginTable("Main", 4);        

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::TableNextColumn();
        UI::Text("Position");
        UI::TableNextColumn();
        UI::Text("Time");

        int i = 0;
        int offsetPod = 0;
        while(i < cutoffArray.Length){
            //We skip the pb if there's none
            if(cutoffArray[i].pb && cutoffArray[i].time == -1){
                i++;
                offsetPod++;
                continue;
            }

            UI::TableNextRow();
            UI::TableNextColumn();

            //Make an offset for the podium icons so that the pb icon is the same as the one below it (or blank if there's nothing below it)
            if(cutoffArray[i].pb){
                offsetPod++;
                UI::Text(podiumIcon[i]);
            }else{
                UI::Text(podiumIcon[i-offsetPod]);
            }
            
            UI::TableNextColumn();
            if(cutoffArray[i].position > 10000){
                UI::Text("<" + cutoffArray[i].position);
            }else{
                UI::Text(""+ cutoffArray[i].position);
            }
            
            UI::TableNextColumn();
            UI::Text(TimeString(cutoffArray[i].time));

            //If it's the pb, display it
            if(cutoffArray[i].pb){
                UI::TableNextColumn();
                UI::Text("PB");
            }

            i++;
            
        }

        UI::EndTable();

        UI::EndGroup();

        UI::End();
    }
}

void Update(float dt) {

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if(app.CurrentPlayground !is null && network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        bool mapIdChanged = currentMapUid != app.RootMap.MapInfo.MapUid;
        if (mapIdChanged || timer > updateFrequency) {
            currentMapUid = app.RootMap.MapInfo.MapUid;
            refreshPosition = true;
            timer = 0;
        } else {
            timer += dt;
        }
    }else{
        timer = 0;
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


string TimeString(int scoreTime) {
    return Time::Format(scoreTime);
}

int GetTimeWithOffset(float offset = 0) {

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    auto server_info = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);

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
    CutoffTime@ best = CutoffTime();
    best.time = -1;
    best.position = -1;
    best.pb = true;

    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    best.time = top[0]["score"];
                    best.position = top[0]["position"];
                }
            }
        }
    }

    return best;
}


void updateTimes(){
    // We get the 1st, 10th, 100th and 1000th leaderboard time, as well as the personal best time
    array<CutoffTime@> cutoffArrayTmp;
    int i = 0;
    bool continueLoop = true;

    cutoffArrayTmp.InsertLast(GetPersonalBest());

    while(continueLoop){
        int offset = int(Math::Pow(10,i));
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

    //sort the array
    cutoffArrayTmp.SortAsc();

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

    while(true){

        //if we're on a new map or the timer is over, we update the times
        if(refreshPosition){
            updateTimes();
            refreshPosition = false;
        }
        yield();

    }

#endif
}
