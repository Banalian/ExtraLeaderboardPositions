// File containing various unrelated functions that are general enough.

/**
 * Check if the current LeaderboardEntry is a valid medal time or not, for the "normal" mode if the user has a better time than the medal
 */
bool isAValidMedalTime(LeaderboardEntry@ time) {
    if(time.position == -1 && time.time == -1) {
        return false;
    }

    if(time.position == currentPbPosition && time.time == currentPbTime) {
        return false;
    }

    // We consider that if the position is 0, it's either below the WR, or the WR is the only one with that medal
    if(time.position == 0) {
        return false;
    }

    return true;
}


/**
 * Check if the current map has a Nadeo leaderboard or not
 * 
 * Needs to be called from a yieldable function
 */
bool MapHasNadeoLeaderboard(const string &in mapId){
    auto info = FetchEndpoint(NadeoServices::BaseURL() + "/api/token/map/" + mapId);

    return info.GetType() == Json::Type::Object;
}

/**
 * Force a refresh of the leaderboard ( requested by the user )
 * also remove the "failed request" lock
 */
void ForceRefresh(){
    failedRefresh = false;
    counterTries = 0;
    if(!refreshPosition){
            refreshPosition = true;
    }
}

// REGIONS ARE HARD CODED - Changes the list of zones to search to ALL zones in the scope of the player
// Please note - I can only test in my region (Texas, USA, North America), so while other regions should hypothetically work, it is not guaranteed.
// Also note some areas have another subdivision (such as in France and England) and I opted not to do a fourth layer of regions
void updateAllZonesToSearch(){
    if(currScope == 1){
        pluginName = playerContinent + " Leaderboard positions";
    }else if(currScope == 2){
        pluginName = playerCountry + " Leaderboard positions";
    }else if(currScope == 3){
        pluginName = playerRegion + " Leaderboard positions";
    }

    string baseRegion = playerRegion;
    if(playerRegion == "")
        baseRegion = playerCountry;

    allZonesToSearch = {};

    array<string> chineseRegions = {"北京市","天津市","河北省","山西省","内蒙古自治区","辽宁省","吉林省","黑龙江省","上海市","江苏省","浙江省","安徽省","福建省","江西省","山东省","河南省","湖北省","湖南省","广东省","广西壮族自治区","海南省","重庆市","四川省","贵州省","云南省","西藏自治区","陕西省","甘肃省","青海省","宁夏回族自治区","新疆维吾尔自治区","香港特别行政区","澳门特别行政区","台湾省"};
    array<string> austrianRegions = {"Burgenland","Carinthia","Lower Austria","Salzburg","Styria","Tyrol","Upper Austria","Vienna","Vorarlberg"};
    array<string> belgianRegions = {"Antwerpen","Brabant Wallon","Brussel Bruxelles","Hainaut","Liege","Limburg","Luxemburg","Namur","Oost-Vlaanderen","Vlaams-Brabant","West-Vlaanderen"};
    array<string> czechRegions = {"Jihoceský kraj","Jihomoravský kraj","Karlovarský kraj","Kraj Vysočina","Královéhradecký kraj","Liberecký kraj","Moravskoslezský kraj","Olomoucký kraj","Pardubický kraj","Plzeňský kraj","Praha","Středočeský kraj","Ustecký kraj","Zlínský kraj"};
    array<string> frenchRegions = {"Auvergne-Rhône-Alpes","Bourgogne-Franche-Comté","Bretagne","Centre-Val de Loire","Corsica","Grand Est","Hauts-de-France","Île-de-France","Normandie","Nouvelle-Aquitaine","Occitanie","Outre-mer","Pays-de-la-Loire","Provence-Alpes-Côte d'Azur"};
    array<string> germanRegions = {"Baden-Württemberg","Bayern","Berlin","Brandenburg","Bremen","Hamburg","Hessen","Mecklenburg-Vorpommern","Niedersachsen","Nordrhein-Westfalen","Rheinland-Pfalz","Saarland","Sachsen","Sachsen-Anhalt","Schleswig-Holstein","Thüringen"};
    array<string> hungarianRegions = {"Bács-Kiskun","Baranya","Békés","Borsod-Abaúj-Zemplén","Budapest","Csongrád","Fejér","Gyõr-Moson-Sopron","Hajdú-Bihar","Heves","Jász-Nagykun-Szolnok","Komárom-Esztergom","Nógrád","Pest","Somogy","Szabolcs-Szatmár-Bereg","Tolna","Vas","Veszprém","Zala"};
    array<string> italianRegions = {"Abruzzo","Basilicata","Calabria","Campania","Emilia-Romagna","Friuli-Venezia Giulia","Lazio","Liguria","Lombardia","Marche","Molise","Piemonte","Puglia","Sardegna","Sicilia","Toscana","Trentino-Alto Adige","Umbria","Valle D-Aosta","Veneto"};
    array<string> dutchRegions = {"Drenthe","Flevoland","Fryslân","Gelderland","Groningen","Limburg","Noord-Brabant","Noord-Holland","Overijssel","Utrecht","Zeeland","Zuid-Holland"};
    array<string> polishRegions = {"Dolnośląskie","Kujawsko-Pomorskie","Lubelskie","Lubuskie","Mazowieckie","Malopolskie","Opolskie","Podkarpackie","Podlaskie","Pomorskie","Śląskie","Świętokrzyskie","Warmińsko-Mazurskie","Wielkopolskie","Zachodniopomorskie","Łódzkie"};
    array<string> portugueseRegions = {"Açores","Alentejo","Algarve","Centro","Lisboa","Madeira","Norte"};
    array<string> russianRegions = {"Дальневосточный федеральный округ","Приволжский федеральный округ","Северо-Западный федеральный округ","Северо-Кавказский федеральный округ","Сибирский федеральный округ","Уральский федеральный округ","Центральный федеральный округ","Южный федеральный округ"};
    array<string> serbianRegions = {"Beograd","Kruševac","Niš","Novi Sad"};
    array<string> slovenianRegions = {"Dolenjska","Gorenjska","Koroška","Notranjska","Prekmurje","Primorska","Štajerska"};
    array<string> spanishRegions = {"Andalucia","Aragón","Asturias","Cantabria","Casilla-La Mancha","Castilla y León","Catalunya","Comunidad de Madrid","Comunitat Valenciana","Euskadi","Extremadura","Galicia","Illes Balears","Islas Canarias","La Rioja","Navarra","Región de Murcia"};
    array<string> swissRegions = {"Aargau","Appenzell-Ausserrhoden","Appenzell-Innerrhoden","Basel-Landschaft","Basel-Stadt","Bern","Fribourg","Genève","Glarus","Graubünden","Jura","Luzern","Neuchâtel","Nidwalden","Obwalden","Schaffhausen","Schwyz","Solothurn","St. Gallen","Thurgau","Ticino","Uri","Valais (Wallis)","Vaud","Zug","Zürich"};
    array<string> britishRegions = {"England","Northern Ireland","Scotland","Wales"};
    array<string> canadianRegions = {"Alberta","British Columbia","Manitoba","New Brunswick","Newfoundland and Labrador","Northwest Territories","Nova Scotia","Nunavut","Ontario","Prince Edward Island","Quebec","Saskatchewan","Yukon"};
    array<string> americanRegions = {"Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","Washington, D.C.","West Virginia","Wisconsin","Wyoming"};
    array<string> australianRegions = {"Australian Capital Territory","New South Wales","Northern Territory","Queensland","South Australia","Tasmania","Victoria","Western Australia"};
    array<string> brazilianRegions = {"Acre","Alagoas","Amapá","Amazonas","Bahia","Ceará","District fédéral","Espírito Santo","Goiás","Maranhão","Mato Grosso","Mato Grosso do Sul","Minas Gerais","Pará","Paraïba","Paraná","Pernambuco","Piauí","Rio de Janeiro","Rio Grande do Norte","Rio Grande do Sul","Roraima","Rondônia","Santa Catarina","São Paulo","Sergipe","Tocantins"};
    array<string> chileanRegions = {"Aisen","Antofagasta","Araucania","Arica y Parinacota","Atacama","Biobio","Coquimbo","Los Lagos","Los Rios","Magallanes y Antartica","Maule","OHiggins","Santiago","Tarapaca","Valparaiso"};

    if(currScope == 1){
        array<string> africanRegions = {"Algeria","Angola","Benin","Botswana","Burkina Faso","Burundi","Cameroon","Cabo Verde","Central African Republic","Chad","Comoros","Congo","Djibouti","DR Congo","Equatorial Guinea","Eritrea","Ethiopia","Gabon","Ghana","Guinea","Guinea-Bissau","Ivory Coast","Kenya","Lesotho","Liberia","Libya","Madagascar","Malawi","Mali","Mauritania","Mauritius","Morocco","Mozambique","Namibia","Niger","Nigeria","Rwanda","São Tomé and Príncipe","Senegal","Seychelles","Sierra Leone","Somalia","South Africa","South Sudan","Sudan","Tanzania","The Gambia","Togo","Tunisia","Uganda","Zambia","Zimbabwe"};
        array<string> asianRegions = {"Afghanistan","Armenia","Azerbaijan","Bangladesh","Bhutan","Brunei","Cambodia","Georgia","India","Indonesia","Japan","Kazakhstan","Kyrgyzstan","Laos","Malaysia","Maldives","Mongolia","Myanmar","Nepal","North Korea","Pakistan","Philippines","Singapore","South Korea","Sri Lanka","Tajikistan","Thailand","Timor-Leste","Turkmenistan","Uzbekistan","Vietnam"};
        for(int i = 0; i < chineseRegions.Length; i++){
            asianRegions.InsertLast(chineseRegions[i]);
        }
        array<string> europeanRegions = {"Albania","Andorra","Belarus","Bosnia and Herzegovina","Bulgaria","Croatia","Cyprus","Denmark","Estonia","Finland","Greece","Iceland","Ireland","Latvia","Liechtenstein","Luxembourg","North Macedonia","Malta","Moldova","Monaco","Montenegro","Norway","Romania","San Marino","Slovakia","Sweden","Turkey","Ukraine"};
        for(int i = 0; i < 26; i++){
            if(i < austrianRegions.Length){
                europeanRegions.InsertLast(austrianRegions[i]);
            }if(i < belgianRegions.Length){
                europeanRegions.InsertLast(belgianRegions[i]);
            }if(i < czechRegions.Length){
                europeanRegions.InsertLast(czechRegions[i]);
            }if(i < frenchRegions.Length){
                europeanRegions.InsertLast(frenchRegions[i]);
            }if(i < germanRegions.Length){
                europeanRegions.InsertLast(germanRegions[i]);
            }if(i < hungarianRegions.Length){
                europeanRegions.InsertLast(hungarianRegions[i]);
            }if(i < italianRegions.Length){
                europeanRegions.InsertLast(italianRegions[i]);
            }if(i < dutchRegions.Length){
                europeanRegions.InsertLast(dutchRegions[i]);
            }if(i < polishRegions.Length){
                europeanRegions.InsertLast(polishRegions[i]);
            }if(i < portugueseRegions.Length){
                europeanRegions.InsertLast(portugueseRegions[i]);
            }if(i < russianRegions.Length){
                europeanRegions.InsertLast(russianRegions[i]);
            }if(i < serbianRegions.Length){
                europeanRegions.InsertLast(serbianRegions[i]);
            }if(i < slovenianRegions.Length){
                europeanRegions.InsertLast(slovenianRegions[i]);
            }if(i < spanishRegions.Length){
                europeanRegions.InsertLast(spanishRegions[i]);
            }if(i < britishRegions.Length){
                europeanRegions.InsertLast(britishRegions[i]);
            }
            europeanRegions.InsertLast(swissRegions[i]); // There are 26 Swiss regions (most of any european country)
        }
        array<string> middleEastRegions = {"Bahrain","Egypt","Iran","Iraq","Israel","Jordan","Kuwait","Lebanon","Oman","Qatar","Saudi Arabia","Syria","United Arab Emirates","Yemen"};
        array<string> naRegions = {"Antigua and Barbuda","Bahamas","Barbados","Belize","Costa Rica","Cuba","Dominica","Dominican Republic","El Salvador","Grenada","Haiti","Honduras","Jamaica","Mexico","Nicaragua","Saint Kitts and Nevis","Saint Lucia","Saint Vincent and the Grenadines","Trinidad and Tobago"};
        for(int i = 0; i < canadianRegions.Length; i++){
            naRegions.InsertLast(canadianRegions[i]);
        }for(int i = 0; i < americanRegions.Length; i++){
            naRegions.InsertLast(americanRegions[i]);
        }
        array<string> oceanicRegions = {"Fiji","Marshall Islands","Micronesia","Nauru","New Zealand","Palau","Papua New Guinea","Samoa","Solomon Islands","Tonga","Tuvalu","Vanuatu"};
        for(int i = 0; i < australianRegions.Length; i++){
            oceanicRegions.InsertLast(australianRegions[i]);
        }
        array<string> saRegions = {"Argentina","Bolivia","Colombia","Ecuador","Guatemala","Guyana","Panama","Paraguay","Peru","Suriname","Uruguay","Venezuela"};
        for(int i = 0; i < brazilianRegions.Length; i++){
            saRegions.InsertLast(brazilianRegions[i]);
        }for(int i = 0; i < chileanRegions.Length; i++){
            saRegions.InsertLast(chileanRegions[i]);
        }

        for(int i = 0; i < europeanRegions.Length; i++){ // 542051 players
            if(europeanRegions[i] == baseRegion){
                allZonesToSearch = europeanRegions;
            }
        }
        for(int i = 0; i < naRegions.Length; i++){ // 120700 players
            if(naRegions[i] == baseRegion){
                allZonesToSearch = naRegions;
            }
        }
        for(int i = 0; i < saRegions.Length; i++){ // 28164 players
            if(saRegions[i] == baseRegion){
                allZonesToSearch = saRegions;
            }
        }
        for(int i = 0; i < asianRegions.Length; i++){ // 25982 players
            if(asianRegions[i] == baseRegion){
                allZonesToSearch = asianRegions;
            }
        }
        for(int i = 0; i < oceanicRegions.Length; i++){ // 18186 players
            if(oceanicRegions[i] == baseRegion){
                allZonesToSearch = oceanicRegions;
            }
        }
        for(int i = 0; i < africanRegions.Length; i++){ // 10332 players
            if(africanRegions[i] == baseRegion){
                allZonesToSearch = africanRegions;
            }
        }
        for(int i = 0; i < middleEastRegions.Length; i++){ // 7157 players
            if(middleEastRegions[i] == baseRegion){
                allZonesToSearch = middleEastRegions;
            }
        }

    }else if(currScope == 2){
        if(playerRegion == ""){
            allZonesToSearch.InsertLast(baseRegion);
        }else{
            for(int i = 0; i < frenchRegions.Length; i++){ // 135292 players
                if(frenchRegions[i] == baseRegion){
                    allZonesToSearch = frenchRegions;
                }
            }
            for(int i = 0; i < americanRegions.Length; i++){ // 120700 players
                if(americanRegions[i] == baseRegion){
                    allZonesToSearch = americanRegions;
                }
            }
            for(int i = 0; i < germanRegions.Length; i++){ // 104748 players
                if(germanRegions[i] == baseRegion){
                    allZonesToSearch = germanRegions;
                }
            }
            for(int i = 0; i < britishRegions.Length; i++){ // 33374 players
                if(britishRegions[i] == baseRegion){
                    allZonesToSearch = britishRegions;
                }
            }
            for(int i = 0; i < polishRegions.Length; i++){ // 25428 players
                if(polishRegions[i] == baseRegion){
                    allZonesToSearch = polishRegions;
                }
            }
            for(int i = 0; i < canadianRegions.Length; i++){ // 22030 players
                if(canadianRegions[i] == baseRegion){
                    allZonesToSearch = canadianRegions;
                }
            }
            for(int i = 0; i < italianRegions.Length; i++){ // 20784 players
                if(italianRegions[i] == baseRegion){
                    allZonesToSearch = italianRegions;
                }
            }
            for(int i = 0; i < dutchRegions.Length; i++){ // 19768 players
                if(dutchRegions[i] == baseRegion){
                    allZonesToSearch = dutchRegions;
                }
            }
            for(int i = 0; i < spanishRegions.Length; i++){ // 19012 players
                if(spanishRegions[i] == baseRegion){
                    allZonesToSearch = spanishRegions;
                }
            }
            for(int i = 0; i < belgianRegions.Length; i++){ // 18112 players
                if(belgianRegions[i] == baseRegion){
                    allZonesToSearch = belgianRegions;
                }
            }
            for(int i = 0; i < czechRegions.Length; i++){ // 15919 players
                if(czechRegions[i] == baseRegion){
                    allZonesToSearch = czechRegions;
                }
            }
            for(int i = 0; i < australianRegions.Length; i++){ // 14487 players
                if(australianRegions[i] == baseRegion){
                    allZonesToSearch = australianRegions;
                }
            }
            for(int i = 0; i < portugueseRegions.Length; i++){ // 13982 players
                if(portugueseRegions[i] == baseRegion){
                    allZonesToSearch = portugueseRegions;
                }
            }
            for(int i = 0; i < brazilianRegions.Length; i++){ // 9750 players
                if(brazilianRegions[i] == baseRegion){
                    allZonesToSearch = brazilianRegions;
                }
            }
            for(int i = 0; i < swissRegions.Length; i++){ // 9750 players
                if(swissRegions[i] == baseRegion){
                    allZonesToSearch = swissRegions;
                }
            }
            for(int i = 0; i < austrianRegions.Length; i++){ // 9601 players
                if(austrianRegions[i] == baseRegion){
                    allZonesToSearch = austrianRegions;
                }
            }
            for(int i = 0; i < russianRegions.Length; i++){ // 8871 players
                if(russianRegions[i] == baseRegion){
                    allZonesToSearch = russianRegions;
                }
            }
            for(int i = 0; i < hungarianRegions.Length; i++){ // 8837 players
                if(hungarianRegions[i] == baseRegion){
                    allZonesToSearch = hungarianRegions;
                }
            }
            for(int i = 0; i < serbianRegions.Length; i++){ // 3038 players
                if(serbianRegions[i] == baseRegion){
                    allZonesToSearch = serbianRegions;
                }
            }
            for(int i = 0; i < chileanRegions.Length; i++){ // 2880 players
                if(chileanRegions[i] == baseRegion){
                    allZonesToSearch = chileanRegions;
                }
            }
            for(int i = 0; i < slovenianRegions.Length; i++){ // 2880 players
                if(slovenianRegions[i] == baseRegion){
                    allZonesToSearch = slovenianRegions;
                }
            }
            for(int i = 0; i < chineseRegions.Length; i++){ // 1701 players
                if(chineseRegions[i] == baseRegion){
                    allZonesToSearch = chineseRegions;
                }
            }
        }
    }else if(currScope == 3){
        allZonesToSearch.InsertLast(baseRegion);
    }
}


