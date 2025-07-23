// Ultimate Medals Extended - General Medal representing a position entry

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

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

        if(exportIconUME && exportIconColorUME) {
            c.icon = positionData.GetColorIcon();
        } else if (exportIconUME) {
            c.icon = greyColor1 + positionData.icon;
        } else if (exportIconColorUME) {
            c.icon = positionData.color + Icons::Kenney::PodiumAlt;
        } else {
            c.icon = greyColor1 + Icons::Kenney::PodiumAlt;;
        }

        if(exportTextColorUME) {
            c.nameColor = positionData.textColor;
        }

        c.sortPriority = 191 - offset; // 191 is the default for position medals, after that a worse position is below (so 191 beats 190)

        // If neither icon nor icon color are exported, use the overlay icon
        bool useOverlay = !(exportIconUME || exportIconColorUME);
        c.usePreviousColor = !exportIconColorUME;
        c.usePreviousIcon = !exportIconUME;
        c.usePreviousOverlayColor = useOverlay;
        c.usePreviousOverlayIcon = useOverlay;

        c.shareIcon = false;
        return c;
    }

    void UpdateMedal(const string &in uid) override {}

    bool HasMedalTime(const string &in uid) override {
        // Don't return an entry if somehow our data isn't for the same map
        if(currentMapUid != uid) {
            return false;
        }
        LeaderboardEntry@ entry = GetEntry();
        return (entry !is null && entry.time > 0);
    }

    uint GetMedalTime() override {
        LeaderboardEntry@ entry = GetEntry();
        return uint(entry.time);
    }

    LeaderboardEntry@ GetEntry() {
        for(uint i = 0; i < leaderboardArray.Length; i++){
            if(leaderboardArray[i].position == position && leaderboardArray[i].entryType == EnumLeaderboardEntryType::POSITION){
                // if we get an entry, update the position data to get the latest values
                if(leaderboardArray[i].positionData !is null){
                    positionData = leaderboardArray[i].positionData;
                }
                return leaderboardArray[i];
            }
        }
        return null;
    }
}


array<PositionMedal@> UMEMedals = {};


void ClearUME() {
    for(uint i = 0; i < UMEMedals.Length; i++){
        UltimateMedalsExtended::RemoveMedal(UMEMedals[i].GetConfig().defaultName);
    }
    UMEMedals.Resize(0);
}


void RefreshUME(bool force = false) {
    if(!exportToUME){
        ClearUME();
        return;
    }

    for(int i = UMEMedals.Length - 1; i >= 0; i--){
        if(force){
            ClearUME();
            break;
        }
        // Remove the medal only if it does not exist anymore
        // This is to ensure that we do not remove medals that are still valid
        auto medal = UMEMedals[i];
        // look for its leaderboard entry
        bool found = false;
        for(uint j = 0; j < leaderboardArray.Length; j++){
            if(leaderboardArray[j].entryType == EnumLeaderboardEntryType::POSITION && leaderboardArray[j].position == medal.position){
                found = true;
                break;
            }
        }
        if(!found){
            UltimateMedalsExtended::RemoveMedal(medal.GetConfig().defaultName);
            UMEMedals.RemoveAt(i);
        }
    }

    // Iterate over the leaderboard array to add new medals and update existing ones
    for(uint i = 0; i < leaderboardArray.Length; i++){
        auto entry = leaderboardArray[i];
        PositionMedal@ existingMedal = null;
        bool needsUpdate = false;
        if (entry.entryType == EnumLeaderboardEntryType::POSITION){
            // Check if the medal already exists
            for(uint j = 0; j < UMEMedals.Length; j++){
                if(UMEMedals[j].position == entry.position){
                    @existingMedal = UMEMedals[j];
                }
            }
            if(existingMedal is null){
                // If the medal does not exist, we create a new one
                auto positionData = entry.positionData;
                auto medal = PositionMedal(entry.position, positionData, i);
                UMEMedals.InsertLast(medal);
                @existingMedal = medal;
                needsUpdate = true;
            } else {
                // If the medal already exists, we can update it
                if(existingMedal.offset != int(i) || existingMedal.positionData != entry.positionData){
                    needsUpdate = true;
                }
                existingMedal.positionData = entry.positionData;
                existingMedal.offset = i;
            }

            if(needsUpdate) {
                UltimateMedalsExtended::AddMedal(existingMedal);
            }
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