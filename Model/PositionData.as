/**
 * Represent a position entry we want to display/get
 */
 class PositionData {
    uint position;
    string color;
    string icon;

    LeaderboardData() {
        position = 0;
        color = greyColor;
        icon = Icons::Kenney::PodiumAlt;
    }

    LeaderboardData(uint position, string color = greyColor, string icon = Icons::Kenney::PodiumAlt) {
        this.position = position;
        this.color = color;
        this.icon = icon;
    }

    LeaderboardData(string data) {
        Deserialize(data);
    }

    string Serialize() {
        return position + " " + color + " " + icon;
    }

    void Deserialize(string data) {
        array<string> split = data.Split(" ");
        position = Text::ParseInt(split[0]);
        color = split[1];
        icon = split[2];
    }

    string GetColorIcon() {
        return color + icon;
    }
 }