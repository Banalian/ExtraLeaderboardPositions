// File containing the main functions of the plugin (main loop and the function to refresh the leaderboard)

void RefreshLeaderboard(){
    int lastPbTime = currentPbTime;
    //No need to make this a coroutine since it is needed before executing the rest of the refresh
    LeaderboardEntry@ pbTimeTmp = GetPersonalBestEntry();

    if(pbTimeTmp.time == lastPbTime) {
        counterTries++;
        if(counterTries > maxTries) {
            print("Failed to refresh the leaderboard " + maxTries + " times, stopping the refresh");
            failedRefresh = true;
        }
        // we still want to try and get the other times
        if(counterTries > 1) {
            return;
        }
        
    } else {
        counterTries = 0;
    }

    leaderboardArrayTmp = array<LeaderboardEntry@>();

    // if activated, call the extra leaderboardAPI
    if(ExtraLeaderboardAPI::Active && useExternalAPI){
        ExtraLeaderboardAPI::ExtraLeaderboardAPIRequest@ req = ExtraLeaderboardAPI::PrepareRequest(true, true);

        ExtraLeaderboardAPI::ExtraLeaderboardAPIResponse@ resp = ExtraLeaderboardAPI::GetExtraLeaderboard(req);

        // We extract the times from the response if there's any
        if(resp is null){
            warn("response from ExtraLeaderboardAPI is null or empty");
            return;
        }

        for(uint i = 0; i< resp.positions.Length; i++){
            if(resp.positions[i].time == -1){
                continue;
            }
            // For now, we assume that if the entry type is TIME, it's the pb, so we change it's type to PB
            if(resp.positions[i].entryType == EnumLeaderboardEntryType::TIME){
                resp.positions[i].entryType = EnumLeaderboardEntryType::PB;
                resp.positions[i].desc = "PB";
            }
            leaderboardArrayTmp.InsertLast(resp.positions[i]);
        }
    } else {    
        leaderboardArrayTmp.InsertLast(pbTimeTmp);
        // Make all the request in local (apart from impossible calls like medals above pb)
        array<Meta::PluginCoroutine@> coroutines;
        for(uint i = 0; i< allPositionToGet.Length; i++){
            auto timeEntryFunc = startnew(SpecificTimeEntryCoroutine, Integer(allPositionToGet[i]));
            coroutines.InsertLast(timeEntryFunc);
        }
        auto medalEntryFunc = startnew(AddMedalsEntriesCoroutine);
        coroutines.InsertLast(medalEntryFunc);

        await(coroutines);
    }

    // Time difference entry finding
    if(currentComboChoice == -1){
        // timeDifferenceEntry is the entry that has entryType Pb
        for(uint i = 0; i< leaderboardArrayTmp.Length; i++){
            if(leaderboardArrayTmp[i].entryType == EnumLeaderboardEntryType::PB){
                timeDifferenceEntry = leaderboardArrayTmp[i];
                break;
            }
        }
    }else{
        timeDifferenceEntry.time = -1;
        timeDifferenceEntry.position = -1;
        timeDifferenceEntry.entryType = EnumLeaderboardEntryType::POSITION; // Doesn't really matter since it isn't checked
        for(uint i = 1; i< leaderboardArrayTmp.Length; i++){
            if(leaderboardArrayTmp[i].position == currentComboChoice){
                timeDifferenceEntry = leaderboardArrayTmp[i];
                break;
            }
        }
    }

    //sort the array
    leaderboardArrayTmp.SortAsc();
    leaderboardArray = leaderboardArrayTmp;
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

void SpecificPositionEntryCoroutine(ref@ time){
    // cast ref to Integer
    Integer@ timeInt = cast<Integer@>(time);
    LeaderboardEntry@ positionEntry = GetSpecificPositionEntry(timeInt.value);
    if(positionEntry !is null && positionEntry.isValid()){
        leaderboardArrayTmp.InsertLast(positionEntry);
    }
}