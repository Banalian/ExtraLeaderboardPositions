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
            timePbLocal = scoreMgr.Map_GetRecord_v2(userId, app.RootMap.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
        }

		
        // if the map change, or the timer is over or a new pb is found, we refresh the positions
        if (mapIdChanged || timer > updateFrequency || newPBSet(timePbLocal)) {
            currentMapUid = app.RootMap.MapInfo.MapUid;
            refreshPosition = true;
            timer = 0;
        } else {
            timer += dt;
        }
    }else{
        timer = 0;
        currentMapUid = "";
    }
    
}

bool newPBSet(int timePbLocal) {
    bool isLocalPbDifferent = timePbLocal != currentPbTime;
    if(isLocalPbDifferent){
        if(timePbLocal == -1){
            return false;
        }
        if(currentPbTime == -1){
            return true;
        }
        if(timePbLocal < currentPbTime){
            return true;
        }else{
            return false;
        }
    }else{
        return false;
    }
}