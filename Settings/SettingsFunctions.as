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
    section.SetString("allPositionToGetStringSave", allPositionToGetStringSave);

    allPlayersToGetStringSave = "";
    for(int i = 0; i < nbSizePlayersToGetArray; i++){
        allPlayersToGetStringSave += "" + allPlayersToGet[i];
        if(i < nbSizePlayersToGetArray - 1){
            allPlayersToGetStringSave += ";";
        }
    }
    section.SetString("allPlayersToGetStringSave", allPlayersToGetStringSave);

    if(currMode == "Normal" || currMode == "Rival"){
        modeSave = currMode;
    }
    section.SetString("currMode", currMode);

    if(currScope > -1 && currScope < 4){
        scopeSave = currScope;
    }
    section.SetInt("currScope", currScope);
}

void OnSettingsLoad(Settings::Section& section){
    //load the array from the string
    allPositionToGetStringSave = section.GetString("allPositionToGetStringSave");

    if(allPositionToGetStringSave != ""){
        array<string> allPositionToGetTmp = allPositionToGetStringSave.Split(",");
        nbSizePositionToGetArray = allPositionToGetTmp.Length;

        for(int i = 0; i < nbSizePositionToGetArray; i++){
            allPositionToGet.InsertLast(Text::ParseInt(allPositionToGetTmp[i]));
        }

    }else{
        allPositionToGetStringSave = "1,10,100,1000,10000";
        nbSizePositionToGetArray = 5;
        allPositionToGet.InsertLast(1);
        allPositionToGet.InsertLast(10);
        allPositionToGet.InsertLast(100);
        allPositionToGet.InsertLast(1000);
        allPositionToGet.InsertLast(10000);
    }

    allPlayersToGetStringSave = section.GetString("allPlayersToGetStringSave");

    if(allPlayersToGetStringSave != ""){
        array<string> allPlayersToGetTmp = allPlayersToGetStringSave.Split(";");
        nbSizePlayersToGetArray = allPlayersToGetTmp.Length;

        for(int i = 0; i < nbSizePlayersToGetArray; i++){
            allPlayersToGet.InsertLast(allPlayersToGetTmp[i]);
        }
    }else{
        allPlayersToGetStringSave = "";
        nbSizePlayersToGetArray = 0;
        allPlayersToGet.InsertLast("");
    }

    modeSave = section.GetString("modeSave");
    if(modeSave != ""){
        currMode = modeSave;
    }else{
        currMode = "Normal";
    }

    scopeSave = section.GetInt("scopeSave");
    if(scopeSave > -1 && scopeSave < 4){
        currScope = scopeSave;
    }else{
        currScope = 0;
    }

    OnSettingsChanged();
}