[SettingsTab name="General Customization" icon="Cog" order="1"]
void RenderSettingsCustomization(){

    if(!UserCanUseThePlugin()){
        UI::TextWrapped("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    if(UI::Button("Reset to default")){
        showRefreshButtonSetting = true;
        hiddingSpeedSetting = 1.0f;
        refreshTimer = 5;
        showPb = true;
        showPercentage = false;
        showTimeDifference = true;
        showColoredTimeDifference = true;
        inverseTimeDiffSign = false;
        currentComboChoice = -1;
        shorterNumberRepresentation = false;
        shortenAbove = 100000;
        useExternalAPI = false;
    }

    showRefreshButtonSetting = UI::Checkbox("Add refresh button to UI (only appears when OP Overlay is on)", showRefreshButtonSetting);

    UI::Text("\n\tExternal API");

    useExternalAPI = UI::Checkbox("Use external API if available (allow for more informations on maps)", useExternalAPI);

    UI::BeginDisabled(!useExternalAPI);

    showPlayerCount = UI::Checkbox("Show player count (only available if using the API)", showPlayerCount);

    UI::EndDisabled();

    UI::Text("\n\tDisplay mode customizations");

    hiddingSpeedSetting = UI::InputFloat("Hide if speed is above X (if the hide when driving mode is active)", hiddingSpeedSetting);
    if(hiddingSpeedSetting < 0){
        hiddingSpeedSetting = 0;
    }

    UI::Text("\n\tTimer");

    refreshTimer = UI::InputInt("Refresh timer every X (minutes)", refreshTimer);

    UI::Text("\n\tPersonal best");

    showPb = UI::Checkbox("Show personal best", showPb);

    UI::BeginDisabled(!showPb);

    string pbDisplayComboTitle = "Invalid state";

    switch(personalBestDisplayMode){
        case EnumDisplayPersonalBest::NORMAL:
            pbDisplayComboTitle = "Normal";
            break;
        case EnumDisplayPersonalBest::IN_GREY:
            pbDisplayComboTitle = "In grey";
            break;
        case EnumDisplayPersonalBest::IN_GREEN:
            pbDisplayComboTitle = "In green";
            break;
    }

    if(UI::BeginCombo("Personal best display mode", pbDisplayComboTitle)){
        if(UI::Selectable("Normal", personalBestDisplayMode == EnumDisplayPersonalBest::NORMAL)){
            personalBestDisplayMode = EnumDisplayPersonalBest::NORMAL;
        }
        if(UI::Selectable("In grey", personalBestDisplayMode == EnumDisplayPersonalBest::IN_GREY)){
            personalBestDisplayMode = EnumDisplayPersonalBest::IN_GREY;
        }
        if(UI::Selectable("In green", personalBestDisplayMode == EnumDisplayPersonalBest::IN_GREEN)){
            personalBestDisplayMode = EnumDisplayPersonalBest::IN_GREEN;
        }

        UI::EndCombo();
    }

    UI::EndDisabled();

    UI::BeginDisabled(!useExternalAPI);

    UI::Text("\n\tPercentage ranking");

    showPercentage = UI::Checkbox("Show percentage column (requires External API)", showPercentage && useExternalAPI);

    UI::EndDisabled();

    UI::Text("\n\tPosition Representation");

    shorterNumberRepresentation = UI::Checkbox("Use shorter number representation (10k instead of 10000)", shorterNumberRepresentation);

    UI::BeginDisabled(!shorterNumberRepresentation);

    shortenAbove = UI::InputInt("Shorten above X (example with 10000 : show 10k instead of 10000)", shortenAbove);

    UI::EndDisabled();

    UI::Text("\n\tMap/Author Name");

    showMapName = UI::Checkbox("Show map name", showMapName);
    showMapAuthor = UI::Checkbox("Show author name", showMapAuthor);

    UI::Text("\n\tTime difference");
    showTimeDifference = UI::Checkbox("Show time difference", showTimeDifference);

    UI::BeginDisabled(!showTimeDifference);

    inverseTimeDiffSign = UI::Checkbox("Inverse sign (+ instead of -)", inverseTimeDiffSign);

    showColoredTimeDifference = UI::Checkbox("Color the time difference (blue if negative, red otherwise)", showColoredTimeDifference);

    UI::Text("\t\tFrom which position should the time difference be shown?");
    string comboText = "";
    if(currentComboChoice == -1){
        comboText = "Personal best";
    }else{
        comboText = "Position " + currentComboChoice;
    }

    if(UI::BeginCombo("Time Diff position", comboText)){
        if(UI::Selectable("Personal best", currentComboChoice == -1)){
            currentComboChoice = -1;
            UI::SetItemDefaultFocus();
        }
        for(int i = 0; i < int(allPositionToGet.Length); i++){
            string text = "Position " + allPositionToGet[i];
            if(UI::Selectable(text, currentComboChoice == allPositionToGet[i])){
                currentComboChoice = allPositionToGet[i];
            }
        }
        UI::EndCombo();
    }

    UI::EndDisabled();

}

[SettingsTab name="Explanation" icon="Question" order="4"]
void RenderSettingsExplanation(){
    UI::TextWrapped("This plugin allows you to see more leaderboard positions.\n\n");
    UI::TextWrapped("You can modify the positions in the \"Positions customization\" tab\n");
    UI::TextWrapped("\nThe leaderboard is refreshed every " + refreshTimer + " minutes when in a map.");
    UI::TextWrapped("This timer resets when you leave the map and is automatically refreshed when you join a map, or if you set a new pb on a map.");;
    UI::TextWrapped("\nThe plugin also allows you to see the time difference between a given position and all the other one.");
    UI::TextWrapped("\nThe medals can also be added to the leaderboard. You can see them as \"if you had a time of X, you would be at the Y position\".\nBecause of API limitation, the medals are not shown in the leaderboard if you have them and are using the 'normal mode'.");
    UI::TextWrapped("\nSince the 2.0 update, a new parameter has been added, allowing you to get faster refreshes and medals positions even if you have them. You may enable it in the \"General Customization\" tab.\nPlease be aware that this feature might be removed at some point, as it depends on an external service that I might not be able to keep up all year long.");
    UI::Dummy(vec2(0,100));
    UI::TextWrapped("Made by Banalian.\nContact me on Discord (you can find me on the OpenPlanet Discord) if you have any questions or suggestions !\nYou can also use the github page to post about any issue you might encounter or any feature you would like added to this plugin.");
}

[SettingsTab name="Medals Position" icon="Circle" order="3"]
void RenderMedalSettings(){
    if(!UserCanUseThePlugin()){
        UI::TextWrapped("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::TextWrapped("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        showMedalWhenBetter = false;
        showMedals = true;
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        showSBVilleATMedal = true;
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        showChampionMedals = true;
#endif
#if DEPENDENCY_WARRIORMEDALS
        showWarriorMedals = true;
#endif
        showAT = true;
        showGold = true;
        showSilver = true;
        showBronze = true;
        medalDisplayMode = EnumDisplayMedal::NORMAL;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    showMedals = UI::Checkbox("Show medals estimated positions", showMedals);

    if(showMedals){
        showMedalWhenBetter = UI::Checkbox("Show medal even if you have it (if possible)", showMedalWhenBetter);
        UI::TextWrapped("\n\tNote: if two medals share the same time, the second one will not be shown.");
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        showSBVilleATMedal = UI::Checkbox("Show SBVille AT medal", showSBVilleATMedal);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        showChampionMedals = UI::Checkbox("Show Champion medals", showChampionMedals);
#endif
#if DEPENDENCY_WARRIORMEDALS
        showWarriorMedals = UI::Checkbox("Show Warrior medals", showWarriorMedals);
#endif
        showAT = UI::Checkbox("Show AT", showAT);
        showGold = UI::Checkbox("Show Gold", showGold);
        showSilver = UI::Checkbox("Show Silver", showSilver);
        showBronze = UI::Checkbox("Show Bronze", showBronze);
    }

    UI::Text("\n\tAppearance");

    // Show it as normal, greyed out and/or italic
    string comboTitle = "Invalid state";

    switch(medalDisplayMode){
        case EnumDisplayMedal::NORMAL:
            comboTitle = "Normal";
            break;
        case EnumDisplayMedal::IN_GREY:
            comboTitle = "In grey";
            break;
    }

    if(UI::BeginCombo("Medal display mode", comboTitle)){
        if(UI::Selectable("Normal", medalDisplayMode == EnumDisplayMedal::NORMAL)){
            medalDisplayMode = EnumDisplayMedal::NORMAL;
        }
        if(UI::Selectable("In grey", medalDisplayMode == EnumDisplayMedal::IN_GREY)){
            medalDisplayMode = EnumDisplayMedal::IN_GREY;
        }

        UI::EndCombo();
    }

}

[SettingsTab name="Positions customization" icon="Kenney::PodiumAlt" order="2"]
void RenderPositionCustomization(){

    if(!UserCanUseThePlugin()){
        UI::TextWrapped("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::TextWrapped("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        allPositionToGet = {1,10,100,1000,10000};
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    if(UI::Button("+ : Add a position")){
        nbSizePositionToGetArray++;
        allPositionToGet.InsertLast(1);
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a position")){
        if(nbSizePositionToGetArray > 0){
            nbSizePositionToGetArray--;
            allPositionToGet.RemoveAt(nbSizePositionToGetArray);
            OnSettingsChanged();
        }
    }

    for(int i = 0; i < nbSizePositionToGetArray; i++){
        int tmp = UI::InputInt("Custom position " + (i+1), allPositionToGet[i]);
        if(tmp != allPositionToGet[i]){
            if(currentComboChoice == allPositionToGet[i]){
                currentComboChoice = tmp;
            }
            allPositionToGet[i] = tmp;
            OnSettingsChanged();
        }
    }
}



/**
 * Function to select an icon and color from the list of available ones
 */
 bool GetPositionData(const string &in positionName, int uniqueId, PositionData& positionData, bool allowPositionChange = false){
    bool changed = false;
    UI::BeginTable("PositionData#" + uniqueId, 3);
    UI::TableNextRow();
    UI::TableNextColumn();
    uint tmpPos = positionData.position;
    string tmpIcon = positionData.icon;
    string tmpColor = positionData.color;
    if(allowPositionChange){
        positionData.position = UI::InputInt(positionName, positionData.position);
    }else{
        UI::Text(positionName);
    }
    UI::TableNextColumn();
    if(UI::BeginCombo("Icon", positionData.icon)){
        for(uint i = 0; i < possibleIcons.Length; i++){
            if(UI::Selectable(possibleIcons[i], positionData.icon == possibleIcons[i])){
                UI::SetItemDefaultFocus();
                positionData.icon = possibleIcons[i];
            }
        }
        UI::EndCombo();
    }
    UI::TableNextColumn();
    if(UI::BeginCombo("Color", positionData.color + Icons::Square)){
        for(uint i = 0; i < possibleColors.Length; i++){
            if(UI::Selectable(possibleColors[i] + Icons::Square, positionData.color == possibleColors[i])){
                UI::SetItemDefaultFocus();
                positionData.color = possibleColors[i];
            }
        }
        UI::EndCombo();
    }
    UI::EndTable();

    if(tmpPos != positionData.position || tmpIcon != positionData.icon || tmpColor != positionData.color){
        changed = true;
    }

    return changed;
 }

[SettingsTab name="Positions data customization"]
void RenderPositionDataCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        trace("old allPositionDataStringSave : " + allPositionDataStringSave);
        trace("old allPositionData : " + allPositionData.Length);
        allPositionData = array<PositionData>();
        allPositionData.InsertLast(PositionData(1, "\\$071"));
        allPositionData.InsertLast(PositionData(10, "\\$db4"));
        allPositionData.InsertLast(PositionData(100, "\\$899"));
        allPositionData.InsertLast(PositionData(1000, "\\$964"));
        allPositionData.InsertLast(PositionData(10000, "\\$444"));
        allPositionDataStringSave = "";
        for(uint i = 0; i < allPositionData.Length; i++){
            allPositionDataStringSave += allPositionData[i].Serialize();
            if(i < allPositionData.Length - 1){
                allPositionDataStringSave +=  ";";
            }
        }
        nbSizePositionDataArray = allPositionData.Length;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    if(UI::Button("+ : Add a position")){
        nbSizePositionDataArray++;
        allPositionData.InsertLast(PositionData(1));
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a position")){
        if(nbSizePositionDataArray > 0){
            nbSizePositionDataArray--;
            allPositionData.RemoveAt(nbSizePositionDataArray);
            OnSettingsChanged();
        }
    }

    bool changed = false;
    for(uint i = 0; i < allPositionData.Length; i++){
        changed = GetPositionData("Custom Position " + (i+1), i, allPositionData[i], true);
    }

    UI::Separator();
    UI::Text("Personal best setting");
    if(UI::Button("Reset to default")){
        currentPbPositionData = PositionData(0, possibleColors[7], Icons::User);
    }
    changed = changed || GetPositionData("Personal Best", -10000, currentPbPositionData);

    UI::Separator();
    UI::Text("Medals settings");
    if(UI::Button("Reset to default")){
        atPositionData = PositionData(0, possibleColors[0], Icons::Circle);
        goldPositionData = PositionData(0, possibleColors[1], Icons::Circle);
        silverPositionData = PositionData(0, possibleColors[2], Icons::Circle);
        bronzePositionData = PositionData(0, possibleColors[3], Icons::Circle);
#if DEPENDENCY_CHAMPIONMEDALS
        championMedalPositionData = PositionData(0, possibleColors[4], Icons::Circle);
#endif
#if DEPENDENCY_WARRIORMEDALS
        warriorMedalPositionData = PositionData(0, possibleColors[4], Icons::Circle);
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        sbVillePositionData = PositionData(0, possibleColors[4], Icons::Circle);
#endif
    }
    changed = changed || GetPositionData("Author Medal", 10001, atPositionData);
    changed = changed || GetPositionData("Gold Medal", 10002, goldPositionData);
    changed = changed || GetPositionData("Silver Medal", 10003, silverPositionData);
    changed = changed || GetPositionData("Bronze Medal", 10004, bronzePositionData);
#if DEPENDENCY_CHAMPIONMEDALS
    changed = changed || GetPositionData("Champion Medal", 10005, championMedalPositionData);
#endif
#if DEPENDENCY_WARRIORMEDALS
    changed = changed || GetPositionData("Warrior Medal", 10006, warriorMedalPositionData);
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    changed = changed || GetPositionData("SBVille Medal", 10007, sbVillePositionData);
#endif

    if(changed){
        OnSettingsChanged();
    }
}