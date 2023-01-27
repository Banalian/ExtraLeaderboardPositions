// File containing various unrelated functions that are general enough.

bool isAValidMedalTime(LeaderboardEntry@ time) {
    if(time.position == -1 && time.time == -1) {
        return false;
    }

    if(time.position == currentPbPosition && time.time == currentPbTime) {
        return false;
    }

    // We consider that if the position is 0, it's either below the WR, or the WR is the only one with that medal
    if(time.position == 0) {
        return false;
    }

    return true;
}