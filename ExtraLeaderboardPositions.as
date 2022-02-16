// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

[Setting hidden name="Refresh timer (minutes)" description="The amount of time between automatic refreshes of the leaderboard. Must be over 0." min=1]
int refreshTimer = 5;

[Setting hidden]
bool showPb = true;

[Setting hidden]
int nbSizePositionToGetArray = 1;

[Setting hidden]
string allPositionToGetStringSave = "";

//also a setting, but can't be saved, allPositionToGetStringSave is the saved counterpart
array<int> allPositionToGet = {};

[Setting hidden]
bool showTimeDifference = true;

[Setting hidden]
bool inverseTimeDiffSign = false;

[Setting hidden]
int currentComboChoice = -1;

[SettingsTab name="Customization"]
void RenderSettingsCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You need at least the standard edition.");
        return;
    }


    UI::Text("\tTimer");

    refreshTimer = UI::InputInt("Refresh timer every X (minutes)", refreshTimer);

    UI::Text("\n\tPersonal best");

    showPb = UI::Checkbox("Show personal best", showPb);

    UI::Text("\tTime difference");
    showTimeDifference = UI::Checkbox("Show time difference", showTimeDifference);
    if(showTimeDifference){
        inverseTimeDiffSign = UI::Checkbox("Inverse sign (+ instead of -)", inverseTimeDiffSign);

        UI::Text("\t\tFrom which position should the time difference be shown?");
        string comboText = "";
        if(currentComboChoice == -1){
            comboText = "Personal best";
        }else{
            comboText = "Position " + currentComboChoice;
        }

        if(UI::BeginCombo("Time Diff position", comboText)){
            if(UI::Selectable("Personal best", currentComboChoice == -1)){
                currentComboChoice = -1;
                UI::SetItemDefaultFocus();
            }
            for(int i = 0; i < int(allPositionToGet.Length); i++){
                string text = "Position " + allPositionToGet[i];
                if(UI::Selectable(text, currentComboChoice == allPositionToGet[i])){
                    currentComboChoice = allPositionToGet[i];
                }
            }
            UI::EndCombo();
        }
            

    }
    

    UI::Text("\n\tPositions customizations");

    UI::Text("It will update the UI when the usual conditions are met (see Explanation).");

    if(UI::Button("Reset to default")){
        allPositionToGet = {1,10,100,1000,10000};
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
    }

    for(int i = 0; i < nbSizePositionToGetArray; i++){
        int tmp = UI::InputInt("Custom position " + (i+1), allPositionToGet[i]);
        if(tmp != allPositionToGet[i]){
            if(currentComboChoice == allPositionToGet[i]){
                currentComboChoice = tmp;
            }
            allPositionToGet[i] = tmp;
            OnSettingsChanged();
        }
    }


    if(UI::Button("+ : Add a position")){
        nbSizePositionToGetArray++;
        allPositionToGet.InsertLast(1);
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a position")){
        if(nbSizePositionToGetArray > 1){
            nbSizePositionToGetArray--;
            allPositionToGet.RemoveAt(nbSizePositionToGetArray);
            OnSettingsChanged();
        }
    }
}

[SettingsTab name="Explanation"]
void RenderSettingsExplanation(){
    UI::Text("This plugin allows you to see more leaderbaord position.\n\n");
    UI::Text("You can modify the positions in the \"Customization tab\"\n");
    UI::Text("The leaderboard is refreshed every " + refreshTimer + " minutes when in a map.");
    UI::Text("This timer resets when you leave the map.");
    UI::Text("It is also automatically refreshed when you join a map, or if you set a new pb on a map.");
    UI::Dummy(vec2(0,150));
    UI::Text("Made by Banalian.\nContact me on Discord (you can find me on the OpenPlanet Discord) if you have any questions or suggestions !\nYou can also use the github page to post about any issue you might encounter.");
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
CutoffTime@ pbTime = CutoffTime();
CutoffTime@ timeDifferenceCutoff = CutoffTime();
int currentPbTime = -1;

// ############################## SETTINGS CALLBACKS #############################

void OnSettingsChanged(){
    if(refreshTimer < 1){
        refreshTimer = 1;
    }
    updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
    
    bool foundCombo = false;
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        if(allPositionToGet[i] < 1){
            allPositionToGet[i] = 1;
        }

        if(allPositionToGet[i] == currentComboChoice){
            if(currentComboChoice < 1 && currentComboChoice != -1){
                currentComboChoice = 1;
            }

            if(currentComboChoice > 10000){
                currentComboChoice = 10000;
            }

            foundCombo = true;
        }

        if(allPositionToGet[i] > 10000){
            allPositionToGet[i] = 10000;
        } 
    }

    if(!foundCombo){
        currentComboChoice = -1;
    }

}

