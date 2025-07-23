// File containing the main functions of the plugin (main loop and the function to refresh the leaderboard)

void RefreshLeaderboard(){
    auto startTime = Time::get_Now();

    // 3-stage update
    // Stage 1: New local PB, not queried API yet. Update leaderboard with PB with empty position and re-sort by time.
    // Stage 2: Get PB position from API. May be delayed (reports the old PB) so retry if necessary up to max.
    // Stage 3: Get all remainaing positions from API.

    if (currentTimePbLocal > 0 && (currentTimePbLocal < currentPbEntry.time || currentPbEntry.time <= 0)) {
        // Stage 1: New local PB, not queried API yet. Update leaderboard with PB with empty position and re-sort by time.
        trace("RefreshLeaderboard(): updating leaderboard PB time from " + TimeLogString(currentPbEntry.time) + " to " + TimeLogString(currentTimePbLocal));
        LeaderboardEntry@ localPbEntry = LeaderboardEntry();
        localPbEntry.time = currentTimePbLocal;
        localPbEntry.position = -1;
        localPbEntry.entryType = EnumLeaderboardEntryType::PB;
        localPbEntry.desc = "PB";
        localPbEntry.positionData = currentPbPositionData;

        leaderboardArrayTmp = array<LeaderboardEntry@>();
        leaderboardArrayTmp.InsertLast(localPbEntry);
        // Fill non-PB entries from previous leaderboard
        for (uint i = 0; i < leaderboardArray.Length; i++) {
            if (leaderboardArray[i].entryType != EnumLeaderboardEntryType::PB)
                leaderboardArrayTmp.InsertLast(leaderboardArray[i]);
        }
        UpdateTimeDifferenceEntry(leaderboardArrayTmp);
        switch(currentMode){
            case EnumCurrentMode::RACE:
                leaderboardArrayTmp.SortAsc();
                break;
            case EnumCurrentMode::STUNT:
                leaderboardArrayTmp.SortDesc();
                break;
            default:
                break;
        };
        leaderboardArray = leaderboardArrayTmp;

        currentPbEntry = localPbEntry;
        yield();
    }

    if (currentPbEntry.time > 0) { // only run if we have a valid PB time on the leaderboard (e.g. not on unplayed map)
        // Stage 2: Get PB position from API. May be delayed (reports the old PB) so retry if necessary up to max.
        auto counterTries = 0;
        auto retryStartTime = Time::get_Now();
        auto retryElapsedTime = 0;
        auto retrySuccess = false;
        while (counterTries < maxTries && retryElapsedTime < retryTimeLimit) {
            counterTries++;
            // progressively longer delay to give more time for retries when API is slow to update
            auto sleepDelay = counterTries * 100;
            trace("RefreshLeaderboard(): PB API attempt " + counterTries + " at " + retryElapsedTime + "ms: sleeping " + sleepDelay + "ms to give API time to update");
            sleep(sleepDelay);

            // if something cleared refreshPosition while we were yielding/sleeping (e.g. exited map), abort the refresh
            if (!refreshPosition)
                return;

            LeaderboardEntry@ apiPbEntry = GetPersonalBestEntry();

            if ((currentMode == EnumCurrentMode::RACE && apiPbEntry.time > 0 && apiPbEntry.time <= currentPbEntry.time)
                || (currentMode == EnumCurrentMode::STUNT && apiPbEntry.time > 0 && apiPbEntry.time >= currentPbEntry.time)) {
                trace("RefreshLeaderboard(): received valid API PB time " + TimeLogString(apiPbEntry.time) + ", position " + apiPbEntry.position);
                currentPbEntry = apiPbEntry;
                // don't add to leaderboard yet, stage 3 will do it
                retrySuccess = true;
                break;
            } else {
                trace("RefreshLeaderboard(): received invalid API PB time " + TimeLogString(apiPbEntry.time) + " behind leaderboard PB time " + TimeLogString(currentPbEntry.time));
            }

            retryElapsedTime = Time::get_Now() - retryStartTime;
        }
        if (!retrySuccess) {
            if (forceRefreshAfterSurroundFail) {
                print("RefreshLeaderboard(): Failed to refresh the online PB " + counterTries + " times in " + retryElapsedTime + "ms. We don't fail the refresh for now, might be because of the surround endpoint changes.");
                trace("Fallback: call surround with the local pb time");
                LeaderboardEntry@ tmpEntry = GetSpecificPositionEntry(currentTimePbLocal);
                if (tmpEntry !is null && tmpEntry.isValid()){
                    // Fake the position to be the PB position
                    tmpEntry.entryType = EnumLeaderboardEntryType::PB;
                    tmpEntry.desc = "PB";
                    tmpEntry.positionData = currentPbPositionData;
                    currentPbEntry = tmpEntry;
                }
            } else {
                print("RefreshLeaderboard(): Failed to refresh the online PB " + counterTries + " times in " + retryElapsedTime + "ms, stopping the PB refresh.");
                failedRefresh = true;
            }
        }
        yield();
    }

    // Stage 3: Get all remaining positions from API.
    trace("RefreshLeaderboard(): getting all positions from API");

    leaderboardArrayTmp = array<LeaderboardEntry@>();
    leaderboardArrayTmp.InsertLast(currentPbEntry);

    // Declare the response here to access it from the logging part later.
    ExtraLeaderboardAPI::ExtraLeaderboardAPIResponse@ respLog = ExtraLeaderboardAPI::ExtraLeaderboardAPIResponse();
    // if activated, call the extra leaderboardAPI
    if(ExtraLeaderboardAPI::Active && useExternalAPI && !ExtraLeaderboardAPI::failedAPI){

        bool needPlayerCount = showPlayerCount || showPercentage;
        bool getMapInfo = showMedals && ( showAT || showGold || showSilver || showBronze);
        ExtraLeaderboardAPI::ExtraLeaderboardAPIRequest@ req = null;
        try
        {
           @req = ExtraLeaderboardAPI::PrepareRequest(needPlayerCount, getMapInfo);
        }
        catch
        {
            // we can assume that something went wrong while trying to prepare the request. We abort the refresh and try again later
            // also warn in the log that something went wrong
            warn("Something went wrong while trying to prepare the request. Aborting the refresh and trying again later");
            warn("Error message : " + getExceptionInfo());
            failedRefresh = true;
            return;
        }

        array<string> processedAccountIds = {};
        array<LeaderboardEntry@> clubEntries;
        string currentUserId = cast<CTrackMania@>(GetApp()).LocalPlayerInfo.WebServicesUserId;
        // Insert the club leaderboard entries
        for(uint i = 0; i < allClubData.Length; i++){
            Json::Value@ clubLeaderboard = ClubLeaderboardAPI::GetClubLeaderboard(allClubData[i].position, currentMapUid);
            for (int j = 0; j < clubLeaderboard.Length; j++) {
                if (clubLeaderboard[j]["accountId"] == currentUserId) {
                    continue;
                }
                LeaderboardEntry@ tmpEntry = LeaderboardEntry();
                tmpEntry.time = clubLeaderboard[j]["score"];
                tmpEntry.desc = clubLeaderboard[j]["username"];
                tmpEntry.entryType = EnumLeaderboardEntryType::CLUB;
                tmpEntry.positionData = allClubData[i];

                if (processedAccountIds.Find(clubLeaderboard[j]["accountId"]) != -1) {
                    continue;
                }
                req.scores.InsertLast(tmpEntry.time);
                processedAccountIds.InsertLast(clubLeaderboard[j]["accountId"]);
                clubEntries.InsertLast(tmpEntry);
            }
        }

        ExtraLeaderboardAPI::ExtraLeaderboardAPIResponse@ resp = ExtraLeaderboardAPI::GetExtraLeaderboard(req);

        // We extract the times from the response if there's any
        if(resp is null){
            warn("response from ExtraLeaderboardAPI is null or empty");
            return;
        }

        respLog = resp;

        // if there's a player count, try to extract it and set the player count
        if(needPlayerCount && resp.playerCount > 0){
            playerCount = resp.playerCount;
        } else {
            playerCount = -1;
        }

        // extract the medal entries
        array<LeaderboardEntry@> medalEntries;
        for(uint i = 0; i< resp.positions.Length; i++){
            if(resp.positions[i].entryType != EnumLeaderboardEntryType::MEDAL){
                continue;
            }
            medalEntries.InsertLast(resp.positions[i]);
        }
        // sort the medal entries then add the description to them
        medalEntries.SortAsc();

        array<string> medalDesc = {};
        array<int> medalScores = {};
        array<PositionData@> medalPositionData = {};
        // only add the medal description if the associated medal is activated
        if(showAT){
            medalDesc.InsertLast("AT");
            medalPositionData.InsertLast(atPositionData);
            medalScores.InsertLast(resp.authorTime);
        }
        if(showGold){
            medalDesc.InsertLast("Gold");
            medalPositionData.InsertLast(goldPositionData);
            medalScores.InsertLast(resp.goldTime);
        }
        if(showSilver){
            medalDesc.InsertLast("Silver");
            medalPositionData.InsertLast(silverPositionData);
            medalScores.InsertLast(resp.silverTime);
        }
        if(showBronze){
            medalDesc.InsertLast("Bronze");
            medalPositionData.InsertLast(bronzePositionData);
            medalScores.InsertLast(resp.bronzeTime);
        }

        // Invert order if we are in stunt mode
        if(currentMode == EnumCurrentMode::STUNT){
            medalDesc.Reverse();
            medalPositionData.Reverse();
        }

        for(uint i = 0; i< medalEntries.Length; i++){
            medalEntries[i].desc = medalDesc[i];
            medalEntries[i].positionData = medalPositionData[i];
            // re-set the time to the one from the API
            // this is important because times might have bogus values when they're secret medals
            medalEntries[i].time = medalScores[i];
        }

        // Track which medals have been found (indexed by medal type, only for custom medals)
        uint customMedalStart = MedalType::AT + 1;
        array<bool> medalFound(MedalType::COUNT - customMedalStart, false);

        // Insert all entries in our temporary entry array
        for(uint i = 0; i < resp.positions.Length; i++){
            if (resp.positions[i].time == -1)
                continue;

            bool alreadyHandled = false;

            // Try to process each special medal type using the handlers
            for (uint medalType = customMedalStart; medalType < MedalType::COUNT; medalType++) {
                uint medalIndex = medalType - customMedalStart;
                if (!medalFound[medalIndex] && !alreadyHandled) {
                    auto handler = GetMedalHandler(MedalType(medalType));
                    medalFound[medalIndex] = TryProcessMedalWithHandler(resp.positions[i], handler);
                    alreadyHandled = medalFound[medalIndex];
                }
            }

            // Update positions for club members
            for (uint j = 0; j < clubEntries.Length; j++) {
                if (clubEntries[j].time == resp.positions[i].time) {
                    resp.positions[i].positionData = clubEntries[j].positionData;
                    resp.positions[i].desc = clubEntries[j].desc;
                    alreadyHandled = true;
                    break;
                }
            }

            // every special cases should be handled before this point
            // now, we match the remaining entries with their position data
            for(uint j = 0; j< allPositionData.Length; j++){
                if(alreadyHandled){
                    break;
                }
                if(int(allPositionData[j].position) == resp.positions[i].position){
                    resp.positions[i].positionData = allPositionData[j];
                    break;
                }
            }
            leaderboardArrayTmp.InsertLast(resp.positions[i]);
        }
    } else {
        // can't get the player count if we don't use the external API, so we set it to -1
        playerCount = -1;

        // Make all the request in local (apart from impossible calls like medals above pb)
        array<awaitable@> coroutines;
        for(uint i = 0; i< allPositionData.Length; i++){
            auto timeEntryFunc = startnew(SpecificTimeEntryCoroutine, Integer(allPositionData[i].position));
            coroutines.InsertLast(timeEntryFunc);
        }
        auto medalEntryFunc = startnew(AddMedalsEntriesCoroutine);
        coroutines.InsertLast(medalEntryFunc);

        await(coroutines);
    }

    if(showPercentage && playerCount > 0){
        for(uint i = 0; i< leaderboardArrayTmp.Length; i++){
            leaderboardArrayTmp[i].percentage = ((100.0f * leaderboardArrayTmp[i].position) / playerCount);
            if(leaderboardArrayTmp[i].percentage % 1 == 0) {
                leaderboardArrayTmp[i].percentageDisplay = Text::Format("%.0f%%", leaderboardArrayTmp[i].percentage);
            }
            else {
                leaderboardArrayTmp[i].percentageDisplay = Text::Format("%.02f%%", leaderboardArrayTmp[i].percentage);
            }
        }
    }

    UpdateTimeDifferenceEntry(leaderboardArrayTmp);
    switch(currentMode){
        case EnumCurrentMode::RACE:
            leaderboardArrayTmp.SortAsc();
            break;
        case EnumCurrentMode::STUNT:
            leaderboardArrayTmp.SortDesc();
            break;
        default:
            break;
    }
    leaderboardArray = leaderboardArrayTmp;

    try{
        RefreshUME();
    }
    catch {
        error("Error while refreshing Ultimate Medals Extended: " + getExceptionInfo());
        // we don't fail the refresh, but we log the error
    }

    string RefreshEndMessage = "Refreshed the leaderboard in " + (Time::get_Now() - startTime) + "ms";
    if(ExtraLeaderboardAPI::Active && useExternalAPI && !ExtraLeaderboardAPI::failedAPI){
        RefreshEndMessage += " (using the external API, with request id : " + respLog.requestID +  ")";
    } else {
        RefreshEndMessage += " (using local Nadeo API calls)";
    }

    print(RefreshEndMessage);
}


