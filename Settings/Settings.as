// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

[Setting category="Display Settings" name="Display mode" description="When should the overlay be displayed?"]
EnumDisplayMode displayMode = EnumDisplayMode::ALWAYS;

[Setting category="Display Settings" name="Show the plugin's name" description="Should the plugin's name be displayed?"]
bool showPluginName = true;

[Setting category="Display Settings" name="Show separator" description="Should the separator be displayed ? (only if the plugin's name is displayed)"]
bool showSeparator = true;

[Setting hidden]
float hiddingSpeedSetting = 1.0f;

[Setting hidden description="Time (milliseconds) before unhiding the overlay (only if Display Mode is set to HIDE_WHEN_DRIVING)"]
int unhideDelay = 500;

[Setting hidden name="Refresh timer (minutes)" description="The amount of time between automatic refreshes of the leaderboard. Must be over 0." min=1]
int refreshTimer = 5;

[Setting hidden]
bool showTableHeaders = true;

[Setting hidden]
bool showPb = true;

[Setting hidden]
bool showPercentage = false;

[Setting hidden]
bool showMedals = true;

[Setting hidden]
bool showMedalWhenBetter = true;

#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
[Setting hidden]
bool showSBVilleATMedal = true;
#endif
#if DEPENDENCY_CHAMPIONMEDALS
[Setting hidden]
bool showChampionMedals = true;
#endif
#if DEPENDENCY_WARRIORMEDALS
[Setting hidden]
bool showWarriorMedals = true;
#endif
#if DEPENDENCY_S314KEMEDALS
[Setting hidden]
bool showS314keMedals = true;
#endif
[Setting hidden]
bool showAT = true;
[Setting hidden]
bool showGold = true;
[Setting hidden]
bool showSilver = true;
[Setting hidden]
bool showBronze = true;

[Setting hidden]
bool showMapName = false;

[Setting hidden]
bool showMapAuthor = false;

[Setting hidden]
bool showRefreshButtonSetting = true;

[Setting hidden]
int nbSizePositionDataArray = 1;

[Setting hidden]
string allPositionDataStringSave = "";

// unsaved counterpart allPositionData is in the data file;

[Setting hidden]
string medalsPositionDataStringSave = "";

// unsaved counterparts variables are in the data file;

#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
[Setting hidden]
string sbVillePositionDataStringSave = "";
#endif

#if DEPENDENCY_CHAMPIONMEDALS
[Setting hidden]
string championMedalPositionDataStringSave = "";
#endif

#if DEPENDENCY_WARRIORMEDALS
[Setting hidden]
string warriorMedalPositionDataStringSave = "";
#endif

#if DEPENDENCY_S314KEMEDALS
[Setting hidden]
string s314keMedalPositionDataStringSave = "";
#endif

[Setting hidden]
bool showTimeDifference = true;

[Setting hidden]
bool showColoredTimeDifference = true;

[Setting hidden]
bool inverseTimeDiffSign = false;

[Setting hidden]
int currentComboChoice = -1;

[Setting hidden]
bool shorterNumberRepresentation = false;

[Setting hidden]
uint shortenAbove = 100000;

[Setting hidden]
bool useExternalAPI = false;

[Setting hidden]
bool showPlayerCount = true;

[Setting hidden]
string lastUsedPluginVersion = "";



// ----------------------------- DEPRECATED SETTINGS -----------------------------
// Can't be removed because they're needed for the migration process

[Setting hidden]
string allPositionToGetStringSave = "";

[Setting hidden]
EnumDisplayMedal medalDisplayMode = EnumDisplayMedal::NORMAL;

[Setting hidden]
EnumDisplayPersonalBest personalBestDisplayMode = EnumDisplayPersonalBest::IN_GREEN;