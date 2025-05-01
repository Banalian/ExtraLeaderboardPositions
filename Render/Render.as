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

uint64 lastMovement = Time::get_Now();

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

        uint64 now = Time::get_Now();

        float currentSpeed = state.WorldVel.Length() * 3.6;
        if(currentSpeed >= hiddingSpeedSetting) {
            lastMovement = now;
            return;
        }

        if(now - lastMovement > 1000)
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

// Render the refresh button after we check if it's visible
void RenderRefreshButton(){
    if(showRefreshButtonSetting && UI::IsOverlayShown()){
        if(UI::Button("Refresh")){
            ForceRefresh();
        }
    }
}


void RenderWindows(){
    //we don't want to show the window if we're in an unsupported gamemode
    if(currentMode == EnumCurrentMode::INVALID){
        return;
    }
    auto app = cast<CTrackMania>(GetApp());

    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking | UI::WindowFlags::NoFocusOnAppearing;

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

        RenderRefreshButton();

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

    // used to avoid showing extra blank space when player count is still checked while external api is unchecked
    auto showPlayerCountEnabled = showPlayerCount && useExternalAPI;

    // if we don't show anything, we don't render the tab
    if(!(showMapName || showMapAuthor || showPlayerCountEnabled)){
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
            UI::Text(Text::StripFormatCodes(app.RootMap.MapInfo.Name));
            UI::TableNextColumn();
            UI::TableNextColumn();
            UI::TableNextColumn();
            RenderRefreshIcon();
            refreshWasRendered = true;
        }

        UI::TableNextRow();
        UI::TableNextColumn();
        if(showMapAuthor){
            UI::Text(greyColor4 + "Made by " + Text::StripFormatCodes(app.RootMap.MapInfo.AuthorNickName));
        }
        UI::TableNextColumn();
        UI::TableNextColumn();
        // if the refresh icon wasn't rendered, we render it here (for better alignment)
        if(!refreshWasRendered && (showMapAuthor || showPlayerCountEnabled)){
            RenderRefreshIcon();
            refreshWasRendered = true;
        }
    }

    if(showPlayerCountEnabled && playerCount != -1){
        // set the text to be on the right
        UI::TableNextColumn();
        // if player count is above 100k, we display it as <100k
        string playerCountStr = NumberToString(playerCount);
        playerCountStr = playerCount > 100000 ? "<" + playerCountStr : playerCountStr;
        UI::Text(playerIconGrey + " " + playerCountStr);
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

void RenderHeaders(bool showRefresh = false){
    UI::TableNextRow();
    // Icon
    UI::TableNextColumn();
    // Position
    UI::TableNextColumn();
    UI::Text("Position");
    // Time
    UI::TableNextColumn();
    switch(currentMode){
        case EnumCurrentMode::RACE:
            UI::Text("Time");
            break;
        case EnumCurrentMode::STUNT:
            UI::Text("Score");
            break;
        default:
            UI::Text("INVALID");
            break;
    }
    // Desc
    UI::TableNextColumn();
    // %
    if(showPercentage){
        UI::TableNextColumn();
        UI::Text("%");
    }
    // Time diff
    if(showTimeDifference){
        UI::TableNextColumn();
    }
    if(showRefresh){
        RenderRefreshIcon();
    }
    UI::TableNextColumn();

}

/**
 * Render the table with the custom leaderboard
 */
void RenderTab(bool showRefresh = false){
    int columnCount = 4;
    if(showPercentage){
        columnCount++;
    }
    if(showTimeDifference){
        columnCount++;
    }
    UI::BeginTable("Main", columnCount);

    if(showTableHeaders){
        RenderHeaders(showRefresh);
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

        // If the PB happens to be exactly a configured Position and we are displaying PB,
        // then skip the Position record because it's essentially the same entry.
        // (This doesn't affect ties becuase the positions would be different in that case e.g. Position record at 10 and tied PB at 11.)
        if (leaderboardArray[i].entryType == EnumLeaderboardEntryType::POSITION && leaderboardArray[i].customEquals(currentPbEntry) && showPb) {
            i++;
            continue;
        }
        // Note the above position skip logic doesn't apply to medals since we still want to show the medal description

        // If the current record is a medal one, we make a display string based on the display mode
        string displayString = leaderboardArray[i].positionData.textColor.Replace("Custom", "");

        //------------POSITION ICON--------
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text(leaderboardArray[i].positionData.GetColorIcon());

        //------------POSITION-------------
        UI::TableNextColumn();
        if(leaderboardArray[i].position <= 0){
            UI::Text(displayString + "-");
        }else if(leaderboardArray[i].position > 100000){
            UI::Text(displayString + "<" + NumberToString(leaderboardArray[i].position));
        }else{
            UI::Text(displayString + "" + NumberToString(leaderboardArray[i].position));
        }

        //------------TIME/SCORE-----------------
        UI::TableNextColumn();
        UI::Text(displayString + formatTimeScore(leaderboardArray[i].time));

        //------------HAS DESC-------------
        UI::TableNextColumn();
        if(leaderboardArray[i].desc != ""){
            UI::Text(displayString + leaderboardArray[i].desc);
        }

        //------------%--------------------
        if(showPercentage){
            UI::TableNextColumn();
            if(leaderboardArray[i].percentage != 0.0f){
                UI::Text(displayString + leaderboardArray[i].percentageDisplay);
            }
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
                string timeDifferenceString = formatTimeScore(Math::Abs(timeDifference));

                if(inverseTimeDiffSign){
                    if(timeDifference < 0){
                        UI::Text((showColoredTimeDifference ? redColor : "") + "+" + timeDifferenceString);
                    }else{
                        UI::Text((showColoredTimeDifference ? blueColor : "") + "\u2212" + timeDifferenceString);
                    }
                }else{
                    if(timeDifference < 0){
                        UI::Text((showColoredTimeDifference ? blueColor : "") + "\u2212" + timeDifferenceString);
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