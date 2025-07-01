#if DEPENDENCY_CHAMPIONMEDALS
class ChampionMedalHandler: MedalHandler {

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

    void SetPositionData(PositionData@ positionData) override{
        championMedalPositionData = positionData;
    }

    PositionData GetDefaultPositionData() override{
        return PositionData(0, championColor, Icons::Circle, greyColor3);
    }
}
#endif