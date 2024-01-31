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

        leaderboardArrayTmp = array<LeaderboardEntry@>();
        leaderboardArrayTmp.InsertLast(localPbEntry);
        // Fill non-PB entries from previous leaderboard
        for (uint i = 0; i < leaderboardArray.Length; i++) {
            if (leaderboardArray[i].entryType != EnumLeaderboardEntryType::PB)
                leaderboardArrayTmp.InsertLast(leaderboardArray[i]);
        }
        UpdateTimeDifferenceEntry(leaderboardArrayTmp);
        leaderboardArrayTmp.SortAsc();
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

            if (apiPbEntry.time > 0 && apiPbEntry.time <= currentPbEntry.time) {
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
            print("RefreshLeaderboard(): Failed to refresh the online PB " + counterTries + " times in " + retryElapsedTime + "ms, stopping the PB refresh.");
            failedRefresh = true;
        }
    }

    // Stage 3: Get all remaining positions from API.
    trace("RefreshLeaderboard(): getting all positions from API");

    leaderboardArrayTmp = array<LeaderboardEntry@>();
    leaderboardArrayTmp.InsertLast(currentPbEntry);

	// Make all the request in local (apart from impossible calls like medals above pb)
	array<Meta::PluginCoroutine@> coroutines;
	auto friendEntryFunc = startnew(FriendsEntryCoroutine);
	coroutines.InsertLast(friendEntryFunc);

	await(coroutines);

    UpdateTimeDifferenceEntry(leaderboardArrayTmp);
    leaderboardArrayTmp.SortAsc();
    leaderboardArray = leaderboardArrayTmp;

    print("Refreshed the leaderboard in " + (Time::get_Now() - startTime) + "ms (using local Nadeo API calls)");
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

void FriendsEntryCoroutine(){
    array<LeaderboardEntry@> entries = GetFriendsEntry(allFriendsToGetStringSave);
    for(uint i = 0; i< entries.Length; i++){
        if(entries[i] !is null && entries[i].isValid()){
            leaderboardArrayTmp.InsertLast(entries[i]);
        }
    }
}

void UpdateTimeDifferenceEntry(array<LeaderboardEntry@> arrayTmp) {
	// timeDifferenceEntry is the entry that has entryType Pb
	for (uint i = 0; i < arrayTmp.Length; i++) {
		if (arrayTmp[i].entryType == EnumLeaderboardEntryType::PB) {
			timeDifferenceEntry = arrayTmp[i];
			break;
		}
	}
}
