// ############################## SETTINGS CALLBACKS #############################

void OnSettingsChanged(){
    if(refreshTimer < 1){
        refreshTimer = 1;
    }
    updateFrequency = refreshTimer*60*1000; // = minutes * One minute in sec * 1000 milliseconds per second

    if(hiddingSpeedSetting < 0){
        hiddingSpeedSetting = 0;
    }

}

void OnSettingsSave(Settings::Section& section){
    //save the array in the string
    allFriendsToGetStringSave = "";
    allFriendsNameStringSave = "";
	trace("OnSettingsSave");
	trace(nbSizePositionToGetArray);
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allFriendsToGetStringSave += "" + allFriendsToGet[i];
        if(i < nbSizePositionToGetArray - 1){
            allFriendsToGetStringSave += ",";
        }
    }
    for(int i = 0; i < nbSizePositionToGetArray; i++){
        allFriendsNameStringSave += "" + allFriendsName[i];
        if(i < nbSizePositionToGetArray - 1){
            allFriendsNameStringSave += ",";
        }
    }
    section.SetString("allFriendsToGetStringSave", allFriendsToGetStringSave);
    section.SetString("allFriendsNameStringSave", allFriendsNameStringSave);
}

void OnSettingsLoad(Settings::Section& section){
    //load the array from the string
    allFriendsToGetStringSave = section.GetString("allFriendsToGetStringSave");

    if(allFriendsToGetStringSave != ""){
        allFriendsToGet = allFriendsToGetStringSave.Split(",");
        nbSizePositionToGetArray = allFriendsToGet.Length;
        allFriendsName = allFriendsNameStringSave.Split(",");
		while (allFriendsToGet.Length > allFriendsName.Length){
			allFriendsName.InsertLast("");
		}
    }else{
        allFriendsToGetStringSave = "";
        allFriendsNameStringSave = "";
        nbSizePositionToGetArray = 0;
    }

    OnSettingsChanged();
}