/**
 * Check if the user can use the plugin or not, based on different conditions
 */
bool UserCanUseThePlugin(){
    //Since this plugin request the leaderboard, we need to check if the user's current subscription has those permissions
    return (Permissions::ViewRecords());
}


string GetIconForPosition(int position){
    if(position == 1){
        return podiumIcon[0];
    }else if(position > 1 && position <= 10){
        return podiumIcon[1];
    }else if(position > 10 && position <= 100){
        return podiumIcon[2];
    }else if(position > 100 && position <= 1000){
        return podiumIcon[3];
    }else if(position > 1000 && position <= 10000){
        return podiumIcon[4];
    }else{
        return "";
    }
}


/**
 * Fetch an endpoint from the Nadeo Live Services
 * 
 * Needs to be called from a yieldable function
 */
Json::Value FetchEndpoint(const string &in route) {
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }
    auto req = NadeoServices::Get("NadeoLiveServices", route);
    req.Start();
    while(!req.Finished()) {
        yield();
    }
    return Json::Parse(req.String());
}


/**
 * Format the time string in a readable format
 */
string TimeString(int scoreTime, bool showSign = false) {
    string timeString = "";
    if(showSign){
        if(scoreTime < 0){
            timeString += "-";
        }else{
            timeString += "+";
        }
    }
    
    timeString += Time::Format(Math::Abs(scoreTime));

    return timeString;
}

/**
 * Check if the new time is a new PB
 */
bool newPBSet(int timePbLocal) {
    if(!validMap){
        return false;
    }
    bool isLocalPbDifferent = timePbLocal != currentPbTime;
    if(isLocalPbDifferent){
        if(timePbLocal == -1){
            return false;
        }
        if(currentPbTime == -1){
            return true;
        }
        if(timePbLocal < currentPbTime){
            return true;
        }else{
            return false;
        }
    }else{
        return false;
    }
}


/**
 * return the string representation of a number based on some settings like shorter numbers, etc
 */
string NumberToString(int number){
    string numberString = "";

    if(number < 10000 || !shorterNumberRepresentation){
        numberString = "" + number;
    } else {
        numberString = "" + number / 1000 + "k";
    }

    return numberString;
}