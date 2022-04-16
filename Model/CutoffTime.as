// Class used to store the data of a position in the leaderboard
class CutoffTime{

    // the time of the player
    int time = -1;

    // the position of the player in the leaderboard
    int position = -1;

    // true if it's a personal best, false otherwise
    bool pb = false;

    string desc = "";

    // Comparaison operator
    int opCmp(CutoffTime@ other){
        return position - other.position;
    }
}