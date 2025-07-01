class ATMedalHandler: MedalHandler {

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

    void SetPositionData(PositionData@ positionData) override{
        atPositionData = positionData;
    }

    PositionData GetDefaultPositionData() override{
        return PositionData(0, atGreenColor, Icons::Circle, greyColor3);
    }
}