namespace ExtraLeaderboardAPI
{
    /**
     * Request class for the Extra Leaderboard API
     */
    class ExtraLeaderboardAPIRequest
    {
        /**
         * MapID of the map requested
         */
        string mapId = "";
        
        /**
         * List of time you want the position of
         */
        array<int> scores = {};

        /**
         * List of positions you want the time of
         */
        array<int> positions = {};

        /**
         * List of medal's time and position you want
         */
        array<MedalType> medals = {};

        /**
         * get the amount of player on the map
         */
        bool getPlayerCount = false;

        /**
         * Get some global map information like the name, amount of lap, medal times, etc...
         */
        bool getMapInfo = false;

        /**
         * Generate the url to request the API based on the current state of the class
         */
        string GenerateUrl(){
            string url = API_URL + "/leaderboard/map/" + mapId + "/records?";
            if(getPlayerCount){
                url += "getplayercount=true&";
            }
            if(getMapInfo){
                url += "getmapinfo=true&";
            }
            if(scores.Length > 0){
                url += "score=";
                for(uint i = 0; i < scores.Length; i++){
                    url += "" + scores[i];
                    if(i != scores.Length - 1){
                        url += ",";
                    }
                }
                url += "&";
            }
            if(positions.Length > 0){
                url += "position=";
                for(uint i = 0; i < positions.Length; i++){
                    url += "" + positions[i];
                    if(i != positions.Length - 1){
                        url += ",";
                    }
                }
                url += "&";
            }
            if(medals.Length > 0){
                url += "medal=";
                for(uint i = 0; i < medals.Length; i++){
                    url += "" + medals[i];
                    if(i != medals.Length - 1){
                        url += ",";
                    }
                }
                url += "&";
            }
            return url;
        }
    }
}