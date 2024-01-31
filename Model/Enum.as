// File containing all enums used by the plugin


enum EnumDisplayMode
{
    ALWAYS,
    ALWAYS_EXCEPT_IF_HIDDEN_INTERFACE,
    ONLY_IF_OPENPLANET_MENU_IS_OPEN,
    HIDE_WHEN_DRIVING
};

enum EnumDisplayPersonalBest
{
    NORMAL,
    IN_GREY,
    IN_GREEN
};

enum EnumLeaderboardEntryType
{
    UNKNOWN,
    PB,
    MEDAL,
    POSITION,
    TIME,
    EXTERNAL // To be potentially used by other plugins wishing to add their own entries
}