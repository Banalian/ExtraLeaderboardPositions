// File containing all constants and global variables

const array<string> invalidGamemodes = {
    "TM_Royal_Online",
    "TM_RoyalTimeAttack_Online",
    "TM_RoyalTimeAttack_Local",
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
    "Custom", // Custom icon
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
 * Don't forget to change the named counterparts if you change the order of the colors
 */
array<string> possibleColors = {
    "Custom", // Custom color
    "\\$071", // AT green
    "\\$db4", // gold
    "\\$899", // silver
    "\\$964", // bronze
    "\\$444", // grey
    "\\$777", // bright grey
    "\\$888", // grey (used for the leaderboard rows)
    "\\$aaa", // another bright grey (used for the map author)
    "\\$77f", // blue
    "\\$9f9", // PB green
    "\\$f77", // red
    "\\$fff"  // white
};

// named counterparts for the possibleColors array (for easier reference in the code)
const string resetColor = "\\$z";
const string atGreenColor = possibleColors[1];
const string goldColor = possibleColors[2];
const string silverColor = possibleColors[3];
const string bronzeColor = possibleColors[4];
const string greyColor1 = possibleColors[5];
const string greyColor2 = possibleColors[6];
const string greyColor3 = possibleColors[7];
const string greyColor4 = possibleColors[8];
const string blueColor = possibleColors[9];
const string pbGreenColor = possibleColors[10];
const string redColor = possibleColors[11];
const string whiteColor = possibleColors[12];
#if DEPENDENCY_CHAMPIONMEDALS
string championColor = "";
#endif
#if DEPENDENCY_WARRIORMEDALS
string warriorColor = "";
#endif



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

const string playerIconGrey = greyColor3 + Icons::User + resetColor; // grey icon

const string refreshIconWhite = whiteColor + Icons::Refresh + resetColor; // white icon

const string warningIcon = "\\$f00" + Icons::ExclamationTriangle + resetColor; // red icon

const string pluginName = "Extra Leaderboard Positions";

string currentMapUid = "";

float timer = 0;
float updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshPosition = false;

float timerOPConfig = 0;
float updateFrequencyOPConfig = 5*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshOPConfig = false;

array<PositionData> allPositionData = {};

// all data to save, counterparts are in the settings file
PositionData currentPbPositionData = PositionData(0, pbGreenColor, Icons::User, pbGreenColor);
PositionData atPositionData = PositionData(0, atGreenColor, Icons::Circle, greyColor3);
PositionData goldPositionData = PositionData(0, goldColor, Icons::Circle, greyColor3);
PositionData silverPositionData = PositionData(0, silverColor, Icons::Circle, greyColor3);
PositionData bronzePositionData = PositionData(0, bronzeColor, Icons::Circle, greyColor3);
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
PositionData sbVillePositionData = PositionData(0, greyColor1, Icons::Circle, greyColor3);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
PositionData championMedalPositionData = PositionData(0, championColor, Icons::Circle, greyColor3);
#endif
#if DEPENDENCY_WARRIORMEDALS
PositionData warriorMedalPositionData = PositionData(0, warriorColor, Icons::Circle, greyColor3);
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

// hopefully temporary, until there's an API change to the surround endpoint.
bool forceRefreshAfterSurroundFail = false;
