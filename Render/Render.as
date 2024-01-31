// ############################## MENU #############################

void RenderMenu() {
    if(UI::BeginMenu(podiumIconBlue + " " +pluginName)) {
        if(windowVisible) {
            if(UI::MenuItem("Hide")) {
                windowVisible = false;
            }
            if(UI::MenuItem("Force refresh")) {
                ForceRefresh();
            }
        } else {
            if(UI::MenuItem("Show")) {
                windowVisible = true;
            }
        }

        UI::EndMenu();
    }
}

// ############################## WINDOW RENDER #############################

void Render() {

    if(!UserCanUseThePlugin()){
        return;
    }

    if(displayMode == EnumDisplayMode::ALWAYS) {
        RenderWindows();
    } else if (UI::IsGameUIVisible() && displayMode == EnumDisplayMode::ALWAYS_EXCEPT_IF_HIDDEN_INTERFACE){
        RenderWindows();
    }

    if(displayMode == EnumDisplayMode::HIDE_WHEN_DRIVING){
        auto state = VehicleState::ViewingPlayerState();
        if(state is null) return;
        float currentSpeed = state.WorldVel.Length() * 3.6;
        if(currentSpeed >= hiddingSpeedSetting) return;

        RenderWindows();
    }
}

void RenderInterface(){
    if(!UserCanUseThePlugin()){
        return;
    }

    if(displayMode == EnumDisplayMode::ONLY_IF_OPENPLANET_MENU_IS_OPEN) {
        RenderWindows();
    }
}

void RenderWindows(){
    auto app = cast<CTrackMania>(GetApp());

    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking | UI::WindowFlags::NoFocusOnAppearing;
    bool showRefreshButton = false;

    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoMove;
    }

    if(leaderboardArray.Length == 0 && !failedRefresh){
        return;
    }

    //we don't want to show the window if we're in the editor
    if(app.Editor !is null){
        return;
    }

    if(windowVisible && app.CurrentPlayground !is null){
        UI::Begin(pluginName, windowFlags);

        UI::BeginGroup();

        if(showPluginName){
            UI::Text(pluginName);
        }

        if(showPluginName && showSeparator){
            UI::Separator();
        }

        bool rendered = RenderInfoTab();

        RenderTab(!rendered);

        UI::EndGroup();

        UI::End();
    }
}

/**
 * Render the info tab
 * 
 * returns true if the refresh icon was rendered
 */
bool RenderInfoTab(){

    // if we don't show anything, we don't render the tab
    if(!(showMapName || showMapAuthor)){
        return false;
    }

    auto app = cast<CTrackMania>(GetApp());

    // To change where the refresh icon is rendered, we need to know if we rendered it or not
    bool refreshWasRendered = false;


    UI::BeginTable("Info", 4, UI::TableFlags::SizingFixedFit);
    UI::TableSetupColumn("info", UI::TableColumnFlags::WidthFixed);
    UI::TableSetupColumn("empty", UI::TableColumnFlags::WidthStretch);
    UI::TableSetupColumn("potentialRefresh", UI::TableColumnFlags::WidthFixed);
    UI::TableSetupColumn("playercount", UI::TableColumnFlags::WidthFixed);
    UI::TableNextRow();
    UI::TableNextColumn();
    if(app.RootMap !is null){
        if(showMapName){
            UI::Text(StripFormatCodes(app.RootMap.MapInfo.Name));
            UI::TableNextColumn();
            UI::TableNextColumn();
            UI::TableNextColumn();
            RenderRefreshIcon();
            refreshWasRendered = true;
        }

        UI::TableNextRow();
        UI::TableNextColumn();
        if(showMapAuthor){
            UI::Text(brightGreyColor + "Made by " + StripFormatCodes(app.RootMap.MapInfo.AuthorNickName));    
        }
        UI::TableNextColumn();
        UI::TableNextColumn();
        // if the refresh icon wasn't rendered, we render it here (for better alignment)
        if(!refreshWasRendered && showMapAuthor){
            RenderRefreshIcon();
            refreshWasRendered = true;
        }
    }

    UI::EndTable();

    return refreshWasRendered;
}

