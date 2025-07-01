#if DEPENDENCY_WARRIORMEDALS
class WarriorMedalHandler: MedalHandler {

    MedalType GetCurrentMedalType() override{
        return MedalType::WARRIOR;
    }

    string GetDesc() override{
        return "Warrior";
    }

    int GetMedalTime() override{
        return WarriorMedals::GetWMTime();
    }

    bool ShouldShowMedal() override{
        return showWarriorMedals;
    }

    PositionData@ GetPositionData() override{
        return warriorMedalPositionData;
    }
}
#endif