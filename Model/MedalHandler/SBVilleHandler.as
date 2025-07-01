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