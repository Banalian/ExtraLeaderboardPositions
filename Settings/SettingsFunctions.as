// ############################## SETTINGS CALLBACKS #############################

void OnSettingsChanged(){
    if(refreshTimer < 1){
        refreshTimer = 1;
    }
    updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second

    bool foundCombo = false;
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        if(allPositionToGet[i] < 1){
            allPositionToGet[i] = 1;
        }

        if(allPositionToGet[i] == currentComboChoice){
            if(currentComboChoice < 1 && currentComboChoice != -1){
                currentComboChoice = 1;
            }

            if(currentComboChoice > 10000){
                currentComboChoice = 10000;
            }

            foundCombo = true;
        }

        if(allPositionToGet[i] > 10000){
            allPositionToGet[i] = 10000;
        }
    }

    if(!foundCombo){
        currentComboChoice = -1;
    }

    if(hiddingSpeedSetting < 0){
        hiddingSpeedSetting = 0;
    }

}

void OnSettingsSave(Settings::Section& section){
    //save the array in the string
    allPositionToGetStringSave = "";
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allPositionToGetStringSave += "" + allPositionToGet[i];
        if(i < nbSizePositionToGetArray - 1){
            allPositionToGetStringSave += ",";
        }
    }
    //if it's still empty, set it to "empty" to avoid saving an empty string that would be considered a new install when loading
    if(allPositionToGetStringSave == ""){
        allPositionToGetStringSave = "empty";
    }
    section.SetString("allPositionToGetStringSave", allPositionToGetStringSave);

    allPositionDataStringSave = "";
    for(int i = 0; i < nbSizePositionDataArray; i++){
        allPositionDataStringSave += allPositionData[i].Serialize();
        if(i < nbSizePositionDataArray - 1){
            allPositionDataStringSave += ";";
        }
    }
    //if it's still empty, set it to "empty" to avoid saving an empty string that would be considered a new install when loading
    if(allPositionDataStringSave == ""){
        allPositionDataStringSave = "empty";
    }
    section.SetString("allPositionDataStringSave", allPositionDataStringSave);

    medalsPositionDataStringSave = "";
    medalsPositionDataStringSave += currentPbPositionData.Serialize() + ";";
    medalsPositionDataStringSave += atPositionData.Serialize() + ";";
    medalsPositionDataStringSave += goldPositionData.Serialize() + ";";
    medalsPositionDataStringSave += silverPositionData.Serialize() + ";";
    medalsPositionDataStringSave += bronzePositionData.Serialize();
    section.SetString("medalsPositionDataStringSave", medalsPositionDataStringSave);

#if DEPENDENCY_CHAMPIONMEDALS
    championMedalPositionDataStringSave = championMedalPositionData.Serialize();
    section.SetString("championMedalPositionDataStringSave", championMedalPositionDataStringSave);
#endif
#if DEPENDENCY_WARRIORMEDALS
    warriorMedalPositionDataStringSave = warriorMedalPositionData.Serialize();
    section.SetString("warriorMedalPositionDataStringSave", warriorMedalPositionDataStringSave);
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    sbVillePositionDataStringSave = sbVillePositionData.Serialize();
    section.SetString("sbVillePositionDataStringSave", sbVillePositionDataStringSave);
#endif
}

void OnSettingsLoad(Settings::Section& section){
    //load the array from the string
    allPositionToGetStringSave = section.GetString("allPositionToGetStringSave");

    if(allPositionToGetStringSave == ""){
        //empty string, should be a new install or a reset, set the default values
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
        allPositionToGet.InsertLast(1);
        allPositionToGet.InsertLast(10);
        allPositionToGet.InsertLast(100);
        allPositionToGet.InsertLast(1000);
        allPositionToGet.InsertLast(10000);
    }else if(allPositionToGetStringSave != "empty"){
        //not empty, load the values
        array<string> allPositionToGetTmp = allPositionToGetStringSave.Split(",");
        nbSizePositionToGetArray = allPositionToGetTmp.Length;

        for(int i = 0; i < nbSizePositionToGetArray; i++){
            allPositionToGet.InsertLast(Text::ParseInt(allPositionToGetTmp[i]));
        }
    } else {
        //else for this case, the array is empty per user choice, don't insert anything
        //still set the default values just in case
        nbSizePositionToGetArray = 0;
        allPositionToGet = {};
    }


    allPositionDataStringSave = section.GetString("allPositionDataStringSave");

    if(allPositionDataStringSave == ""){
        //empty string, should be a new install or a reset, set the default values
        allPositionDataStringSave = "";
        nbSizePositionDataArray = 0;
    }else if(allPositionDataStringSave != "empty"){
        //not empty, load the values
        array<string> allPositionDataTmp = allPositionDataStringSave.Split(";");
        nbSizePositionDataArray = allPositionDataTmp.Length;

        for(int i = 0; i < nbSizePositionDataArray; i++){
            PositionData positionData = PositionData(allPositionDataTmp[i]);
            allPositionData.InsertLast(positionData);
        }
    }else{
        //else for this case, the array is empty per user choice, don't insert anything
        allPositionDataStringSave = "";
        nbSizePositionDataArray = 0;
    }

    medalsPositionDataStringSave = section.GetString("medalsPositionDataStringSave");
    
    bool resetToDefault = false;
    if(medalsPositionDataStringSave != ""){
        array<string> medalsPositionDataTmp = medalsPositionDataStringSave.Split(";");
        if(medalsPositionDataTmp.Length == 5){
            currentPbPositionData = PositionData(medalsPositionDataTmp[0]);
            atPositionData = PositionData(medalsPositionDataTmp[1]);
            goldPositionData = PositionData(medalsPositionDataTmp[2]);
            silverPositionData = PositionData(medalsPositionDataTmp[3]);
            bronzePositionData = PositionData(medalsPositionDataTmp[4]);
        } else {
            resetToDefault = true;
        }
    }else{
        resetToDefault = true;
    }
    if(resetToDefault){
        currentPbPositionData = PositionData(0, pbGreenColor, Icons::Circle);
        atPositionData = PositionData(0, atGreenColor, Icons::Circle);
        goldPositionData = PositionData(0, goldColor, Icons::Circle);
        silverPositionData = PositionData(0, silverColor, Icons::Circle);
        bronzePositionData = PositionData(0, bronzeColor, Icons::Circle);
    }

#if DEPENDENCY_CHAMPIONMEDALS
    championMedalPositionDataStringSave = section.GetString("championMedalPositionDataStringSave");
    if(championMedalPositionDataStringSave != ""){
        championMedalPositionData = PositionData(championMedalPositionDataStringSave);
    }else{
        championMedalPositionData = PositionData(0, redColor, Icons::Circle);
    }
#endif
#if DEPENDENCY_WARRIORMEDALS
    warriorMedalPositionDataStringSave = section.GetString("warriorMedalPositionDataStringSave");
    if(warriorMedalPositionDataStringSave != ""){
        warriorMedalPositionData = PositionData(warriorMedalPositionDataStringSave);
    }else{
        warriorMedalPositionData = PositionData(0, blueColor, Icons::Circle);
    }
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    sbVillePositionDataStringSave = section.GetString("sbVillePositionDataStringSave");
    if(sbVillePositionDataStringSave != ""){
        sbVillePositionData = PositionData(sbVillePositionDataStringSave);
    }else{
        sbVillePositionData = PositionData(0, greyColor1, Icons::Circle);
    }
#endif

    OnSettingsChanged();
}