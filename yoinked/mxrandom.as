//yoinked from mxrandom https://github.com/GreepTheSheep/openplanet-MXRandom

MapInfo@ preloadedMap;
MapInfo@ mapInfo;
bool isLoadingPreload = false;
bool isLoadingMapInfo = false;
int iMapsLoading = 0;

void PreloadRandomMap(const string &in URL, int iMapI)
{
	startnew(PreloadRandomMapCoroutine, CoroutineURL(URL, iMapI));
}

class CoroutineURL 
{
	string URL;
	int iMapI;

	CoroutineURL(const string &in URL, int iMapI) 
	{ 
		this.URL = URL; 
		this.iMapI = iMapI;
	}
}

void PreloadRandomMapCoroutine(ref@ Data)
{
	string URL = cast<CoroutineURL>(Data).URL;
	int iMapI = cast<CoroutineURL>(Data).iMapI;
	//print(URL);

	isLoadingPreload = true;
	iMapsLoading+= 1;
	
	Json::Value res;
	try {
		res = GetAsync(URL)["results"][0];
	} catch {
		error("ManiaExchange API returned an error, retrying...");
		PreloadRandomMapCoroutine(Data);
		iMapsLoading = iMapsLoading - 1;
		return;
	}

	MapInfo@ map = MapInfo(res);

	if (map is null){
		warn("Map is null, retrying...");
		PreloadRandomMapCoroutine(Data);
		iMapsLoading = iMapsLoading - 1;
		return;
	}

	if (map.AuthorTime >= 120000) {
		warn("Map is too long, retrying...");
		PreloadRandomMapCoroutine(Data);
		iMapsLoading = iMapsLoading - 1;
		return;
	} 

	isLoadingPreload = false;
	iMapsLoading = iMapsLoading - 1;
	print("map loaded, maps left: " + iMapsLoading);
	
	@preloadedMap = map;
	rmgLoadedGame.tMaps[iMapI].LoadMapInfo(map);
}

string CreateQueryURL(int iMapPackID = -1, const string &in sMapTags = "")
{
	string url = "https://trackmania.exchange/mapsearch2/search?api=on&random=1&tagsinc=0";

	if(sMapTags != "") 
	{
		url += "&tags=" + sMapTags;
	}	
	else
	{
		url += "&etags=4,10,23,37,40";
	}
	
	if (iMapPackID > 0) 
	{
		url += "&mid=" + iMapPackID;
	}

	// prevent loading CharacterPilot maps
	url += "&vehicles=1";

	// prevent loading non-Race maps (Royal, flagrush etc...)
	url += "&mtype=TM_Race";

	return url;
}

string CreateQueryURLForTmxID(int iTmxId)
{
	return "https://trackmania.exchange/api/maps/get_map_info/id/" + iTmxId;
}

Net::HttpRequest@ Get(const string &in url)
{
	auto ret = Net::HttpRequest();
	ret.Method = Net::HttpMethod::Get;
	ret.Url = url;
	ret.Start();
	return ret;
}

Json::Value GetAsync(const string &in url)
{
	auto req = Get(url);
	//print(url);
	while (!req.Finished()) {
		yield();
	}
	string res = req.String();
	
	return Json::Parse(res);
}

Net::HttpRequest@ Post(const string &in url, const string &in body)
{
	auto ret = Net::HttpRequest();
	ret.Method = Net::HttpMethod::Post;
	ret.Url = url;
	ret.Body = body;
	ret.Headers.Set("Content-Type", "application/json");
	ret.Start();
	return ret;
}

Json::Value PostAsync(const string &in url, const string &in body)
{
	auto req = Post(url, body);
	while (!req.Finished()) {
		yield();
	}
	return Json::Parse(req.String());
}	

class MapInfo
{
	int TrackID;
	string TrackUID;
	int UserID;
	string Username;
	string AuthorLogin;
	string MapType;
	string ExeBuild;
	string UploadedAt;
	string UpdatedAt;
	Json::Value PlayedAt;
	string Name;
	string GbxMapName;
	string Comments;
	string TitlePack;
	bool Unlisted;
	string Mood;
	int DisplayCost;
	string LengthName;
	int Laps;
	string DifficultyName;
	string VehicleName;
	int AuthorTime;
	int TrackValue;
	int AwardCount;
	uint ImageCount;
	bool IsMP4;
	array<MapTag@> Tags;

