// ############################## TICK UPDATE #############################

void Update(float dt) {

    if(timerStartDelay > 0){
        timerStartDelay -= dt;
        if(!startupEnded){
            return;
        }
    }

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    //check if we're in a map
    if(app.CurrentPlayground !is null && network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        bool mapIdChanged = currentMapUid != app.RootMap.MapInfo.MapUid;
        auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;

        int timePbLocal = -1;

        //get the user id
        if(network.ClientManiaAppPlayground.UserMgr.Users.Length != 0){
            auto userId = network.ClientManiaAppPlayground.UserMgr.Users[0].Id;
            //get the current map pb
            string mode = currentMode == EnumCurrentMode::STUNT ? "Stunt" : "TimeAttack";
            timePbLocal = scoreMgr.Map_GetRecord_v2(userId, app.RootMap.MapInfo.MapUid, "PersonalBest", "", mode, "");
        }

        if (timePbLocal > 0 && currentTimePbLocal != timePbLocal) {
            currentTimePbLocal = timePbLocal;
            trace("Update(): new PB: " + TimeLogString(currentTimePbLocal));
        }

        //if the map change, or the timer is over or a new pb is found, we refresh the positions
        if (mapIdChanged) {
            currentMapUid = app.RootMap.MapInfo.MapUid;
            trace("Update(): new map uid: " + currentMapUid);
            playerCount = -1;
            UpdateCurrentMode();
            ClearLeaderboard();
            ForceRefresh();
        } else if (NewPBSet(currentTimePbLocal) || timer > updateFrequency) {
            ForceRefresh();
        } else {
            timer += dt;
        }
    } else {
        timer = 0;
        currentMapUid = "";
        refreshPosition = false;
        currentTimePbLocal = -1;
        ClearLeaderboard();
    }

    // update the config timer
    timerOPConfig += dt;
    if(timerOPConfig > updateFrequencyOPConfig){
        timerOPConfig = 0;
        refreshOPConfig = true;
    }

    // update the loading step timer if we're refreshing the positions
    if(refreshPosition){
        loadingStepTimer += dt;
        if(loadingStepTimer > loadingStepDuration){
            loadingStepTimer = 0;
            currentLoadingStep++;
            if(currentLoadingStep > loadingSteps.Length - 1){
                currentLoadingStep = 0;
            }
        }
    }

}