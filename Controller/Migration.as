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

    // ---------- MIGRATION FROM * TO 2.6.0 ----------
    if (major < 2 || (major == 2 && minor < 6)) {
        UI::ShowNotification(pluginName, "Settings migration in progress (2.6.0)...");
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
        atPositionData = PositionData(0, atGreenColor, Icons::Circle, colorToUse);
        goldPositionData = PositionData(0, goldColor, Icons::Circle, colorToUse);
        silverPositionData = PositionData(0, silverColor, Icons::Circle, colorToUse);
        bronzePositionData = PositionData(0, bronzeColor, Icons::Circle, colorToUse);
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        sbVillePositionData = PositionData(0, greyColor1, Icons::Circle, colorToUse);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        championMedalPositionData = PositionData(0, redColor, Icons::Circle, colorToUse);
#endif
#if DEPENDENCY_WARRIORMEDALS
        warriorMedalPositionData = PositionData(0, blueColor, Icons::Circle, colorToUse);
#endif
        UI::ShowNotification(pluginName, "Settings migration completed! Feel free to check the settings for new options!", 15000);
    }
    // ---------- END OF 2.6.0 MIGRATION ----------
}