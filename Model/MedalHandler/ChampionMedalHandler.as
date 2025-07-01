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