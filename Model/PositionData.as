/**
 * Represent a position entry we want to display/get
 */
 class PositionData {
    uint position;
    uint region;
    string color;
    string icon;
    string textColor;

    PositionData() {
        position = 0;
        region = 0;
        color = greyColor1;
        icon = Icons::Kenney::PodiumAlt;
        textColor = whiteColor;
    }

    PositionData(uint position, const string &in color = greyColor1, const string &in icon = Icons::Kenney::PodiumAlt, const string &in textColor = whiteColor, uint region = 0) {
        this.position = position;
        this.region = region;
        this.color = color;
        this.icon = icon;
        this.textColor = textColor;
    }

    PositionData(const string &in data) {
        Deserialize(data);
    }

    string Serialize() {
        return color + " " + position + " " + icon + " " + textColor + " " + region;
    }

    void Deserialize(const string &in data) {
        array<string> split = data.Split(" ");
        color = split[0];
        position = Text::ParseInt(split[1]);
        icon = split[2];
        textColor = split[3];
        if (split.Length > 4) {
            region = Text::ParseInt(split[4]);
        } else {
            region = 0;
        }
    }

    string GetColorIcon() {
        return color + icon + resetColor;
    }
 }