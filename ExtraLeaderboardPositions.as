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

const array<string> invalidGamemodes = {
    "TM_Royal_Online",
    "TM_RoyalTimeAttack_Online",
    "TM_RoyalValidation_Local"
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
const string brightGreyColor = "\\$aaa";

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

//variables to check that we aren't currently in a "failed request" (server not responding or not updating the pb) to not spam the server
int counterTries = 0;
int maxTries = 10;
bool failedRefresh = false;

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

        // TODO : Rewrite this to remove all this nesting
        //if we're on a new map, the timer is over or a new pb has been made we update the times
        if(refreshPosition){
            //check that we're in a map
            if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){

                // check that we're not in an invalid gamemode
                auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(network.ServerInfo);
                string gamemode = ServerInfo.CurGameModeStr;

                if(invalidGamemodes.Find(gamemode) == -1){
                    //we don't want to update the times if we know the current refresh has already failed.
                    //This should not deadlock because other parts of the plugin will be able to unlock this
                    if(!failedRefresh){
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
                }else{
                    // temp solution
                    validMap = false;
                    if(cutoffArray.Length > 0){
                        cutoffArray = array<CutoffTime@>();
                    }
                }
                
                

            }else{
                if(cutoffArray.Length > 0){
                    cutoffArray = array<CutoffTime@>();
                }
            }
            refreshPosition = false;
        }
        yield();

    }

#endif
}
