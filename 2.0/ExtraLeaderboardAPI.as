// Namespace for the Extra Leaderboard API related stuff

namespace ExtraLeaderboardAPI
{
    string API_URL = "";
    bool Active = false;

    /**
     *  Return a list of LeaderboardEntry objects, given a map id and a list of requests
     */ 
    ExtraLeaderboardAPIResponse@ GetExtraLeaderboard(ExtraLeaderboardAPIRequest request){
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = request.generateUrl();
        req.Method = Net::HttpMethod::Get;

        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error calling API at url ' " + req.Url + "' : " + req.ResponseCode() + " - " + req.Error());
            return null;
        }

        // get the json object from the response
        auto response = Json::Parse(req.String());
        ExtraLeaderboardAPIResponse@ result = ExtraLeaderboardAPIResponse();
        result.fromJson(response);
        return result;
    }

    /**
     * load the configuration of the plugin.
     */
    string loadURLConfig(){
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = "openplanet.dev/plugin/extraleaderboardpositions/config/urls";
        req.Method = Net::HttpMethod::Get;
        
        req.Start();
        while(!req.Finished()){
            yield();
        }
        if(req.ResponseCode() != 200){
            warn("Error loading config : " + req.ResponseCode() + " - " + req.Error());
            return "";
        }

        // get the json object from the response
        auto response = Json::Parse(req.String());
        auto externalAPI = response["api"];
        // if the json's "active" is true, return the url, else return an empty string
        if(externalAPI["active"] == "true"){
            return externalAPI["url"];
        }
        return "";
    }
}