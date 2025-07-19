[SettingsTab name="General Customization" icon="Cog" order="1"]
void RenderSettingsCustomization(){

    if(!UserCanUseThePlugin()){
        UI::TextWrapped("You don't have the required permissions to use this plugin. You need a paid subscription.");
        return;
    }

    if(UI::Button("Reset to default")){
        showRefreshButtonSetting = true;
        showTableHeaders = true;
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

    showTableHeaders = UI::Checkbox("Display the headers? (Position, Time, %, etc...)", showTableHeaders);

    UI::Text("\n\tExternal API");

    useExternalAPI = UI::Checkbox("Use external API if available (allow for more informations on maps)", useExternalAPI);

    UI::BeginDisabled(!useExternalAPI);

    showPlayerCount = UI::Checkbox("Show player count (only available if using the API)", showPlayerCount);

    UI::EndDisabled();

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UI::Text("\n\tUltimate Medals Extended Support");

    exportToUME = UI::Checkbox("Add custom positions to Ultimate Medals Extended (if available)", exportToUME);

    UI::BeginDisabled(!exportToUME);

    usePositionDataForUME = UI::Checkbox("Use custom position's customization for Ultimate Medals Extended", usePositionDataForUME);

    UI::EndDisabled();

#endif
    UI::Text("\n\tDisplay mode customizations");

    hiddingSpeedSetting = UI::InputFloat("Hide if speed is above X (if the hide when driving mode is active)", hiddingSpeedSetting);
    if(hiddingSpeedSetting < 0){
        hiddingSpeedSetting = 0;
    }

    unhideDelay = UI::InputInt("Delay (in ms) to wait before showing the window if you're below the hiding speed", unhideDelay, 100);
    if(unhideDelay < 0){
        unhideDelay = 0;
    }

    UI::Text("\n\tTimer");

    refreshTimer = UI::InputInt("Refresh timer every X (minutes)", refreshTimer);

    UI::Text("\n\tPersonal best");

    showPb = UI::Checkbox("Show personal best", showPb);

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
        for(int i = 0; i < int(allPositionData.Length); i++){
            string text = "Position " + allPositionData[i].position;
            if(UI::Selectable(text, currentComboChoice == int(allPositionData[i].position))){
                currentComboChoice = allPositionData[i].position;
            }
        }
        UI::EndCombo();
    }

    UI::EndDisabled();

}


[SettingsTab name="Explanation" icon="Question" order="4"]
void RenderSettingsExplanation(){
    UI::TextWrapped("This plugin allows you to see more leaderboard positions.\n\n");
    UI::TextWrapped("You can modify the positions in the \"Leaderboard Entry Customization\" tab\n");
    UI::TextWrapped("\nThe leaderboard is refreshed every <" + refreshTimer + "> minutes when in a map.");
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
        UI::TextWrapped("You don't have the required permissions to use this plugin. You need a paid subscription.");
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
#if DEPENDENCY_S314KEMEDALS
        showS314keMedals = true;
#endif
        showAT = true;
        showGold = true;
        showSilver = true;
        showBronze = true;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    showMedals = UI::Checkbox("Show medals estimated positions", showMedals);

    if(showMedals){
        showMedalWhenBetter = UI::Checkbox("Show medal even if you have it (if possible)", showMedalWhenBetter);
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        showSBVilleATMedal = UI::Checkbox("Show SBVille AT medal", showSBVilleATMedal);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        showChampionMedals = UI::Checkbox("Show Champion medals", showChampionMedals);
#endif
#if DEPENDENCY_WARRIORMEDALS
        showWarriorMedals = UI::Checkbox("Show Warrior medals", showWarriorMedals);
#endif
#if DEPENDENCY_S314KEMEDALS
        showS314keMedals = UI::Checkbox("Show S314ke medals", showS314keMedals);
#endif
        showAT = UI::Checkbox("Show AT", showAT);
        showGold = UI::Checkbox("Show Gold", showGold);
        showSilver = UI::Checkbox("Show Silver", showSilver);
        showBronze = UI::Checkbox("Show Bronze", showBronze);
    }

}


/**
 * Function to select an icon and color from the list of available ones
 */
