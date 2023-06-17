const int MAP_CELL_TYPE_DEADEND 	= 0;
const int MAP_CELL_TYPE_MAP 		= 1;
const int MAP_CELL_TYPE_CHOICE 		= 2;
const int MAP_CELL_TYPE_LOOT 		= 3;
const int MAP_CELL_TYPE_CASINO 		= 4;

class RM_Map 
{
	bool bLoaded = false;
	bool bBeaten = false;
	bool bClaimed = false;
	
    CachedImage@ ciThumbnail;
    CachedImage@ ciMapImage;	
	
	int iTmxId;
	
	MapInfo@ miMapInfo;
	int iMapPackId;
	string sMapTags;
	
	int iRMUI_X;
	int iRMUI_Y;
	int iRMUI_AAS;
	
	int iReward;
	int iTimeToBeat;
	int iBestTime = -1;
	int iMapType = MAP_CELL_TYPE_MAP;
	int iCasinoCost;
	
	MapTag RandomTag1;
	MapTag RandomTag2;
	MapTag RandomTag3;
	
	RM_Map() { }
	
	RM_Map(int iX, int iY, int iReward, int iMapPackId = -1, const string &in sMapTags = "", int iMapType = MAP_CELL_TYPE_MAP)
	{
		this.iRMUI_X = iX;
		this.iRMUI_Y = iY;
		this.iRMUI_AAS = 500;
		this.iReward = iReward;
		this.iMapPackId = iMapPackId;
		this.sMapTags = sMapTags;
		this.iMapType = iMapType;	
		
		if (iMapType == MAP_CELL_TYPE_CHOICE)
		{
			RandomTag1 = RandomMapTag();
			RandomTag2 = RandomMapTag();
			RandomTag3 = RandomMapTag();
		}
		
		if (iMapType == MAP_CELL_TYPE_CASINO)
		{
			iCasinoCost = Math::Rand(200, 2000);
		}
	}	
	
	void LoadMapInfo(MapInfo@ miMapInfo)
	{
		this.iTimeToBeat = miMapInfo.AuthorTime;		
		if (rmgLoadedGame.iDifficulty == 1)
		{
			this.iTimeToBeat *= 1.5;
		}
		if (rmgLoadedGame.iDifficulty == 2)
		{
			this.iTimeToBeat *= 1.25;
		}			
	
		@this.miMapInfo = miMapInfo;
		@this.ciThumbnail = Images::CachedFromURL("https://trackmania.exchange/maps/screenshot_normal/" + miMapInfo.TrackID);
		@this.ciMapImage = Images::CachedFromURL("https://trackmania.exchange/maps/" + miMapInfo.TrackID + "/image/1");	
		
		this.iTmxId = miMapInfo.TrackID;
		bLoaded = true;
	}
	
	RM_Map(const Json::Value &in json)
	{
		this.bBeaten = json["bBeaten"];
		this.bClaimed = json["bClaimed"];		
	
		iMapPackId = json["iMapPackId"];
		sMapTags = json["sMapTags"];	
	
		this.iRMUI_X = json["iRMUI_X"];
		this.iRMUI_Y = json["iRMUI_Y"];
		this.iRMUI_AAS = json["iRMUI_AAS"];
		
		this.iReward = json["iReward"];
		this.iTimeToBeat = json["iTimeToBeat"];
		this.iBestTime = json["iBestTime"];
		this.iMapType = json["iMapType"];
		this.iCasinoCost = json["iCasinoCost"];
		
		this.RandomTag1 = MapTag(json["RandomTag1"]);
		this.RandomTag2 = MapTag(json["RandomTag2"]);
		this.RandomTag3 = MapTag(json["RandomTag3"]);
		
		if (iMapType == MAP_CELL_TYPE_MAP)
		{
			if (json["miMapInfo"] is null)
			{
				bLoaded = false;
				RequestMapPreload(this);
			}
			else
			{
				@this.miMapInfo = MapInfo(json["miMapInfo"]);
				@this.ciThumbnail = Images::CachedFromURL("https://trackmania.exchange/maps/screenshot_normal/" + miMapInfo.TrackID);
				@this.ciMapImage = Images::CachedFromURL("https://trackmania.exchange/maps/" + miMapInfo.TrackID + "/image/1");
				
				bLoaded = true;
			}			
		}
		
		
	}
	
	Json::Value ToJson()
	{
		Json::Value json = Json::Object();

		json["bBeaten"] = bBeaten;
		json["bClaimed"] = bClaimed;		
	
		if (miMapInfo !is null)
		{
			json["miMapInfo"] = miMapInfo.ToJson();
		}
		json["iMapPackId"] = iMapPackId;
		json["sMapTags"] = sMapTags;	
	
		json["iRMUI_X"] = iRMUI_X;
		json["iRMUI_Y"] = iRMUI_Y;
		json["iRMUI_AAS"] = iRMUI_AAS;
		
		json["iReward"] = iReward;
		json["iTimeToBeat"] = iTimeToBeat;
		json["iBestTime"] = iBestTime;
		json["iMapType"] = iMapType;
		json["iCasinoCost"] = iCasinoCost;
		
		json["RandomTag1"] = RandomTag1.ToJson();
		json["RandomTag2"] = RandomTag2.ToJson();
		json["RandomTag3"] = RandomTag3.ToJson();
		
		return json;
	}
}