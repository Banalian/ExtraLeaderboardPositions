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