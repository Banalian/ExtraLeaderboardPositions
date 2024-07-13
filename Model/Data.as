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


/**
 * List of available icons for leaderboard customisation
 */
const array<string> possibleIcons = {
    Icons::Kenney::Podium,
    Icons::Kenney::PodiumAlt,
    Icons::Circle,
    Icons::Heart,
    Icons::Star,
    Icons::User,
    Icons::Trophy
};

/**
 * List of available colors for leaderboard customisation
 */
const array<string> possibleColors = {
    "\\$071", // AT green
    "\\$db4", // gold
    "\\$899", // silver
    "\\$964", // bronze
    "\\$444", // grey
    "\\$777", // bright grey
    "\\$77f", // blue
    "\\$9f9", // PB green
    "\\$f77", // red
    "\\$fff" // white
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
const string greenColor = "\\$9f9";

const string pluginName = "Extra Leaderboard Positions";

string currentMapUid = "";

float timer = 0;
float updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshPosition = false;

float timerOPConfig = 0;
float updateFrequencyOPConfig = 5*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshOPConfig = false;

//also a setting, but can't be saved, allPositionToGetStringSave is the saved counterpart
array<int> allPositionToGet = {};

array<PositionData> allPositionData = {};

// all data to save, counterparts are in the settings file
PositionData currentPbPosition = PositionData(0, possibleColors[7], Icons::User);
PositionData atPositionData = PositionData(0, possibleColors[0], Icons::Circle);
PositionData goldPositionData = PositionData(0, possibleColors[1], Icons::Circle);
PositionData silverPositionData = PositionData(0, possibleColors[2], Icons::Circle);
PositionData bronzePositionData = PositionData(0, possibleColors[3], Icons::Circle);
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
PositionData sbVillePositionData = PositionData(0, possibleColors[4], Icons::Circle);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
PositionData championMedalPositionData = PositionData(0, possibleColors[4], Icons::Circle);
#endif


array<LeaderboardEntry@> leaderboardArray;
array<LeaderboardEntry@> leaderboardArrayTmp;
LeaderboardEntry@ timeDifferenceEntry = LeaderboardEntry();

int playerCount = -1;

// Current local PB time, updated in Update() when new PB set.
int currentTimePbLocal = -1;

// PB entry we are currently displaying on the leaderboard.
// When new PB set, updated and displayed immediately with the new time and an empty position value.
// Position filled in later by API call.
LeaderboardEntry@ currentPbEntry = LeaderboardEntry();

float timerStartDelay = 30 *1000; // 30 seconds
bool startupEnded = false;

bool validMap = false;

//variables to check that we aren't currently in a "failed request" (server not responding or not updating the pb) to not spam the server
int maxTries = 10;
int retryTimeLimit = 10000;
bool failedRefresh = false;


EnumCurrentMode currentMode = EnumCurrentMode::INVALID;
