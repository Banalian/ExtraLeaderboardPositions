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

    void SetPositionData(PositionData@ positionData) override{
        warriorMedalPositionData = positionData;
    }

    PositionData GetDefaultPositionData() override{
        return PositionData(0, WarriorMedals::GetColorStr(), Icons::Circle, greyColor3);
    }
}
#endif