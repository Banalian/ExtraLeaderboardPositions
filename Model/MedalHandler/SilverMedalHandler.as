class SilverMedalHandler: MedalHandler {

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

    void SetPositionData(PositionData@ positionData) override{
        silverPositionData = positionData;
    }

    PositionData GetDefaultPositionData() override{
        return PositionData(0, silverColor, Icons::Circle, greyColor3);
    }
}