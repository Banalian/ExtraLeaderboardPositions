namespace ExtraLeaderboardAPI
{
    /**
     * Class representing the response of the Extra Leaderboard API
     */
    class ExtraLeaderboardAPIResponse
    {
        /**
         * List of entries made by the API
         */
        array<LeaderboardEntry@> positions;

        /**
         * Number of players who have played the map
         */
        int playerCount;

        string mapName;
        string mapAuthor;

        /**
         * Author medal time on the map
         */
        int authorTime;

        /**
         * Gold medal time on the map
         */
        int goldTime;

        /**
         * Silver medal time on the map
         */
        int silverTime;

        /**
         * Bronze medal time on the map
         */
        int bronzeTime;

        // Convert a json object to an ExtraLeaderboardAPIResponse object
        ExtraLeaderboardAPIResponse fromJson(Json::Value@ input){
            ExtraLeaderboardAPIResponse response;

            if(input.HasKey("meta")){
                auto metaJson = input.Get("meta");
                if(metaJson.HasKey("playerCount")){
                    response.playerCount = metaJson.Get("playerCount");
                }
            }

            if(input.HasKey("mapInfo")){
                auto mapInfo = input.Get("mapInfo");
                response.mapName = mapInfo.Get("name");
                response.mapAuthor = mapInfo.Get("author");
                response.authorTime = mapInfo.Get("authorTime");
                response.goldTime = mapInfo.Get("goldTime");
                response.silverTime = mapInfo.Get("silverTime");
                response.bronzeTime = mapInfo.Get("bronzeTime");
            }
            
            auto positions = input.Get("positions");

            response.positions = {};
            for(uint i = 0; i < positions.Length; i++){
                LeaderboardEntry entry;
                entry.time = positions[i].Get("time");
                entry.position = positions[i].Get("rank");
                string type = positions[i].Get("entryType");
                if(type == "MEDAL"){
                    entry.entryType = EnumLeaderboardEntryType::MEDAL;
                } else if(type == "TIME" || type == "POSITION"){
                    entry.entryType = EnumLeaderboardEntryType::POSTIME;
                } else{
                    entry.entryType = EnumLeaderboardEntryType::UNKNOWN;
                }
                response.positions.InsertLast(entry);
            }
            return response;
        }

        /**
         * Convert the response to a string
         */
        string toString(){
            string output = "";
            output += "Map: " + mapName + " by " + mapAuthor + "\n";
            output += "Author time: " + authorTime + "\n";
            output += "Gold time: " + goldTime + "\n";
            output += "Silver time: " + silverTime + "\n";
            output += "Bronze time: " + bronzeTime + "\n";
            output += "Player count: " + playerCount + "\n";
            output += "Positions: \n";
            for(uint i = 0; i < positions.Length; i++){
                output += "\t- Position: " + positions[i].position + " - Time :" + positions[i].time + " - Desc :" + positions[i].desc + " - Type :" + positions[i].entryType + "\n";
            }
            return output;
        }
    
        
    }
}