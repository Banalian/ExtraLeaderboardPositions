/**
 * Represent a position entry we want to display/get
 */
class PositionData {
    uint position;
    string color;
    string icon;
    string textColor;

    string colorName;
    string textColorName;

    PositionData() {
        position = 0;
        color = string(possibleColors["Dark Grey"]);
        icon = Icons::Kenney::PodiumAlt;
        textColor = string(possibleColors["White"]);

        colorName = "Dark Grey";
        textColorName = "White";
    }

    PositionData(uint position, const string &in color = greyColor1, const string &in icon = Icons::Kenney::PodiumAlt, const string &in textColor = whiteColor) {
        this.position = position;
        this.color = color;
        this.icon = icon;
        this.textColor = textColor;

        foreach (auto value, string colorName : possibleColors){
            string colorValue = string(value);
            if(colorValue == color){
                this.colorName = colorName;
            }
            if(colorValue == textColor){
                this.textColorName = colorName;
            }
        }
        if (color.Contains("Custom")) {
            this.colorName = "";
        }
        if (textColor.Contains("Custom")) {
            this.textColorName = "";
        }
    }

    PositionData(const string &in data) {
        Deserialize(data);
    }

    string Serialize() {
        // names can have a space, replace them with underscores
        string cName = colorName.Replace(" ", "_");
        string tcName = textColorName.Replace(" ", "_");
        
        return color + " " + position + " " + icon + " " + textColor + " " + cName + " " + tcName;
    }

    void Deserialize(const string &in data) {
        array<string> split = data.Split(" ");
        color = split[0];
        position = Text::ParseInt(split[1]);
        icon = split[2];
        textColor = split[3];

        // older users might not have the color names saved
        // can maybe be removed in a future update
        if(split.Length > 4){
            colorName = split[4];
            colorName = colorName.Replace("_", " ");
            textColorName = split[5];
            textColorName = textColorName.Replace("_", " ");
        }
    }

    string GetColorIcon() {
        return color.Replace("Custom", "") + icon.Replace("Custom", "") + resetColor;
    }

    /**
     * Convenience method to set the position data
     */
    void SetFrom(const PositionData &in other) {
        this.position = other.position;
        this.color = other.color;
        this.icon = other.icon;
        this.textColor = other.textColor;

        this.colorName = other.colorName;
        this.textColorName = other.textColorName;
    }

    bool opEquals(const PositionData &in other) {
        return position == other.position && color == other.color && icon == other.icon && textColor == other.textColor && colorName == other.colorName && textColorName == other.textColorName;
    }
}