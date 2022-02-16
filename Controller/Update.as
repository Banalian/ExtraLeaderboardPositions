// ############################## TICK UPDATE #############################

void Update(float dt) {

    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    
    //check if we're in a map
    if(app.CurrentPlayground !is null && network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.Playground.Map !is null){
        bool mapIdChanged = currentMapUid != app.RootMap.MapInfo.MapUid;
        auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;

        //get the current map pb
        int timePbLocal = scoreMgr.Map_GetRecord_v2(network.PlayerInfo.Id, app.RootMap.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");
		
        // if the map change, or the timer is over or a new pb is found, we refresh the positions
        if (mapIdChanged || timer > updateFrequency || timePbLocal != currentPbTime) {
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