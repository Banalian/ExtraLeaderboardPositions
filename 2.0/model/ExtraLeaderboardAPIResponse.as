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
        array<LeaderboardEntry> positions;

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
        ExtraLeaderboardAPIResponse fromJson(Json::Value input){
            ExtraLeaderboardAPIResponse response;

            if(input.Get("meta") !is null && input.Get("meta").GetType() != Json::Type::Null){
                auto metaInfo = input["meta"];
                response.playerCount = metaInfo.Get("playerCount");
                //response.playerCount = input["meta"]["playerCount"];
            }

            if(input.Get("mapInfo") !is null && input.Get("mapInfo").GetType() == Json::Type::Null){
                auto mapInfo = input["mapInfo"];
                response.mapName = mapInfo["mapName"];
                response.mapAuthor = mapInfo["mapAuthor"];
                response.authorTime = mapInfo["authorTime"];
                response.goldTime = mapInfo["goldTime"];
                response.silverTime = mapInfo["silverTime"];
                response.bronzeTime = mapInfo["bronzeTime"];
            }
            

            auto positions = input.Get("positions");

            response.positions = {};
            for(uint i = 0; i < positions.Length; i++){
                LeaderboardEntry entry;
                entry.time = positions[i].Get("time");
                entry.position = positions[i].Get("rank");
                response.positions.InsertLast(entry);
            }
            return response;
        }
    
        
    }
}