/**
 * Try to process a medal using a medal handler.
 * @param entry The leaderboard entry to process
 * @param handler The medal handler to use
 * @return true if the entry was processed as this medal type
 */
bool TryProcessMedalWithHandler(LeaderboardEntry@ entry, MedalHandler@ handler) {
    if (entry.entryType == EnumLeaderboardEntryType::TIME) {
        try {
            int medalTime = handler.GetMedalTime();
            if (entry.time == medalTime) {
                entry.entryType = EnumLeaderboardEntryType::MEDAL;
                entry.desc = handler.GetDesc();
                entry.positionData = handler.GetPositionData();
                return true;
            }
        } catch {
            warn("Error getting " + handler.GetDesc() + " medal time: " + getExceptionInfo());
        }
    }
    return false;
}


/**
 * Hack class to be able to have handles
 */
class Integer{
    int value;
    Integer(int value){
        this.value = value;
    }
}


void SpecificTimeEntryCoroutine(ref@ position){
    // cast ref to Integer
    Integer@ positionInt = cast<Integer@>(position);
    LeaderboardEntry@ timeEntry = GetSpecificTimeEntry(positionInt.value);
    if(timeEntry !is null && timeEntry.isValid()){
        leaderboardArrayTmp.InsertLast(timeEntry);
    }
}


