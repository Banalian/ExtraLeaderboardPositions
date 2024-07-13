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
    section.SetString("allPositionDataStringSave", allPositionDataStringSave);

    medalsPositionDataStringSave = "";
    medalsPositionDataStringSave += currentPbPosition.Serialize() + ";";
    medalsPositionDataStringSave += atPositionData.Serialize() + ";";
    medalsPositionDataStringSave += goldPositionData.Serialize() + ";";
    medalsPositionDataStringSave += silverPositionData.Serialize() + ";";
    medalsPositionDataStringSave += bronzePositionData.Serialize();
    section.SetString("medalsPositionDataStringSave", medalsPositionDataStringSave);

#if DEPENDENCY_CHAMPIONMEDALS
    championMedalPositionDataStringSave = championMedalPositionData.Serialize();
    section.SetString("championMedalPositionDataStringSave", championMedalPositionDataStringSave);
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

    if(allPositionDataStringSave != ""){
        array<string> allPositionDataTmp = allPositionDataStringSave.Split(";");
        nbSizePositionDataArray = allPositionDataTmp.Length;

        for(int i = 0; i < nbSizePositionDataArray; i++){
            PositionData positionData = PositionData(allPositionDataTmp[i]);
            allPositionData.InsertLast(positionData);
        }
    }else{
        allPositionDataStringSave = "";
        nbSizePositionDataArray = 0;
    }

    medalsPositionDataStringSave = section.GetString("medalsPositionDataStringSave");
    
    if(medalsPositionDataStringSave != ""){
        array<string> medalsPositionDataTmp = medalsPositionDataStringSave.Split(";");
        if(medalsPositionDataTmp.Length == 5){
            currentPbPosition = PositionData(medalsPositionDataTmp[0]);
            atPositionData = PositionData(medalsPositionDataTmp[1]);
            goldPositionData = PositionData(medalsPositionDataTmp[2]);
            silverPositionData = PositionData(medalsPositionDataTmp[3]);
            bronzePositionData = PositionData(medalsPositionDataTmp[4]);
        }
    }else{
        currentPbPosition = PositionData(0, possibleColors[7], Icons::Circle);
        atPositionData = PositionData(0, possibleColors[0], Icons::Circle);
        goldPositionData = PositionData(0, possibleColors[1], Icons::Circle);
        silverPositionData = PositionData(0, possibleColors[2], Icons::Circle);
        bronzePositionData = PositionData(0, possibleColors[3], Icons::Circle);
    }

#if DEPENDENCY_CHAMPIONMEDALS
    championMedalPositionDataStringSave = section.GetString("championMedalPositionDataStringSave");
    if(championMedalPositionDataStringSave != ""){
        championMedalPositionData = PositionData(championMedalPositionDataStringSave);
    }else{
        championMedalPositionData = PositionData(0, possibleColors[4], Icons::Circle);
    }
#endif
#if DEPENDENCY_SBVILLECAMPAIGNCHALLENGES
    sbVillePositionDataStringSave = section.GetString("sbVillePositionDataStringSave");
    if(sbVillePositionDataStringSave != ""){
        sbVillePositionData = PositionData(sbVillePositionDataStringSave);
    }else{
        sbVillePositionData = PositionData(0, possibleColors[4], Icons::Circle);
    }
#endif

    OnSettingsChanged();
}