bool GetPositionData(const string &in positionName, int uniqueId, PositionData& positionData, bool allowPositionChange = false){
    bool changed = false;
    bool isCustomIcon = false;
    bool isCustomIconColor = false;
    bool isCustomTextColor = false;
    UI::BeginTable("PositionData#" + uniqueId, 4);
    UI::TableNextRow();
    UI::TableNextColumn();
    uint tmpPos = positionData.position;
    string tmpIcon = positionData.icon;
    string tmpColor = positionData.color;
    string tmpTextColor = positionData.textColor;
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
                if(i==0){
                    positionData.icon = "Custom" + positionData.icon;
                } else {
                    positionData.icon = possibleIcons[i];
                }
            }
        }
        UI::EndCombo();
    }

    UI::TableNextColumn();
    if(UI::BeginCombo("Icon Color", positionData.color + Icons::Square)){
        for(uint i = 0; i < possibleColors.Length; i++){
            string label = i == 0 ? "Custom" : possibleColors[i] + Icons::Square;
            if(UI::Selectable(label, positionData.color == possibleColors[i])){
                UI::SetItemDefaultFocus();
                if(i==0){
                    positionData.color = "Custom" + positionData.color;
                } else {
                    positionData.color = possibleColors[i];
                }
            }
        }
        UI::EndCombo();
    }

    UI::TableNextColumn();
    if(UI::BeginCombo("Text Color", positionData.textColor + Icons::Square)){
        for(uint i = 0; i < possibleColors.Length; i++){
            string label = i == 0 ? "Custom" : possibleColors[i] + Icons::Square;
            if(UI::Selectable(label, positionData.textColor == possibleColors[i])){
                UI::SetItemDefaultFocus();
                if(i==0){
                    positionData.textColor = "Custom" + positionData.textColor;
                } else {
                    positionData.textColor = possibleColors[i];
                }
            }
        }
        UI::EndCombo();
    }

    // check if there is custom stuff by seeing if it contains the word "Custom"
    if(positionData.icon.Contains("Custom")){
        isCustomIcon = true;
    }
    if(positionData.color.Contains("Custom")){
        isCustomIconColor = true;
    }
    if(positionData.textColor.Contains("Custom")){
        isCustomTextColor = true;
    }

    if (isCustomIcon || isCustomIconColor || isCustomTextColor){
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::TableNextColumn();
        if(isCustomIcon){
            string baseIcon = positionData.icon == "" || positionData.icon == "Custom" ? possibleIcons[1] : positionData.icon.Replace("Custom", "");
            auto newIcon = UI::InputText("Custom Icon", baseIcon);
            // if the user has not entered anything, we keep the default icon
            positionData.icon = "Custom" + newIcon;
        }
        UI::TableNextColumn();
        if(isCustomIconColor){
            vec3 baseColor = positionData.color == "" ? vec3() : StringToVec3Color(positionData.color);
            auto vecIconColor = UI::InputColor3("Custom Icon Color", baseColor);
            positionData.color = "Custom" + Vec3ColorToString(vecIconColor);
        }
        UI::TableNextColumn();
        if(isCustomTextColor){
            vec3 baseColor = positionData.textColor == "" ? vec3() : StringToVec3Color(positionData.textColor);
            auto vecTextColor = UI::InputColor3("Custom Text Color", baseColor);
            positionData.textColor = "Custom" + Vec3ColorToString(vecTextColor);
        }
    }

    UI::EndTable();

    if(tmpPos != positionData.position || tmpIcon != positionData.icon || tmpColor != positionData.color || tmpTextColor != positionData.textColor){
        changed = true;
    }

    return changed;
}


[SettingsTab name="Leaderboard Entry Customization" icon="Kenney::PodiumAlt" order="2"]
void RenderPositionDataCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You need a paid subscription.");
        return;
    }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset positions to default")){
        trace("old allPositionDataStringSave : " + allPositionDataStringSave);
        trace("old allPositionData : " + allPositionData.Length);
        allPositionData = array<PositionData>();
        allPositionData.InsertLast(PositionData(1, atGreenColor));
        allPositionData.InsertLast(PositionData(10, goldColor));
        allPositionData.InsertLast(PositionData(100, silverColor));
        allPositionData.InsertLast(PositionData(1000, bronzeColor));
        allPositionData.InsertLast(PositionData(10000, greyColor1));
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
        changed = GetPositionData("Custom Position " + (i+1), i, allPositionData[i], true) || changed;
    }

    UI::Separator();
    UI::Text("Personal best setting");
    if(UI::Button("Reset pb to default")){
        currentPbPositionData = PositionData(0, pbGreenColor, Icons::User, pbGreenColor);
    }
    changed = GetPositionData("Personal Best", -10000, currentPbPositionData) || changed;

    UI::Separator();
    UI::Text("Medals settings");
    if(UI::Button("Reset medals to default")){
        for(uint medal = MedalType::BRONZE; medal < MedalType::COUNT; medal++){
            auto medalHandler = GetMedalHandler(MedalType(medal));
            medalHandler.SetPositionData(medalHandler.GetDefaultPositionData());
        }
    }
    changed = GetPositionData("Author Medal", 10001, atPositionData) || changed;
    changed = GetPositionData("Gold Medal", 10002, goldPositionData) || changed;
    changed = GetPositionData("Silver Medal", 10003, silverPositionData) || changed;
    changed = GetPositionData("Bronze Medal", 10004, bronzePositionData) || changed;
#if DEPENDENCY_CHAMPIONMEDALS
    changed = GetPositionData("Champion Medal", 10005, championMedalPositionData) || changed;
#endif
#if DEPENDENCY_WARRIORMEDALS
    changed = GetPositionData("Warrior Medal", 10006, warriorMedalPositionData) || changed;
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    changed = GetPositionData("SBVille Medal", 10007, sbVillePositionData) || changed;
#endif
#if DEPENDENCY_S314KEMEDALS
    changed = GetPositionData("S314ke Medal", 10008, s314keMedalPositionData) || changed;
#endif

    if(changed){
        OnSettingsChanged();
    }
}