void OnSettingsSave(Settings::Section& section){
    //save the array in the string
    allPositionToGetStringSave = "";
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allPositionToGetStringSave += "" + allPositionToGet[i];
        if(i < nbSizePositionToGetArray - 1){
            allPositionToGetStringSave += ",";
        }
    }
    section.SetString("allPositionToGetStringSave", allPositionToGetStringSave);
}

void OnSettingsLoad(Settings::Section& section){
    //load the array from the string
    allPositionToGetStringSave = section.GetString("allPositionToGetStringSave");

    if(allPositionToGetStringSave != ""){
        array<string> allPositionToGetTmp = allPositionToGetStringSave.Split(",");
        nbSizePositionToGetArray = allPositionToGetTmp.Length;

        for(int i = 0; i < nbSizePositionToGetArray; i++){
            allPositionToGet.InsertLast(Text::ParseInt(allPositionToGetTmp[i]));
        }

    }else{
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
        allPositionToGet.InsertLast(1);
        allPositionToGet.InsertLast(10);
        allPositionToGet.InsertLast(100);
        allPositionToGet.InsertLast(1000);
        allPositionToGet.InsertLast(10000);
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

    if(!UserCanUseThePlugin()){
        warn("You don't have the permissions to use this plugin, you at least need the standard edition");
        return;
    }


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
        
        UI::BeginTable("Main", 5);        

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::TableNextColumn();
        UI::Text("Position");
        UI::TableNextColumn();
        UI::Text("Time");

        int i = 0;
        while(i < int(cutoffArray.Length)){
            //We skip the pb if there's none
            if( (cutoffArray[i].pb && cutoffArray[i].time == -1) || (!showPb && cutoffArray[i].pb) ){
                i++;
                continue;
            }

            //------------POSITION ICON--------
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(GetIconForPosition(cutoffArray[i].position));
            
            //------------POSITION-------------
            UI::TableNextColumn();
            if(cutoffArray[i].position > 10000){
                UI::Text("<" + cutoffArray[i].position);
            }else{
                UI::Text(""+ cutoffArray[i].position);
            }
            
            //------------TIME-----------------
            UI::TableNextColumn();
            UI::Text(TimeString(cutoffArray[i].time));

            //------------IS PB----------------
            UI::TableNextColumn();
            if(cutoffArray[i].pb){
                UI::Text("PB");
            }
            
            //------------TIME DIFFERENCE------
            UI::TableNextColumn();

            if(showTimeDifference){
                if(cutoffArray[i].time == -1 || timeDifferenceCutoff.time == -1){
                    //Nothing here, no time to compare to
                }else if(cutoffArray[i].position == timeDifferenceCutoff.position){
                    //Nothing here, the position is the same, it's the same time
                    //still keeping the if in case we want to print/add something here
                }else{
                    int timeDifference = cutoffArray[i].time - timeDifferenceCutoff.time;
                    if(inverseTimeDiffSign){
                        if(timeDifference < 0){
                            UI::Text("+" + TimeString(Math::Abs(timeDifference)));
                        }else{
                            UI::Text("-" + TimeString(timeDifference));
                        }
                    }else{
                        if(timeDifference < 0){
                            UI::Text("-" + TimeString(Math::Abs(timeDifference)));
                        }else{
                            UI::Text("+" + TimeString(timeDifference));
                        }
                    }
                }

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
        currentMapUid = "";
    }
    
}


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
    CutoffTime@ pbTimeTmp = CutoffTime();
    pbTimeTmp.time = -1;
    pbTimeTmp.position = -1;
    pbTimeTmp.pb = true;

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
                    currentPbTime = pbTimeTmp.time;
                    pbTimeTmp.position = top[0]["position"];
                }
            }
        }
    }

    return pbTimeTmp;
}


void UpdateTimes(){
    // We get the 1st, 10th, 100th and 1000th leaderboard time, as well as the personal best time
    array<CutoffTime@> cutoffArrayTmp;

    cutoffArrayTmp.InsertLast(GetPersonalBest());

    for(uint i = 0; i< allPositionToGet.Length; i++){
        CutoffTime@ best = CutoffTime();
        best.time = -1;
        best.position = -1;
        best.pb = false;

        int position = allPositionToGet[i];
        int offset = position - 1;

        best.position = position;

        best.time = GetTimeWithOffset(offset);

        if(best.time != -1){
            cutoffArrayTmp.InsertLast(best);
        }
    }

    pbTime = cutoffArrayTmp[0];
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
    //sort the array
    cutoffArrayTmp.SortAsc();
    cutoffArray = cutoffArrayTmp;
}


// ############################## MAIN #############################


void Main(){
#if TMNEXT

    if(!UserCanUseThePlugin()){
        warn("You don't have the permissions to use this plugin, you at least need the standard edition");
        return;
    }

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
            UpdateTimes();
            refreshPosition = false;
        }
        yield();

    }

#endif
}
