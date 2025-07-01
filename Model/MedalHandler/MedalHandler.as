// File used to store MedalHandler and its implementations. Intented to have all plugin-specific logic
// Stored in one place to avoid cluttering the plugin with lots of code duplication and ifdef checks

/**
 * Interface for handling any medal in the plugin.
 * Each medal type should implement this interface to provide its specific logic.
 */
interface MedalHandler {
    /**
     * Get the medal type.
     * @return MedalType
     */
    MedalType GetCurrentMedalType();

    /**
     * Get the medal name/desc
     */
    string GetDesc();

    /**
     * Get the medal time for the current map.
     * @return int
     */
    int GetMedalTime();

    /**
     * Check if a medal should be displayed.
     * @return bool
     */
    bool ShouldShowMedal();

    /**
     * Get the position data for the medal.
     * @return PositionData
     */
    PositionData@ GetPositionData();

    /**
     * Set the position data for the medal.
     * @param positionData PositionData to set
     */
    void SetPositionData(PositionData@ positionData);

    /**
     * Get the default position data for the medal.
     * @return PositionData
     */
    PositionData GetDefaultPositionData();
}


/**
 * Factory method to get the appropriate medal handler based on the medal type.
 * @param medal The type of medal.
 * @return MedalHandler corresponding to the medal type.
 */
MedalHandler@ GetMedalHandler(MedalType medal) {
    switch(medal) {
        case MedalType::BRONZE:
            return BronzeMedalHandler();
        case MedalType::SILVER:
            return SilverMedalHandler();
        case MedalType::GOLD:
            return GoldMedalHandler();
        case MedalType::AT:
            return ATMedalHandler();
#if DEPENDENCY_CHAMPIONMEDALS
        case MedalType::CHAMPION:
            return ChampionMedalHandler();
#endif
#if DEPENDENCY_WARRIORMEDALS
        case MedalType::WARRIOR:
            return WarriorMedalHandler();
#endif
#if DEPENDENCY_S314KEMEDALS
        case MedalType::S314KE:
            return S314keMedalHandler();
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
        case MedalType::SBVILLE:
            return SBVilleCampaignChallengesHandler();
#endif
        default:
            throw("Unhandled medal type: type'" + medal + "', no Handler defined for it.");
    }
    return null; // Fallback for the compiler, should never be reached
}