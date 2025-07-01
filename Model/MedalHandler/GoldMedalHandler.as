class GoldMedalHandler: MedalHandler {

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