void AddMedalsEntriesCoroutine(){
    array<LeaderboardEntry@> entries = GetMedalsEntries();
    for(uint i = 0; i< entries.Length; i++){
        if(entries[i] !is null && entries[i].isValid()){
            leaderboardArrayTmp.InsertLast(entries[i]);
        }
    }
}


void UpdateTimeDifferenceEntry(array<LeaderboardEntry@> arrayTmp) {
    if (currentComboChoice == -1) {
        // timeDifferenceEntry is the entry that has entryType Pb
        for (uint i = 0; i < arrayTmp.Length; i++) {
            if (arrayTmp[i].entryType == EnumLeaderboardEntryType::PB) {
                timeDifferenceEntry = arrayTmp[i];
                break;
            }
        }
    } else {
        timeDifferenceEntry.time = -1;
        timeDifferenceEntry.position = -1;
        timeDifferenceEntry.entryType = EnumLeaderboardEntryType::POSITION; // Doesn't really matter since it isn't checked
        for (uint i = 0; i < arrayTmp.Length; i++) {
            if (arrayTmp[i].position == currentComboChoice && arrayTmp[i].entryType == EnumLeaderboardEntryType::POSITION) {
                timeDifferenceEntry = arrayTmp[i];
                break;
            }
        }
    }
}


void UpdateCurrentMode() {
    // find the current mode (stunt or some race gamemode)
    auto app = GetApp();
    auto map = app.RootMap;
    auto mapInfo = map.MapInfo;
    string mapType = mapInfo.MapType;

    if(mapType == "TrackMania\\TM_Race"){
        currentMode = EnumCurrentMode::RACE;
    } else if(mapType == "TrackMania\\TM_Stunt"){
        currentMode = EnumCurrentMode::STUNT;
    } else if(mapType == "TrackMania\\TM_Platform"){
        currentMode = EnumCurrentMode::PLATFORM;
    } else {
        currentMode = EnumCurrentMode::INVALID;
    }
}