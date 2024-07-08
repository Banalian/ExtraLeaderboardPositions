/**
 * Represent a position entry we want to display/get
 */
 class PositionData {
    uint position;
    string color;
    string icon;

    PositionData() {
        position = 0;
        color = greyColor;
        icon = Icons::Kenney::PodiumAlt;
    }

    PositionData(uint position, const string &in color = greyColor, const string &in icon = Icons::Kenney::PodiumAlt) {
        this.position = position;
        this.color = color;
        this.icon = icon;
    }

    PositionData(const string &in data) {
        Deserialize(data);
    }

    string Serialize() {
        return position + " " + color + " " + icon;
    }

    void Deserialize(const string &in data) {
        array<string> split = data.Split(" ");
        position = Text::ParseInt(split[0]);
        color = split[1];
        icon = split[2];
    }

    string GetColorIcon() {
        return color + icon + resetColor;
    }
 }