/**
 * Render the refresh icon if we're refreshing
 */
 void RenderRefreshIcon(){
    auto remainingTime = Time::Format(int(Math::Ceil((updateFrequency - timer) / 1000)) * 1000);
    remainingTime = remainingTime.SubStr(0 , remainingTime.Length - 4);

    if(refreshPosition){
        UI::Text(loadingSteps[currentLoadingStep]);
        if(UI::IsItemHovered()){
            UI::BeginTooltip();
            UI::Text("Refreshing...");
            UI::EndTooltip();
        }
    }else if(failedRefresh){
        UI::Text(refreshIconWhite + warningIcon);
        if(UI::IsItemClicked()){
            ForceRefresh();
        }
        if(UI::IsItemHovered()){
            UI::BeginTooltip();
            UI::Text("Failed to receive updated data from the game API.");
            UI::Text("API updates may be delayed during peak times.");
            UI::Text("Automatic refresh in: " + remainingTime);
            UI::Text("Click icon to refresh now.");
            UI::EndTooltip();
        }
    }else {
        UI::Text(refreshIconWhite);
        if(UI::IsItemClicked()){
            ForceRefresh();
        }
        if(UI::IsItemHovered()){
            UI::BeginTooltip();
            UI::Text("Automatic refresh in: " + remainingTime);
            UI::Text("Click icon to refresh now.");
            UI::EndTooltip();
        }
    }
}

/**
 * Render the table with the custom leaderboard
 */
void RenderTab(bool showRefresh = false){
    int columnCount = 3;
    if(showTimeDifference){
        columnCount++;
    }
    UI::BeginTable("Main", columnCount);

    UI::TableNextRow();
    // Position
    UI::TableNextColumn();
    UI::Text("Name");
    // Time
    UI::TableNextColumn();
    UI::Text("Time");
    // Desc
    UI::TableNextColumn();
    if(showRefresh){
        RenderRefreshIcon();
    }
    // Time diff
    if(showTimeDifference){
        UI::TableNextColumn();
    }

    int i = 0;
    while(i < int(leaderboardArray.Length)){
        //We skip the pb if there's none
        if(
            (leaderboardArray[i].entryType == EnumLeaderboardEntryType::PB && leaderboardArray[i].time == -1) ||
            (!showPb && leaderboardArray[i].entryType == EnumLeaderboardEntryType::PB) ){
            i++;
            continue;
        }

        string displayString = "";

        if(leaderboardArray[i].entryType == EnumLeaderboardEntryType::PB){
            switch(personalBestDisplayMode){
                case EnumDisplayPersonalBest::NORMAL:
                    break;
                case EnumDisplayPersonalBest::IN_GREY:
                    displayString = greyColor;
                    break;
                case EnumDisplayPersonalBest::IN_GREEN:
                    displayString = greenColor;
                    break;
                default:
                    break;
            }
        }

        //------------NAME-------------
        UI::TableNextColumn();
		UI::Text(displayString + "" + leaderboardArray[i].name);

        //------------TIME-----------------
        UI::TableNextColumn();
        UI::Text(displayString + TimeString(leaderboardArray[i].time));

        //------------HAS DESC-------------
        UI::TableNextColumn();
        if(leaderboardArray[i].desc != ""){
            UI::Text(displayString + leaderboardArray[i].desc);
        }

        //------------TIME DIFFERENCE------
        if(showTimeDifference){
            UI::TableNextColumn();
            if(leaderboardArray[i].time == -1 || timeDifferenceEntry.time == -1){
                //Nothing here, no time to compare to
            }else if(leaderboardArray[i].time == timeDifferenceEntry.time){
                //Nothing here, it's the same time
                //still keeping the if in case we want to print/add something here
            }else{
                int timeDifference = leaderboardArray[i].time - timeDifferenceEntry.time;
                string timeDifferenceString = TimeString(Math::Abs(timeDifference));

                if(inverseTimeDiffSign){
                    if(timeDifference < 0){
                        UI::Text((showColoredTimeDifference ? redColor : "") + "+" + timeDifferenceString);
                    }else{
                        UI::Text((showColoredTimeDifference ? blueColor : "") + "-" + timeDifferenceString);
                    }
                }else{
                    if(timeDifference < 0){
                        UI::Text((showColoredTimeDifference ? blueColor : "") + "-" + timeDifferenceString);
                    }else{
                        UI::Text((showColoredTimeDifference ? redColor : "") + "+" + timeDifferenceString);
                    }
                }
            }
        }

        i++;
    }

    UI::EndTable();
}