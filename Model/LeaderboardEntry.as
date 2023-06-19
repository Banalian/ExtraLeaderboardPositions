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
     * Really short description of the entry (medal type for example, or custom description)
     */
    string desc = "";

    /**
     * Type of the entry (medal, custom, etc...)
     */
    EnumLeaderboardEntryType entryType = EnumLeaderboardEntryType::UNKNOWN;

    /**
     * Comparaison operator
     */
    int opCmp(LeaderboardEntry@ other){
        if(position - other.position != 0)
            return position - other.position;
        else
            return time - other.time;
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
        return time != -1 && position != -1 && entryType != EnumLeaderboardEntryType::UNKNOWN;
    }
}