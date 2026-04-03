// File containing all constants and global variables

const array<string> invalidGamemodes = {
    "TM_Royal_Online",
    "TM_RoyalTimeAttack_Online",
    "TM_RoyalTimeAttack_Local",
    "TM_RoyalValidation_Local"
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
 */
dictionary possibleColors = {
    {"Custom", ""}, // Custom color
    {"AT Green", "\\$071"}, // AT green
    {"Gold", "\\$db4"}, // gold
    {"Silver", "\\$899"}, // silver
    {"Bronze", "\\$964"}, // bronze
    {"Dark Grey", "\\$444"}, // grey
    {"Grey", "\\$777"}, // bright grey
    {"Bright Grey", "\\$888"}, // grey (used for the leaderboard rows)
    {"Brightest Grey", "\\$aaa"}, // another bright grey (used for the map author)
    {"Blue", "\\$77f"}, // blue
    {"PB Green", "\\$9f9"}, // PB green
    {"Red", "\\$f77"}, // red
    {"White", "\\$fff"} // white
#if DEPENDENCY_CHAMPIONMEDALS
    , {"Champion", "\\$f47"} // champion medal color
#endif
#if DEPENDENCY_WARRIORMEDALS
    , {"Warrior", "\\$000"} // warrior medal color, black since I don't know the color at compile time
#endif
};

// named counterparts for the possibleColors array (for easier reference in the code)
const string resetColor = "\\$z";
const string atGreenColor = string(possibleColors["AT Green"]);
const string goldColor = string(possibleColors["Gold"]);
const string silverColor = string(possibleColors["Silver"]);
const string bronzeColor = string(possibleColors["Bronze"]);
const string greyColor1 = string(possibleColors["Dark Grey"]);
const string greyColor2 = string(possibleColors["Grey"]);
const string greyColor3 = string(possibleColors["Bright Grey"]);
const string greyColor4 = string(possibleColors["Brightest Grey"]);
const string blueColor = string(possibleColors["Blue"]);
const string pbGreenColor = string(possibleColors["PB Green"]);
const string redColor = string(possibleColors["Red"]);
const string whiteColor = string(possibleColors["White"]);
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
float updateFrequencyOPConfig = 30*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second
bool refreshOPConfig = false;

array<PositionData> allPositionData = {};
array<PositionData> allClubData = {};

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
PositionData championMedalPositionData = PositionData(0, "\\$f47", Icons::Circle, greyColor3);
#endif
#if DEPENDENCY_WARRIORMEDALS
PositionData warriorMedalPositionData = PositionData(0, "\\$3CF", Icons::Circle, greyColor3);
#endif
#if DEPENDENCY_S314KEMEDALS
PositionData s314keMedalPositionData = PositionData(0, greyColor1, Icons::Circle, greyColor3);
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

// Last time the car was above the speed threshold
uint64 lastMovement = Time::get_Now();

float timerStartDelay = 30 *1000; // 30 seconds
bool startupEnded = false;

bool validMap = false;

//variables to check that we aren't currently in a "failed request" (server not responding or not updating the pb) to not spam the server
int maxTries = 10;
int retryTimeLimit = 10000;
bool failedRefresh = false;


EnumCurrentMode currentMode = EnumCurrentMode::INVALID;

bool forceRefreshAfterSurroundFail = false;