#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
class SBVilleCampaignChallengesHandler: MedalHandler {

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

    PositionData GetDefaultPositionData() override{
        return PositionData(0, greyColor1, Icons::Circle, greyColor3);
    }
}
#endif