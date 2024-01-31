/**
 * Class used to store the data of an entry in the leaderboard
 */
class LeaderboardEntry{
    /**
     * Time of the entry (in ms, e.g 70876 would be 1:10.876)
     */
    int time = -1;

    /**
     * Position of the entry
     */
    int position = -1;

    /**
     * Player name of the entry
     */
    string name = "";

    /**
     * Player id of the entry
     */
    string id = "";

    /**
     * Really short description of the entry (medal type for example, or custom description)
     */
    string desc = "";

    float percentage = 0.0f;

    string percentageDisplay = "";

    /**
     * Type of the entry (medal, custom, etc...)
     */
    EnumLeaderboardEntryType entryType = EnumLeaderboardEntryType::UNKNOWN;

    /**
     * Comparaison operator
     */
    int opCmp(LeaderboardEntry@ other){
        // Position can be -1 if we have new PB on leaderboard without position from API yet, so sort by time first
        if (time != other.time)
            return time - other.time;
        else if (position != other.position) {
            // Sort a temporary -1 position later i.e. greater than a valid position,
            // since driving an equal time would typically be ranked later than the already existing record.
            // We'll only have to wait a bit for the API to give the actual position for definitive sort.
            if (position == -1)
                return 1;
            else if (other.position == -1)
                return -1;
            else
                return position - other.position;
        }
        else
            return 0;
    }

    /**
     * Custom Equality operator (only checks the position and the time compared to the regular equality operator)
     */
    bool customEquals(LeaderboardEntry@ other){
        return position == other.position && time == other.time;
    }


    /**
     * Check if the entry is valid (i.e. if it has been initialized with different values than the default ones)
     */
    bool isValid(){
        return time != -1 && entryType != EnumLeaderboardEntryType::UNKNOWN;
    }
}