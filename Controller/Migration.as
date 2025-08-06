// Contains all functions regarding migration of data from one version to another

void HandleMigration() {
    // extract major, minor and patch version from the lastUsedPluginVersion
    int major = 0;
    int minor = 0;
    int patch = 0;
    auto version = lastUsedPluginVersion.Split(".");
    if (version.Length > 0) {
        major = Text::ParseInt(version[0]);
    }
    if (version.Length > 1) {
        minor = Text::ParseInt(version[1]);
    }
    if (version.Length > 2) {
        patch = Text::ParseInt(version[2]);
    }

    bool migrationNeeded = false;

    // ---------- MIGRATION FROM * TO 2.6.0 ----------
    if (major < 2 || (major == 2 && minor < 6)) {
        UI::ShowNotification(pluginName, "Settings migration in progress (2.6.0)...");
        migrationNeeded = true;
        // migrate allPositionToGetStringSave to the new allPositionData structure
        // multiple changes required:
        // - extract data from allPositionToGetStringSave to transfer to allPositionData
        // - use personalBestDisplayMode and medalDisplayMode to set the correct values for the representation of the medals and pb data
        array<string> allPositionToGet = allPositionToGetStringSave.Split(",");
        allPositionData = {};
        for(uint i = 0; i < allPositionToGet.Length; i++){
            int position = Text::ParseInt(allPositionToGet[i]);
            PositionData data = PositionData(position);
            if(position == 1){
                data.color = "\\$071";
            }else if(position > 1 && position <= 10){
                data.color = "\\$db4";
            }else if(position > 10 && position <= 100){
                data.color = "\\$899";
            }else if(position > 100 && position <= 1000){
                data.color = "\\$964";
            }else{
                data.color = "\\$444";
            }
            allPositionData.InsertLast(data);
        }
        nbSizePositionDataArray = allPositionData.Length;

        string colorToUse;
        if(personalBestDisplayMode == EnumDisplayPersonalBest::IN_GREEN){
            colorToUse = pbGreenColor;
        }else if(personalBestDisplayMode == EnumDisplayPersonalBest::IN_GREY){
            colorToUse = greyColor3;
        }else{
            colorToUse = whiteColor;
        }
        currentPbPositionData = PositionData(0, pbGreenColor, Icons::User, colorToUse);

        if(medalDisplayMode == EnumDisplayMedal::NORMAL){
            colorToUse = whiteColor;
        }else{
            colorToUse = greyColor3;
        }
        for(uint medal = MedalType::BRONZE; medal < MedalType::COUNT; medal++){
            auto medalHandler = GetMedalHandler(MedalType(medal));
            PositionData defaultPosData = medalHandler.GetDefaultPositionData();
            defaultPosData.color = colorToUse;
            medalHandler.SetPositionData(defaultPosData);
        }
    }
    // ---------- END OF 2.6.0 MIGRATION ----------

    // ---------- MIGRATION FROM 2.6.0 TO 2.6.1 ----------
    if (major == 2 && minor == 6 && patch < 1) {
        UI::ShowNotification(pluginName, "Settings migration in progress (2.6.1)...");
        migrationNeeded = true;
        // if they use a custom medal plugin, modify the icon color to match the plugin's color (if they were using the default color)
        //CM : red color
        //WM : blue color
#if DEPENDENCY_CHAMPIONMEDALS
        if (championMedalPositionData.color == redColor) {
            championMedalPositionData.color = championColor;
        }
#endif
#if DEPENDENCY_WARRIORMEDALS
        if (warriorMedalPositionData.color == blueColor) {
            warriorMedalPositionData.color = warriorColor;
        }
#endif
    }
    // ---------- END OF 2.6.1 MIGRATION ----------

    // ---------- MIGRATION FROM 2.6.2+ TO 2.7.0 ----------
    if (major == 2 && minor == 6 && patch < 5) {
        UI::ShowNotification(pluginName, "Settings migration in progress (2.6.2+)...");
        migrationNeeded = true;
        // Fix potentially broken custom medal colors because of uninitialized colors
#if DEPENDENCY_CHAMPIONMEDALS
        if (championMedalPositionData.color == "" || championMedalPositionData.color == whiteColor) {
            championMedalPositionData.color = championColor;
        }
#endif
#if DEPENDENCY_WARRIORMEDALS
        if (warriorMedalPositionData.color == "" || warriorMedalPositionData.color == whiteColor) {
            print("Setting warrior medal color to: " + warriorColor + " color: " + warriorMedalPositionData.color);
            warriorMedalPositionData.color = warriorColor;
        }
#endif
    }
    // ---------- END OF 2.7.0 MIGRATION ----------
    
    if (migrationNeeded) {
        UI::ShowNotification(pluginName, "Settings migration completed! Feel free to check the settings for new options!", 15000);
    }
}