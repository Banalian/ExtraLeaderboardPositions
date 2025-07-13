// Ultimate Medals Extended - General Medal representing a position entry

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

array<string> UMEMedals = {};

void InsertIfNotExists(const string &in name) {
    for (uint i = 0; i < UMEMedals.Length; i++) {
        if (UMEMedals[i] == name) {
            return;
        }
    }
    UMEMedals.InsertLast(name);
}

class PositionMedal : UltimateMedalsExtended::IMedal {

    int position;
    PositionData@ positionData;
    int offset;

    PositionMedal(int position, PositionData@ positionData, int offset = 0) {
        this.position = position;
        @this.positionData = positionData;
        this.offset = offset;
    }

    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        c.defaultName = "Top " + this.position;
        c.icon = positionData.GetColorIcon();
        c.nameColor = positionData.textColor;
        c.sortPriority = 191 - offset; // 191 is the default for position medals, after that a worse position is below (so 191 beats 190)
        c.usePreviousColor = false;
        c.shareIcon = false;
        // Store known medals to ensure they get removed correctly if reloaded
        InsertIfNotExists(c.defaultName);
        return c;
    }
    
    void UpdateMedal(const string &in uid) override {}

    bool HasMedalTime(const string &in uid) override {
        LeaderboardEntry@ entry = GetEntry();
        return (entry !is null && entry.time > 0);
    }
    uint GetMedalTime() override {
        LeaderboardEntry@ entry = GetEntry();
        return uint(entry.time);
    }

    LeaderboardEntry@ GetEntry() {
        for (uint i = 0; i < leaderboardArray.Length; i++) {
            if (leaderboardArray[i].position == position && leaderboardArray[i].entryType == EnumLeaderboardEntryType::POSITION) {
                // if we get an entry, update the position data to get the latest values
                if (leaderboardArray[i].positionData !is null) {
                    positionData = leaderboardArray[i].positionData;
                }
                return leaderboardArray[i];
            }
        }
        return null;
    }
}


void ClearUME() {
    for (uint i = 0; i < UMEMedals.Length; i++) {
        UltimateMedalsExtended::RemoveMedal(UMEMedals[i]);
    }
    UMEMedals.Resize(0);
}


void RefreshUME() {
    ClearUME();
    for (uint i = 0; i < leaderboardArray.Length; i++) {
        if (leaderboardArray[i].entryType == EnumLeaderboardEntryType::POSITION) {
            auto positionData = leaderboardArray[i].positionData;
            auto medal = PositionMedal(leaderboardArray[i].position, positionData, i);
            UltimateMedalsExtended::AddMedal(medal);
        }
    }
}

void OnDestroyed() {
    ClearUME();
}

#else
// If the Ultimate Medals Extended dependency is not available, we define a dummy setup function
void ClearUME() {}
void RefreshUME() {}
void OnDestroyed() {}
#endif