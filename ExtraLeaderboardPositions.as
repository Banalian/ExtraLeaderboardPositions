// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

[Setting hidden name="Refresh timer (minutes)" description="The amount of time between automatic refreshes of the leaderboard. Must be over 0." min=1]
int refreshTimer = 5;


[Setting hidden]
int nbSizePositionToGetArray = 1;

[Setting hidden]
string allPositionToGetStringSave = "";

//also a setting, but can't be saved, allPositionToGetStringSave is the saved counterpart
array<string> allPositionToGet = {};

[SettingsTab name="Customization"]
void RenderSettingsCustomization(){
    UI::Text("Timer");

    refreshTimer = UI::InputInt("Refresh timer every X (minutes)", refreshTimer);

    UI::Text("Positions customizations");

    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allPositionToGet[i] = UI::InputText("Position " + (i+1), allPositionToGet[i]);
    }


    if(UI::Button("+ : Add a position")){
        nbSizePositionToGetArray++;
        allPositionToGet.InsertLast("");
    }
    if(UI::Button("- : Remove a position")){
        if(nbSizePositionToGetArray > 1){
            nbSizePositionToGetArray--;
            allPositionToGet.RemoveAt(nbSizePositionToGetArray);
        }
    }
}

// #######################
// ### Consts and vars ###
// #######################

const array<string> podiumIcon = {
    "\\$071" + Icons::Kenney::PodiumAlt, // 1st : green
    "\\$db4" + Icons::Kenney::PodiumAlt, // 10th and below : gold
    "\\$899" + Icons::Kenney::PodiumAlt, // 100th and below : silver
    "\\$964" + Icons::Kenney::PodiumAlt, // 1000th and below : bronze
	"\\$444" + Icons::Kenney::PodiumAlt, // 10000th and below : grey
    ""                                   // above 10k : No icon
};

const string resetColor = "\\$z";

const string pluginName = "Extra Leaderboard positions";

string currentMapUid = "";

float timer = 0;
float updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshPosition = false;



// Class used to store the data of a position in the leaderboard
class CutoffTime{

    // the time of the player
    int time;

    // the position of the player in the leaderboard
    int position;

    // true if it's a personal best, false otherwise
    bool pb = false;

    // Comparaison operator
    int opCmp(CutoffTime@ other){
        return position - other.position;
    }
}


array<CutoffTime@> cutoffArray;
int currentPbTime = -1;

// ############################## SETTINGS #############################

void OnSettingsChanged(){
    if(refreshTimer < 1){
        refreshTimer = 1;
    }
    updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
}

void OnSettingsSave(Settings::Section& section){
    section.SetInt("refreshTimer", refreshTimer);

    //save the array in the string
    allPositionToGetStringSave = "";
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allPositionToGetStringSave += allPositionToGet[i];
        if(i < nbSizePositionToGetArray - 1){
            allPositionToGetStringSave += ",";
        }
    }
    section.SetString("allPositionToGetStringSave", allPositionToGetStringSave);
}

void OnSettingsLoad(Settings::Section& section){
    refreshTimer = section.GetInt("refreshTimer");

    //load the array from the string
    allPositionToGetStringSave = section.GetString("allPositionToGetStringSave");

    if(allPositionToGetStringSave != ""){
        array<string> allPositionToGetTmp = allPositionToGetStringSave.Split(",");
        nbSizePositionToGetArray = allPositionToGetTmp.Length;

        for(int i = 0; i < nbSizePositionToGetArray; i++){
            allPositionToGet.InsertLast(allPositionToGetTmp[i]);
        }
    }else{
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
        allPositionToGet.InsertLast("1");
        allPositionToGet.InsertLast("10");
        allPositionToGet.InsertLast("100");
        allPositionToGet.InsertLast("1000");
        allPositionToGet.InsertLast("10000");
    }

    


    OnSettingsChanged();
}


// ############################## MENU #############################

void RenderMenu() {
    if (UI::MenuItem(pluginName)) {
        windowVisible = !windowVisible;
    }
}


// ############################## WINDOW RENDER #############################

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
        while(i < int(cutoffArray.Length)){
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

// ############################## TICK UPDATE #############################

void Update(float dt) {

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    
    //check if we're in a map
    if(app.CurrentPlayground !is null && network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        bool mapIdChanged = currentMapUid != app.RootMap.MapInfo.MapUid;
        auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;

        //get the current map pb
        int timePbLocal = scoreMgr.Map_GetRecord_v2(network.PlayerInfo.Id, app.RootMap.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
		
        // if the map change, or the timer is over or a new pb is found, we refresh the positions
        if (mapIdChanged || timer > updateFrequency || timePbLocal != currentPbTime) {
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


// ############################## FUNCTIONS #############################

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
    CutoffTime@ best = CutoffTime();
    best.time = -1;
    best.position = -1;
    best.pb = true;

    //check that we're in a map
    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
        
        auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/leaderboard/group/Personal_Best/map/"+mapid+"/surround/0/0?onlyWorld=true");
    
        if(info.GetType() != Json::Type::Null) {
            auto tops = info["tops"];
            if(tops.GetType() == Json::Type::Array) {
                auto top = tops[0]["top"];
                if(top.Length > 0) {
                    best.time = top[0]["score"];
                    currentPbTime = best.time;
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
            //We reached the end of the leaderboard
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


// ############################## MAIN #############################


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