	MapInfo(const Json::Value &in json)
	{
		try {
			TrackID = json["TrackID"];
			TrackUID = json["TrackUID"];
			UserID = json["UserID"];
			Username = json["Username"];
			AuthorLogin = json["AuthorLogin"];
			MapType = json["MapType"];
			ExeBuild = json["ExeBuild"];
			UploadedAt = json["UploadedAt"];
			UpdatedAt = json["UpdatedAt"];
			//if (json["PlayedAt"].GetType() != Json::Type::Null) PlayedAt = json["PlayedAt"];
			Name = json["Name"];
			GbxMapName = json["GbxMapName"];
			Comments = json["Comments"];
			if (json["TitlePack"].GetType() != Json::Type::Null) TitlePack = json["TitlePack"];
			Unlisted = json["Unlisted"];
			Mood = json["Mood"];
			DisplayCost = json["DisplayCost"];
			if (json["LengthName"].GetType() != Json::Type::Null) LengthName = json["LengthName"];
			Laps = json["Laps"];
			if (json["DifficultyName"].GetType() != Json::Type::Null) DifficultyName = json["DifficultyName"];
			if (json["VehicleName"].GetType() != Json::Type::Null) VehicleName = json["VehicleName"];
			if (json["AuthorTime"].GetType() != Json::Type::Null) AuthorTime = json["AuthorTime"];
			TrackValue = json["TrackValue"];
			AwardCount = json["AwardCount"];
			ImageCount = json["ImageCount"];
			IsMP4 = json["IsMP4"];

			// Tags is a string of ids separated by commas
			// gets the ids and fetches the tags from m_mapTags
			if (json["Tags"].GetType() != Json::Type::Null)
			{
				string tagIds = json["Tags"];
				string[] tagIdsSplit = tagIds.Split(",");
				for (uint i = 0; i < tagIdsSplit.Length; i++)
				{
					int tagId = Text::ParseInt(tagIdsSplit[i]);
					for (uint j = 0; j < m_mapTags.Length; j++)
					{
						if (m_mapTags[j].ID == tagId)
						{
							Tags.InsertLast(m_mapTags[j]);
							break;
						}
					}
				}
			}
		} catch {
			Name = json["Name"];
			warn("Error parsing infos for the map: "+ Name + "\nReason: " + getExceptionInfo());
		}
	}

	Json::Value ToJson()
	{
		Json::Value json = Json::Object();
		try {
			json["TrackID"] = TrackID;
			json["TrackUID"] = TrackUID;
			json["UserID"] = UserID;
			json["Username"] = Username;
			json["AuthorLogin"] = AuthorLogin;
			json["MapType"] = MapType;
			json["ExeBuild"] = ExeBuild;
			json["UploadedAt"] = UploadedAt;
			json["UpdatedAt"] = UpdatedAt;
			//json["PlayedAt"] = PlayedAt;
			json["Name"] = Name;
			json["GbxMapName"] = GbxMapName;
			json["Comments"] = Comments;
			json["TitlePack"] = TitlePack;
			json["Unlisted"] = Unlisted;
			json["Mood"] = Mood;
			json["DisplayCost"] = DisplayCost;
			json["LengthName"] = LengthName;
			json["Laps"] = Laps;
			json["DifficultyName"] = DifficultyName;
			json["VehicleName"] = VehicleName;
			json["AuthorTime"] = AuthorTime;
			json["TrackValue"] = TrackValue;
			json["AwardCount"] = AwardCount;
			json["ImageCount"] = ImageCount;
			json["IsMP4"] = IsMP4;

			string tagsStr = "";
			for (uint i = 0; i < Tags.Length; i++)
			{
				tagsStr += tostring(Tags[i].ID);
				if (i < Tags.Length - 1) tagsStr += ",";
			}
			json["Tags"] = tagsStr;
		} catch {
			error("Error converting map info to JSON for map "+Name);
		}
		return json;
	}
}

