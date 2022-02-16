// Class used to store the data of a position in the leaderboard
class CutoffTime{

    // the time of the player
    int time;

    // the position of the player in the leaderboard
    int position;

    // true if it's a personal best, false otherwise
    bool pb = false;

    // Comparaison operator
    int opCmp(CutoffTime@ other){
        return position - other.position;
    }
}