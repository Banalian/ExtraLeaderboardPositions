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