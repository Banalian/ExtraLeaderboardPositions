// ################
// ### Settings ###
// ################

[Setting category="Display Settings" name="Window visible" description="To move the windows, click and drag while the Openplanet overlay is visible."]
bool windowVisible = true;

[Setting category="Display Settings" name="Display mode" description="When should the overlay be displayed?"]
EnumDisplayMode displayMode = EnumDisplayMode::ALWAYS;

[Setting category="Display Settings" name="Show the plugin's name" description="Should the plugin's name be displayed?"]
bool showPluginName = true;

[Setting category="Display Settings" name="Show separator" description="Should the separator be displayed ? (only if the plugin's name is displayed)))"]
bool showSeparator = true;

[Setting hidden]
float hiddingSpeedSetting = 1.0f;

[Setting hidden name="Refresh timer (minutes)" description="The amount of time between automatic refreshes of the leaderboard. Must be over 0." min=1]
int refreshTimer = 5;

[Setting hidden]
bool showPb = true;

[Setting hidden]
EnumDisplayPersonalBest personalBestDisplayMode = EnumDisplayPersonalBest::IN_GREEN;

[Setting hidden]
bool showMapName = false;

[Setting hidden]
bool showMapAuthor = false;

[Setting hidden]
int nbSizePositionToGetArray = 1;

[Setting hidden]
string allFriendsToGetStringSave = "";
// unsaved counterpart allFriendsToGet is in the data file;

[Setting hidden]
string allFriendsNameStringSave = "";
// unsaved counterpart allFriendsName is in the data file;

[Setting hidden]
bool showTimeDifference = true;

[Setting hidden]
bool showColoredTimeDifference = true;

[Setting hidden]
bool inverseTimeDiffSign = false;
