[SettingsTab name="General Customization" icon="Cog" order="2"]
void RenderSettingsCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    if(UI::Button("Reset to default")){
        showRefreshButtonSetting = true;
        hiddingSpeedSetting = 1.0f;
        refreshTimer = 5;
        showPb = true;
        showTimeDifference = true;
        showColoredTimeDifference = true;
        inverseTimeDiffSign = false;
        currentComboChoice = -1;
        useExternalAPI = false;
    }

    showRefreshButtonSetting = UI::Checkbox("Add refresh button to UI (only appears when OP Overlay is on)", showRefreshButtonSetting);

    UI::Text("\n\tExternal API");

    useExternalAPI = UI::Checkbox("Use external API if available (allow for more informations on maps)", useExternalAPI);

    showPlayerCount = UI::Checkbox("Show player count (only available if using the API)", showPlayerCount);

    UI::Text("\n\tDisplay mode customizations");

    hiddingSpeedSetting = UI::InputFloat("Hide if speed is above X (if the hide when driving mode is active)", hiddingSpeedSetting);
    if(hiddingSpeedSetting < 0){
        hiddingSpeedSetting = 0;
    }

    UI::Text("\n\tTimer");

    refreshTimer = UI::InputInt("Refresh timer every X (minutes)", refreshTimer);

    UI::Text("\n\tPersonal best");

    showPb = UI::Checkbox("Show personal best", showPb);

    UI::Text("\n\tPosition Representation");

    shorterNumberRepresentation = UI::Checkbox("Use shorter number representation (10k instead of 10000)", shorterNumberRepresentation);

    UI::Text("\n\tMap/Author Name");

    showMapName = UI::Checkbox("Show map name", showMapName);
    showMapAuthor = UI::Checkbox("Show author name", showMapAuthor);

    UI::Text("\n\tTime difference");
    showTimeDifference = UI::Checkbox("Show time difference", showTimeDifference);
    if(showTimeDifference){
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
            

    }
    
}

[SettingsTab name="Explanation" icon="Question" order="5"]
void RenderSettingsExplanation(){
    UI::Text("This plugin allows you to see more leaderboard positions.\n\n");
    UI::Text("You can modify the positions in the \"Positions customization\" tab\n");
    UI::Text("\nThe leaderboard is refreshed every " + refreshTimer + " minutes when in a map.");
    UI::Text("This timer resets when you leave the map and is automatically refreshed when you join a map, or if you set a new pb on a map.");;
    UI::Text("\nThe plugin also allows you to see the time difference between a given position and all the other one.");
    UI::Text("\nThe medals can also be added to the leaderboard. You can see them as \"if you had a time of X, you would be at the Y position\".\nBecause of API limitation, the medals are not shown in the leaderboard if you have them and are using the 'normal mode'.");
    UI::Text("\nSince the 2.0 update, a new parameter has been added, allowing you to get faster refreshes and medals positions evn if you have them. You may enable it in the \"General Customization\" tab.\nPlease be aware that this feature might be removed at some point, as it depends on an external service that I might not be able to keep up all year long.");
    UI::Dummy(vec2(0,100));
    UI::Text("Made by Banalian.\nContact me on Discord (you can find me on the OpenPlanet Discord) if you have any questions or suggestions !\nYou can also use the github page to post about any issue you might encounter or any feature you would like added to this plugin.");
}

[SettingsTab name="Medals Position" icon="Circle" order="4"]
void RenderMedalSettings(){
    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        showMedalWhenBetter = false;
        showMedals = true;
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        showSBVilleATMedal = true;
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        showChampionMedals = true;
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
        UI::Text("\n");
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        showSBVilleATMedal = UI::Checkbox("Show SBVille AT medal", showSBVilleATMedal);
#endif
#if DEPENDENCY_CHAMPIONMEDALS
        showChampionMedals = UI::Checkbox("Show Champion medals", showChampionMedals);
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

[SettingsTab name="Positions customization" icon="Kenney::PodiumAlt" order="3"]
void RenderPositionCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        allPositionToGet = {1,10,100,1000,10000};
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
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


    if(UI::Button("+ : Add a position")){
        nbSizePositionToGetArray++;
        allPositionToGet.InsertLast(1);
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a position")){
        if(nbSizePositionToGetArray > 1){
            nbSizePositionToGetArray--;
            allPositionToGet.RemoveAt(nbSizePositionToGetArray);
            OnSettingsChanged();
        }
    }
}

//The following 2 tabs were added by Daniel1730
[SettingsTab name="Player Database" order="6"]
void RenderPlayerDatabase(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The boxes are formatted in the following manner: <Player ID, Player Name> for as many players as desired. If any of the players below happen to set any of the desired times, their name will");

    if(UI::Button("Reset to default")){
        allPlayersToGet = {};
        allPlayersToGetStringSave = "";
        nbSizePlayersToGetArray = 0;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    for(int i = 0; i < nbSizePlayersToGetArray; i++){
        string tmp = UI::InputText("Custom player " + (i+1), allPlayersToGet[i]);
        if(tmp != allPlayersToGet[i]){
            allPlayersToGet[i] = tmp;
            OnSettingsChanged();
        }
    }


    if(UI::Button("+ : Add a player")){
        nbSizePlayersToGetArray++;
        allPlayersToGet.InsertLast("Player ID, Player Name");
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a player")){
        if(nbSizePlayersToGetArray > 1){
            nbSizePlayersToGetArray--;
            allPlayersToGet.RemoveAt(nbSizePlayersToGetArray);
            OnSettingsChanged();
        }
    }
}

[SettingsTab name="Mode Swap" order="1"]
void RenderModeSwap(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The available modes are \"Normal\" and \"Rival\". In Rival mode, custom positions will not be used. Instead, the leaderboard will display only the times and positions of the players listed in the player database");

    string tmp = UI::InputText("Mode", currMode);
    if(tmp != currMode){
        currMode = tmp;
        OnSettingsChanged();
    }

    UI::Text("The available scope is 0 (World), 1 (Continent), 2 (Country), or 3 (Region). If a scope other than world is selected, the leaderboard will only display times in that region, instead of the World.");
    UI::Text("Changing this mode in a map will not have an effect until you change maps or reload the map");

    int tmp2 = UI::InputInt("Scope", currScope);
    if(tmp2 != currScope && tmp2 > -1 && tmp2 < 4){
        currScope = tmp2;
        updateAllZonesToSearch();
        OnSettingsChanged();
    }
}