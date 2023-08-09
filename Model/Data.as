// File containing all constants and global variables

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

const array<string> loadingSteps = {
    Icons::Kenney::MoveBr,
    Icons::Kenney::MoveBt,
    Icons::Kenney::MoveRt,
    Icons::Kenney::MoveLr,
    Icons::Kenney::MoveLt,
    Icons::Kenney::MoveBtAlt,
    Icons::Kenney::MoveLb,
    Icons::Kenney::MoveLrAlt
};

uint currentLoadingStep = 0;

float loadingStepTimer = 0;

float loadingStepDuration = 25;

const string podiumIconBlue = "\\$36b" + Icons::Kenney::PodiumAlt + resetColor; // blue icon

const string playerIconGrey = "\\$888" + Icons::User + resetColor; // grey icon

const string refreshIconWhite = "\\$fff" + Icons::Refresh + resetColor; // white icon

const string warningIcon = "\\$f00" + Icons::ExclamationTriangle + resetColor; // red icon

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

float timerOPConfig = 0;
float updateFrequencyOPConfig = 5*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshOPConfig = false;

//also a setting, but can't be saved, allPositionToGetStringSave is the saved counterpart
array<int> allPositionToGet = {};


array<LeaderboardEntry@> leaderboardArray;
array<LeaderboardEntry@> leaderboardArrayTmp;
LeaderboardEntry@ timeDifferenceEntry = LeaderboardEntry();

int playerCount = -1;

int currentPbTime = -1;
int currentPbPosition = -1;

float timerStartDelay = 30 *1000; // 30 seconds
bool startupEnded = false;

bool validMap = false;

//variables to check that we aren't currently in a "failed request" (server not responding or not updating the pb) to not spam the server
int counterTries = 0;
int maxTries = 10;
bool failedRefresh = false;