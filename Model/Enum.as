// File containing all enums used by the plugin

enum EnumDisplayMode
{
    ALWAYS,
    ALWAYS_EXCEPT_IF_HIDDEN_INTERFACE,
    ONLY_IF_OPENPLANET_MENU_IS_OPEN,
    HIDE_WHEN_DRIVING
};


enum EnumLeaderboardEntryType
{
    UNKNOWN,
    PB,
    MEDAL,
    POSITION,
    TIME,
    EXTERNAL // To be potentially used by other plugins wishing to add their own entries
};


enum MedalType
{
    NONE,
    BRONZE,
    SILVER,
    GOLD,
    AT,
#if DEPENDENCY_S314KEMEDALS
    S314KE,
#endif
#if DEPENDENCY_WARRIORMEDALS
    WARRIOR,
#endif
#if DEPENDENCY_CHAMPIONMEDALS
    CHAMPION,
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    SBVILLE,
#endif
    COUNT
};


enum EnumCurrentMode
{
    INVALID,
    RACE,
    STUNT,
    PLATFORM
};


// ----------------------------- DEPRECATED ENUMS -----------------------------
// Can't be removed because they're needed for the migration process

enum EnumDisplayMedal
{
    NORMAL,
    IN_GREY
};


enum EnumDisplayPersonalBest
{
    NORMAL,
    IN_GREY,
    IN_GREEN
};