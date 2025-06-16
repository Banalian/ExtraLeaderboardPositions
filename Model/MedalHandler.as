// File used to store MedalHandler and its implementations. Intented to have all plugin-specific logic
// Stored in one place to avoid cluttering the plugin with lots of code duplication and ifdef checks

interface CustomMedalHandler {
    /**
     * Get the medal type.
     * @return MedalType
     */
    MedalType GetCurrentMedalType();

    /**
     * Get the medal name/desc
     */
    string GetDesc();

    /**
     * Get the medal time for the current map.
     * @return int
     */
    int GetMedalTime();

    /**
     * Check if a medal should be displayed.
     * @return bool
     */
    bool ShouldShowMedal();

    /**
     * Get the position data for the medal.
     * @return PositionData
     */
    PositionData@ GetPositionData();
}


class BronzeMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::BRONZE;
    }

    string GetDesc() override{
        return "Bronze";
    }

    int GetMedalTime() override{
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        return map.TMObjective_BronzeTime;
    }

    bool ShouldShowMedal() override{
        return showBronze;
    }

    PositionData@ GetPositionData() override{
        return bronzePositionData;
    }
}


class SilverMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::SILVER;
    }

    string GetDesc() override{
        return "Silver";
    }

    int GetMedalTime() override{
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        return map.TMObjective_SilverTime;
    }

    bool ShouldShowMedal() override{
        return showSilver;
    }

    PositionData@ GetPositionData() override{
        return silverPositionData;
    }
}


class GoldMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::GOLD;
    }

    string GetDesc() override{
        return "Gold";
    }

    int GetMedalTime() override{
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        return map.TMObjective_GoldTime;
    }

    bool ShouldShowMedal() override{
        return showGold;
    }

    PositionData@ GetPositionData() override{
        return goldPositionData;
    }
}


class ATMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::AT;
    }

    string GetDesc() override{
        return "AT";
    }

    int GetMedalTime() override{
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        return map.TMObjective_AuthorTime;
    }

    bool ShouldShowMedal() override{
        return showAT;
    }

    PositionData@ GetPositionData() override{
        return atPositionData;
    }
}


#if DEPENDENCY_CHAMPIONMEDALS
class ChampionMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::CHAMPION;
    }

    string GetDesc() override{
        return "Champion";
    }

    int GetMedalTime() override{
        return ChampionMedals::GetCMTime();
    }

    bool ShouldShowMedal() override{
        return showChampionMedals;
    }

    PositionData@ GetPositionData() override{
        return championMedalPositionData;
    }
}
#endif


#if DEPENDENCY_WARRIORMEDALS
class WarriorMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::WARRIOR;
    }

    string GetDesc() override{
        return "Warrior";
    }

    int GetMedalTime() override{
        return WarriorMedals::GetWMTime();
    }

    bool ShouldShowMedal() override{
        return showWarriorMedals;
    }

    PositionData@ GetPositionData() override{
        return warriorMedalPositionData;
    }
}
#endif


#if DEPENDENCY_S314KEMEDALS
class S314keMedalHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::S314KE;
    }

    string GetDesc() override{
        return "S314ke";
    }

    int GetMedalTime() override{
        return s314keMedals::GetS314keMedalTime();
    }

    bool ShouldShowMedal() override{
        return showS314keMedals;
    }

    PositionData@ GetPositionData() override{
        return s314keMedalPositionData;
    }
}
#endif


#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
class SBVilleCampaignChallengesHandler: CustomMedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::SBVILLE;
    }

    string GetDesc() override{
        return "SBVille AT";
    }

    int GetMedalTime() override{
        return SBVilleCampaignChallenges::getChallengeTime();
    }

    bool ShouldShowMedal() override{
        return showSBVilleATMedal;
    }

    PositionData@ GetPositionData() override{
        return sbVillePositionData;
    }
}
#endif


CustomMedalHandler@ GetMedalHandler(MedalType medal) {
    switch(medal) {
        case MedalType::BRONZE:
            return BronzeMedalHandler();
        case MedalType::SILVER:
            return SilverMedalHandler();
        case MedalType::GOLD:
            return GoldMedalHandler();
        case MedalType::AT:
            return ATMedalHandler();
#if DEPENDENCY_CHAMPIONMEDALS
        case MedalType::CHAMPION:
            return ChampionMedalHandler();
#endif
#if DEPENDENCY_WARRIORMEDALS
        case MedalType::WARRIOR:
            return WarriorMedalHandler();
#endif
#if DEPENDENCY_S314KEMEDALS
        case MedalType::S314KE:
            return S314keMedalHandler();
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        case MedalType::SBVILLE:
            return SBVilleCampaignChallengesHandler();
#endif
        default:
            // throw new Exception("No handler for medal type: " + MedalTypeToString(medal));
            throw("Unhandled medal type: " + MedalTypeToString(medal));
    }
    return null; // Fallback for the compiler, should never be reached
}