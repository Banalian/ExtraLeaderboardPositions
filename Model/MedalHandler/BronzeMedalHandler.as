class BronzeMedalHandler: MedalHandler {

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

    void SetPositionData(PositionData@ positionData) override{
        bronzePositionData = positionData;
    }

    PositionData GetDefaultPositionData() override{
        return PositionData(0, bronzeColor, Icons::Circle, greyColor3);
    }
}