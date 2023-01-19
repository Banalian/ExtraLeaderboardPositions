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
        windowFlags |= UI::WindowFlags::NoInputs;
    }

    if(cutoffArray.Length == 0 && !failedRefresh){
        return;
    }

    //if this is true, we're probably on a map not uploaded to nadeo's server. we don't want to show the window
    if(cutoffArray.Length == 1 && cutoffArray[0].position == -1){
        return;
    }

    //we don't want to show the window if we're in the editor
    if(app.Editor !is null){
        return;
    }
        

    if(windowVisible && app.CurrentPlayground !is null){
        UI::Begin(pluginName, windowFlags);

        UI::BeginGroup();

        UI::Text("Extra leaderboard positions");
        
        if(showSeparator){
            UI::Separator();
        }

        if(app.RootMap !is null){
            if(showMapName){
                UI::Text(StripFormatCodes(app.RootMap.MapInfo.Name));
            }

            if(showMapAuthor){
                UI::Text(brightGreyColor + "Made by " + StripFormatCodes(app.RootMap.MapInfo.AuthorNickName));
            }
        }

        

        RenderTab();

        RenderRefreshButton();

        UI::EndGroup();

        UI::End();
    }
}

// Render the table with the custom leaderboard
void RenderTab(){
    UI::BeginTable("Main", 5);        
    
    UI::TableNextRow();
    UI::TableNextColumn();
    UI::TableNextColumn();
    UI::Text("Position");
    UI::TableNextColumn();
    UI::Text("Time");
    UI::TableNextColumn();
    UI::TableNextColumn();
    if(refreshPosition){
        UI::Text("Refreshing...");
    }else if(failedRefresh){
        UI::Text("Refreshing failed.");
    }

    int i = 0;
    while(i < int(cutoffArray.Length)){
            //We skip the pb if there's none
        if( (cutoffArray[i].pb && cutoffArray[i].time == -1) || (!showPb && cutoffArray[i].pb) ){
            i++;
            continue;
        }

        // If the current record is a medal one, we make a display string based on the display mode
        string displayString = "";

        if(cutoffArray[i].isMedal){
            switch(medalDisplayMode){
                case EnumDisplayMedal::NORMAL:
                    break;
                case EnumDisplayMedal::IN_GREY:
                    displayString = greyColor;
                    break;                   
                default:
                    break;
            }
        }

        //------------POSITION ICON--------
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text(GetIconForPosition(cutoffArray[i].position));
        
        //------------POSITION-------------
        UI::TableNextColumn();
        if(cutoffArray[i].position > 10000){
            UI::Text(displayString + "<" + cutoffArray[i].position);
        }else{
            UI::Text(displayString + "" + cutoffArray[i].position);
        }
        
        //------------TIME-----------------
        UI::TableNextColumn();
        UI::Text(displayString + TimeString(cutoffArray[i].time));

        //------------HAS DESC-------------
        UI::TableNextColumn();
        if(cutoffArray[i].desc != ""){
            UI::Text(displayString + cutoffArray[i].desc);
        }
        
        //------------TIME DIFFERENCE------
        UI::TableNextColumn();

        if(showTimeDifference){
            if(cutoffArray[i].time == -1 || timeDifferenceCutoff.time == -1){
                //Nothing here, no time to compare to
            }else if(cutoffArray[i].position == timeDifferenceCutoff.position){
                //Nothing here, the position is the same, it's the same time
                //still keeping the if in case we want to print/add something here
            }else{
                int timeDifference = cutoffArray[i].time - timeDifferenceCutoff.time;
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

// Render the refresh button after we check if it's visible
void RenderRefreshButton(){
    if(showRefreshButtonSetting && UI::IsOverlayShown()){
        if(UI::Button("Refresh")){
            ForceRefresh();
        }
    }
}