class MapTag
{
	int ID;
	string Name;
	string Color;
	
	MapTag() {}

	MapTag(const Json::Value &in json)
	{
		try {
			ID = json["ID"];
			Name = json["Name"];
			Color = json["Color"];
		} catch {
			ID = json["ID"];
			Name = json["Name"];
		}
	}
	
	Json::Value ToJson()
	{
		Json::Value json = Json::Object();
		json["ID"] = ID;
		json["Name"] = Name;
		json["Color"] = Color;
		return json;
	}
}

array<MapTag@> m_mapTags;
Net::HttpRequest@ req;

void FetchMapTags()
{
	m_mapTags.RemoveRange(0, m_mapTags.Length);

	Json::Value resNet = GetAsync("https://trackmania.exchange/api/tags/gettags");

	try {
		for (uint i = 0; i < resNet.Length; i++)
		{
			if (resNet[i]["Name"] != "FlagRush" && resNet[i]["Name"] != "Puzzle" && resNet[i]["Name"] != "Royal" && resNet[i]["Name"] != "Arena")
			{
				int tagID = resNet[i]["ID"];
				string tagName = resNet[i]["Name"];
				
				m_mapTags.InsertLast(MapTag(resNet[i]));
			}
		}
	} catch {
		warn("Error while loading tags");
	}
}

class PBTime {
    string name;
    string club;
    string wsid;
    uint time;
    string timeStr;
    string replayUrl;
    uint recordTs;
    string recordDate;
    bool isLocalPlayer;

    PBTime(CSmPlayer@ _player, CMapRecord@ _rec, bool _isLocalPlayer = false) {
        wsid = _player.User.WebServicesUserId; // rare null pointer exception here
        name = _player.User.Name;
        club = _player.User.ClubTag;
        isLocalPlayer = _isLocalPlayer;
        if (_rec !is null) {
            time = _rec.Time;
            replayUrl = _rec.ReplayUrl;
            recordTs = _rec.Timestamp;
        } else {
            time = 0;
            replayUrl = "";
            recordTs = 0;
        }
        UpdateCachedStrings();
    }

    void UpdateCachedStrings() {
        timeStr = time == 0 ? "???" : Time::Format(time);
        recordDate = recordTs == 0 ? "??-??-?? ??:??" : Time::FormatString("%y-%m-%d %H:%M", recordTs);
    }

    int opCmp(PBTime@ other) const {
        if (time == 0) {
            return (other.time == 0 ? 0 : 1); // one or both PB unset
        }
        if (other.time == 0 || time < other.time) return -1;
        if (time == other.time) return 0;
        return 1;
    }
}

string GetCurrentTrackUID()
{
	auto app = cast<CTrackMania>(GetApp());
	auto map = app.RootMap;
	if (map !is null)
	{
		return map.MapInfo.MapUid;
	}
	return "";
}

int GetCurrentMapPBTime()
{
	auto app = cast<CTrackMania>(GetApp());
	auto map = app.RootMap;
	CGamePlayground@ GamePlayground = cast<CGamePlayground>(app.CurrentPlayground);
	int time = -1;
	if (map !is null && GamePlayground !is null){
		CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
		if (PlaygroundScript !is null && GamePlayground.GameTerminals.Length > 0) {
			CSmPlayer@ player = cast<CSmPlayer>(GamePlayground.GameTerminals[0].ControlledPlayer);
			if (GamePlayground.GameTerminals[0].UISequence_Current == SGamePlaygroundUIConfig::EUISequence::Finish && player !is null) {
				CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
				auto ghost = PlaygroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);
				if (ghost !is null) {
					if (ghost.Result.Time > 0 && ghost.Result.Time < 4294967295) time = ghost.Result.Time;
					PlaygroundScript.DataFileMgr.Ghost_Release(ghost.Id);
				} else time = -1;
			} else time = -1;
		} else time = -1;
	}
	return time;
}