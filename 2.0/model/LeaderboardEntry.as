// Class used to store the data of a entry in the leaderboard
class LeaderboardEntry{

    // Type of the entry (medal, custom, etc...)
    EnumLeaderboardEntryType type = EnumLeaderboardEntryType::UNKNOWN;

    // Time of the entry (in ms, e.g 70876 would be 1:10.876)
    int time = -1;

    // Position of the entry
    int position = -1;

    // Really short description of the entry (medal type for example, or custom description)
    string desc = "";

    EnumLeaderboardEntryType entryType = EnumLeaderboardEntryType::UNKNOWN;

    // Comparaison operator
    int opCmp(LeaderboardEntry@ other){
        if(position - other.position != 0)
            return position - other.position;
        else
            return time - other.time;
    }
}