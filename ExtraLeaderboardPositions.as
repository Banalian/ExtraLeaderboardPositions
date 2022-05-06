// #######################
// ### Consts and vars ###
// #######################


enum EnumDisplayMode
{
    ALWAYS,
    ALWAYS_EXCEPT_IF_HIDDEN_INTERFACE,
    ONLY_IF_OPENPLANET_MENU_IS_OPEN,
    HIDE_WHEN_DRIVING
};

enum EnumDisplayMedal
{
    NORMAL,
    IN_GREY
};


const array<string> podiumIcon = {
    "\\$071" + Icons::Kenney::PodiumAlt, // 1st : green
    "\\$db4" + Icons::Kenney::PodiumAlt, // 10th and below : gold
    "\\$899" + Icons::Kenney::PodiumAlt, // 100th and below : silver
    "\\$964" + Icons::Kenney::PodiumAlt, // 1000th and below : bronze
	"\\$444" + Icons::Kenney::PodiumAlt, // 10000th and below : grey
    ""                                   // above 10k : No icon
};

const string podiumIconBlue = "\\$36b" + Icons::Kenney::PodiumAlt + resetColor; // blue icon

const string resetColor = "\\$z";
const string blueColor = "\\$77f";
const string redColor = "\\$f77";
const string greyColor = "\\$888";

const string pluginName = "Extra Leaderboard positions";

string currentMapUid = "";

float timer = 0;
float updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshPosition = false;

//also a setting, but can't be saved, allPositionToGetStringSave is the saved counterpart
array<int> allPositionToGet = {};


array<CutoffTime@> cutoffArray;
array<CutoffTime@> cutoffArrayTmp;
CutoffTime@ timeDifferenceCutoff = CutoffTime();
int currentPbTime = -1;
int currentPbPosition = -1;

float timerStartDelay = 30 *1000; // 30 seconds
bool startupEnded = false;

bool validMap = false;

// ############################## MAIN #############################


void Main(){
#if TMNEXT

    if(!UserCanUseThePlugin()){
        print("Waiting 30 more seconds for permissions...");
        while(timerStartDelay > 0){
            yield();
        }
        if(!UserCanUseThePlugin()){
            warn("You currently don't have the permissions to use this plugin, you at least need the standard edition");
            warn("If you do have the permissions, the plugin checks every 30 seconds and should work when you finished loading into the main menu");
            timerStartDelay = 30 *1000;
            while(true){
                yield();
                if(timerStartDelay < 0){
                    if(UserCanUseThePlugin()){
                        break;
                    }
                    timerStartDelay = 30 *1000;
                }
            }
        }
        print("Permission granted!");
    }
    startupEnded = true;
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
            //check that we're in a map
            if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
                string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
                if(MapHasNadeoLeaderboard(mapid)){
                    validMap = true;
                    UpdateTimes();
                }else{
                    validMap = false;
                    if(cutoffArray.Length > 0){
                        cutoffArray = array<CutoffTime@>();
                    }
                }
            }
            refreshPosition = false;
        }
        yield();

    }

#endif
}
