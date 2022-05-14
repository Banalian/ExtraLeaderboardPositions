// Class used to store the data of a position in the leaderboard
class CutoffTime{

    // the time of the player
    int time = -1;

    // the position of the player in the leaderboard
    int position = -1;

    // true if it's a personal best, false otherwise
    bool pb = false;

    // true if it's a medal, false otherwise
    bool isMedal = false;

    // really short description of the record
    string desc = "";

    string percentage = "";

    // Comparaison operator
    int opCmp(CutoffTime@ other){
        if(position - other.position != 0)
            return position - other.position;
        else
            return time - other.time;
    }
}