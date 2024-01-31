[SettingsTab name="General Customization" icon="Cog" order="1"]
void RenderSettingsCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    if(UI::Button("Reset to default")){
        hiddingSpeedSetting = 1.0f;
        refreshTimer = 5;
        showPb = true;
        showTimeDifference = true;
        showColoredTimeDifference = true;
        inverseTimeDiffSign = false;
    }

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

    UI::Text("\n\tMap/Author Name");

    showMapName = UI::Checkbox("Show map name", showMapName);
    showMapAuthor = UI::Checkbox("Show author name", showMapAuthor);

    UI::Text("\n\tTime difference");
    showTimeDifference = UI::Checkbox("Show time difference", showTimeDifference);

    UI::BeginDisabled(!showTimeDifference);

    inverseTimeDiffSign = UI::Checkbox("Inverse sign (+ instead of -)", inverseTimeDiffSign);

    showColoredTimeDifference = UI::Checkbox("Color the time difference (blue if negative, red otherwise)", showColoredTimeDifference);

    UI::EndDisabled();

}

[SettingsTab name="Positions customization" icon="Kenney::PodiumAlt" order="2"]
void RenderPositionCustomization(){

    if(!UserCanUseThePlugin()){
        UI::Text("You don't have the required permissions to use this plugin. You at least need the standard edition.");
        return;
    }

    UI::Text("The UI will be updated when the usual conditions are met (see Explanation) or if you press the refresh button.");

    if(UI::Button("Reset to default")){
        allFriendsToGet = {};
        allFriendsToGetStringSave = "";
        nbSizePositionToGetArray = 0;
    }

    if(UI::Button("Refresh")){
        ForceRefresh();
    }

    for(int i = 0; i < nbSizePositionToGetArray; i++){
        string tmp = UI::InputText("Friend " + (i+1) + " Account ID", allFriendsToGet[i]);
        string tmp2 = UI::InputText("Friend " + (i+1) + " Name", allFriendsName[i]);
        if(tmp != allFriendsToGet[i]){
            allFriendsToGet[i] = tmp;
            OnSettingsChanged();
        }
        if(tmp2 != allFriendsName[i]){
            allFriendsName[i] = tmp2;
            OnSettingsChanged();
        }
    }


    if(UI::Button("+ : Add a friend")){
        nbSizePositionToGetArray++;
        allFriendsToGet.InsertLast("");
        allFriendsName.InsertLast("");
        OnSettingsChanged();
    }
    if(UI::Button("- : Remove a friend")){
        if(nbSizePositionToGetArray > 1){
            nbSizePositionToGetArray--;
            allFriendsToGet.RemoveAt(nbSizePositionToGetArray);
            allFriendsName.RemoveAt(nbSizePositionToGetArray);
            OnSettingsChanged();
        }
    }
}