// File containing the main functions of the plugin (main loop and the function to refresh the leaderboard)

void RefreshLeaderboard(){
    auto startTime = Time::get_Now();
    int lastPbTime = currentPbTime;
    //No need to make this a coroutine since it is needed before executing the rest of the refresh
    LeaderboardEntry@ pbTimeTmp = GetPersonalBestEntry();

    if(pbTimeTmp.time == lastPbTime) {
        counterTries++;
        if(counterTries > maxTries) {
            print("Failed to refresh the leaderboard " + maxTries + " times, stopping the refresh. Time spent : " + (Time::get_Now() - startTime) + "ms");
            failedRefresh = true;
        }
        // we still want to try and get the other times
        if(counterTries > 1) {
            print("Failed to refresh the leaderboard " + counterTries + " times. Time spent : " + (Time::get_Now() - startTime) + "ms");
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
        medalEntries[0].desc = "AT";
        medalEntries[1].desc = "Gold";
        medalEntries[2].desc = "Silver";
        medalEntries[3].desc = "Bronze";

        // Insert all entries in our temporary entry array
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

#if DEPENDENCY_CHAMPIONMEDALS
        // We check all the pb entries :
        // There is either one or two entries. We check if the time of them is equal to the champion time. If only one of them is, we change its type to MEDAL, and the other to PB
        // If both are, we sort them and change the first one to MEDAL and the second one to PB, since either they're both the same, or the medal if the "first" to have the medal
        int championTime = ChampionMedals::GetCMTime();
        if(championTime != 0){
            array<LeaderboardEntry@> pbEntries;
            for(uint i = 0; i< leaderboardArrayTmp.Length; i++){
                if(leaderboardArrayTmp[i].entryType == EnumLeaderboardEntryType::PB){
                    pbEntries.InsertLast(leaderboardArrayTmp[i]);
                }
            }
            if(pbEntries.Length == 1){
                if(pbEntries[0].time == championTime){
                    pbEntries[0].entryType = EnumLeaderboardEntryType::MEDAL;
                    pbEntries[0].desc = "Champion";
                }
            }else if(pbEntries.Length == 2){
                pbEntries.SortAsc();
                if(pbEntries[0].time == championTime){
                    pbEntries[0].entryType = EnumLeaderboardEntryType::MEDAL;
                    pbEntries[0].desc = "Champion";
                    pbEntries[1].entryType = EnumLeaderboardEntryType::PB;
                    pbEntries[1].desc = "PB";
                }
            }
        }
#endif
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
    print("Refreshed the leaderboard in " + (Time::get_Now() - startTime) + "ms");
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