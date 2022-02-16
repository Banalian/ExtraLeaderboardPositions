// ############################## MENU #############################

void RenderMenu() {
    if (UI::MenuItem(pluginName)) {
        windowVisible = !windowVisible;
    }
}

// ############################## WINDOW RENDER #############################

void Render() {

    if(!UserCanUseThePlugin()){
        warn("You don't have the permissions to use this plugin, you at least need the standard edition");
        return;
    }


    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;

    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoInputs;
    }

    if(cutoffArray.Length == 0){
        return;
    }

    //if this is true, we're probably on a map not uploaded to nadeo's server. we don't want to show the window
    if(cutoffArray.Length == 1 && cutoffArray[0].position == -1){
        return;
    }
        

    if(windowVisible && app.CurrentPlayground !is null){
        UI::Begin(pluginName, windowFlags);

        UI::BeginGroup();

        UI::Text("Extra leaderboard positions");
        
        UI::BeginTable("Main", 5);        

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::TableNextColumn();
        UI::Text("Position");
        UI::TableNextColumn();
        UI::Text("Time");
        if(refreshPosition){
            UI::TableNextColumn();
            UI::TableNextColumn();
            UI::Text("Refresing...");
        }

        int i = 0;
        while(i < int(cutoffArray.Length)){
            //We skip the pb if there's none
            if( (cutoffArray[i].pb && cutoffArray[i].time == -1) || (!showPb && cutoffArray[i].pb) ){
                i++;
                continue;
            }

            //------------POSITION ICON--------
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(GetIconForPosition(cutoffArray[i].position));
            
            //------------POSITION-------------
            UI::TableNextColumn();
            if(cutoffArray[i].position > 10000){
                UI::Text("<" + cutoffArray[i].position);
            }else{
                UI::Text(""+ cutoffArray[i].position);
            }
            
            //------------TIME-----------------
            UI::TableNextColumn();
            UI::Text(TimeString(cutoffArray[i].time));

            //------------IS PB----------------
            UI::TableNextColumn();
            if(cutoffArray[i].pb){
                UI::Text("PB");
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
                    if(inverseTimeDiffSign){
                        if(timeDifference < 0){
                            UI::Text("+" + TimeString(Math::Abs(timeDifference)));
                        }else{
                            UI::Text("-" + TimeString(timeDifference));
                        }
                    }else{
                        if(timeDifference < 0){
                            UI::Text("-" + TimeString(Math::Abs(timeDifference)));
                        }else{
                            UI::Text("+" + TimeString(timeDifference));
                        }
                    }
                }

            }
            

            i++;
            
        }

        UI::EndTable();

        UI::EndGroup();

        UI::End();
    }
}