RM_Game@ rmgLoadedGame;
string sCurrentTrackUID = "";
int iCurrentTrackI = -1;

const int STORE_REROLL_PRICE = 250;
const int STORE_SKIP_PRICE = 1250;

class RM_Game 
{
	string sName;
	int iDifficulty;
	array<RM_Map@> tMaps;
	
	int iCameraPosX;
	int iCameraPosY;
	
	int iCash;
	int iSkips;
	int iRerolls;
	
	int iStatsTotalCash = 0;
	int iStatsMapsBeaten = 0;
	int iStatsLootedChests = 0;	
	int iStatsCasinoPlayed = 0;	
	int iStatsCasinoWin = 0;
	int iStatsCasinoLost = 0;
	int iStatsSkipsUsed = 0;
	int iStatsRerollsUsed = 0;
	
	RM_Game (const string &in sName, int iDifficulty) 
	{ 
		this.sName = sName; 
		this.iDifficulty = iDifficulty; 
		
		iCameraPosX = -1;
		iCameraPosY = 1;
		iCash = 10;
		iSkips = 0;
		iRerolls = 1;
	}
	
	RM_Game (const Json::Value &in json)
	{
		this.sName = json["sName"];
		this.iDifficulty = json["iDifficulty"];

		for(int i = 0; i < json["tMaps"]; i++)
		{
			tMaps.InsertLast(RM_Map(json["tMap" + i]));
		}
		
		this.iCameraPosX = json["iCameraPosX"];
		this.iCameraPosY = json["iCameraPosY"];
		
		this.iCash = json["iCash"];
		this.iSkips = json["iSkips"];
		this.iRerolls = json["iRerolls"];
		
		this.iStatsTotalCash = json["iStatsTotalCash"];
		this.iStatsMapsBeaten = json["iStatsMapsBeaten"];
		this.iStatsLootedChests = json["iStatsLootedChests"];	
		this.iStatsCasinoPlayed = json["iStatsCasinoPlayed"];	
		this.iStatsCasinoWin = json["iStatsCasinoWin"];
		this.iStatsCasinoLost = json["iStatsCasinoLost"];
		this.iStatsSkipsUsed = json["iStatsSkipsUsed"];
		this.iStatsRerollsUsed = json["iStatsRerollsUsed"];
	}
	
	void AddCash(int iInc)
	{
		iCash += iInc;
		if (iInc > 0)
		{
			iStatsTotalCash += iInc;
		}
	}
	
	Json::Value ToJson()
	{
		Json::Value json = Json::Object();
	
		json["sName"] = sName;
		json["iDifficulty"] = iDifficulty;
	
		json["tMaps"] = tMaps.Length;
		for(int i = 0; i < tMaps.Length; i++)
		{
			json["tMap" + i] = tMaps[i].ToJson();
		}
	
		json["iCameraPosX"] = iCameraPosX;
		json["iCameraPosY"] = iCameraPosY;
		
		json["iCash"] = iCash;
		json["iSkips"] = iSkips; 
		json["iRerolls"] = iRerolls;
		
		json["iStatsTotalCash"] = iStatsTotalCash;
		json["iStatsMapsBeaten"] = iStatsMapsBeaten;
		json["iStatsLootedChests"] = iStatsLootedChests;
		json["iStatsCasinoPlayed"] = iStatsCasinoPlayed;
		json["iStatsCasinoWin"] = iStatsCasinoWin;
		json["iStatsCasinoLost"] = iStatsCasinoLost;
		json["iStatsSkipsUsed"] = iStatsSkipsUsed;
		json["iStatsRerollsUsed"] = iStatsRerollsUsed;
		
		return json;
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------
void UserStartNewGame()
{
	@rmgLoadedGame = RM_Game(sSaveGameName, iDifficulty);
	
	if (sSaveGameName == "ineedcash")
	{
		rmgLoadedGame.AddCash(99999);
	}
	
	AddNewRandomMap(0, 0, 100, 40, "");
	
	SG_Save(@rmgLoadedGame);
}

void UserPlayAMap(int iMapI)
{
	if (!rmgLoadedGame.tMaps[iMapI].bBeaten)
	{
		iCurrentTrackI = iMapI;
		sCurrentTrackUID = rmgLoadedGame.tMaps[iMapI].miMapInfo.TrackUID;
	}
	
	LoadMap(rmgLoadedGame.tMaps[iMapI].miMapInfo.TrackID);
	bRMUI_IsInMenu = false;
}

void UserBeatMap()
{
	rmgLoadedGame.tMaps[iCurrentTrackI].bBeaten = true;
	
	UI::ShowNotification("ROGUEMANIA", "You've beaten the required time on " + rmgLoadedGame.tMaps[iCurrentTrackI].miMapInfo.Name + "! Claim your reward!", vec4(0.0, 0.7, 0.0, 1.0), 10000);	
	
	sCurrentTrackUID = "";
	iCurrentTrackI = -1;
	
	rmgLoadedGame.iStatsMapsBeaten += 1;
	
	SG_Save(@rmgLoadedGame);
	
	//ExitToMainMenuPls();
	//bRMUI_IsInMenu = true;	
}

void UserClaimAMap(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.AddCash(rmgLoadedGame.tMaps[iMapI].iReward);
	
	int iMapX = rmgLoadedGame.tMaps[iMapI].iRMUI_X;
	int iMapY = rmgLoadedGame.tMaps[iMapI].iRMUI_Y;
	
	int iDeadEnds = 0;
	if(AddNewRandomMap(iMapX + 1, iMapY, RandomReward(), 0, "", !(iDeadEnds > 0))) {iDeadEnds++;}
	if(AddNewRandomMap(iMapX - 1, iMapY, RandomReward(), 0, "", !(iDeadEnds > 0))) {iDeadEnds++;}	
	if(AddNewRandomMap(iMapX, iMapY + 1, RandomReward(), 0, "", !(iDeadEnds > 0))) {iDeadEnds++;}
	if(AddNewRandomMap(iMapX, iMapY - 1, RandomReward(), 0, "", !(iDeadEnds > 0))) {iDeadEnds++;}
	
	SG_Save(@rmgLoadedGame);
}

void UserRerollMap(int iMapI)
{
	rmgLoadedGame.iRerolls -= 1;
	rmgLoadedGame.iStatsRerollsUsed += 1;
	
	ChangeRandomMap(iMapI, rmgLoadedGame.tMaps[iMapI].iMapPackId, rmgLoadedGame.tMaps[iMapI].sMapTags);
	
	SG_Save(@rmgLoadedGame);
}

void UserSkipMap(int iMapI)
{
	rmgLoadedGame.iSkips -= 1;
	rmgLoadedGame.iStatsSkipsUsed += 1;
	
	rmgLoadedGame.tMaps[iMapI].bBeaten = true;
	rmgLoadedGame.tMaps[iMapI].iReward = 0;
	UserClaimAMap(iMapI);
}

void UserSelectMapType(int iMapI, int iId)
{
	ChangeRandomMap(iMapI, -1, tostring(iId));
	
	SG_Save(@rmgLoadedGame);
}

void UserLootedChest(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bBeaten = true;
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.AddCash(rmgLoadedGame.tMaps[iMapI].iReward);
	
	rmgLoadedGame.iStatsLootedChests++;
	
	SG_Save(@rmgLoadedGame);
}

void UserPlayedCasino(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bBeaten = true;
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.AddCash(-rmgLoadedGame.tMaps[iMapI].iCasinoCost);
	
	rmgLoadedGame.iStatsCasinoPlayed++;
	rmgLoadedGame.iStatsCasinoLost += rmgLoadedGame.tMaps[iMapI].iCasinoCost;
	
	SG_Save(@rmgLoadedGame);
}
//-----------------------------------------------------------------------------------------------------------------------------------

bool AddNewRandomMap(int iX, int iY, int iReward = 0, int iMapPackId = -1, const string &in sTags = "", bool bCanBeARandomDeadEndType = false)
{
	if (MapExistsAtCoordinates(iX, iY)) { return false; }

	int iMapType = MAP_CELL_TYPE_MAP;
	bool bIsADeadEnd = false;	
	if (bCanBeARandomDeadEndType)
	{
		iMapType = Math::Rand(0,5);
		if(iMapType > MAP_CELL_TYPE_CASINO)
		{
			iMapType = MAP_CELL_TYPE_DEADEND;
		}
		if(iMapType != MAP_CELL_TYPE_MAP && iMapType != MAP_CELL_TYPE_CHOICE)
		{
			bIsADeadEnd = true;
		}
	}
	else
	{
		if (Math::Rand(0,1) == 1)
		{
			iMapType = MAP_CELL_TYPE_CHOICE;
		}
	}

	rmgLoadedGame.tMaps.InsertLast(RM_Map(iX, iY, iReward, iMapPackId, sTags, iMapType));

	if(iMapType == MAP_CELL_TYPE_MAP)
	{
		PreloadRandomMap(CreateQueryURL(iMapPackId, sTags), rmgLoadedGame.tMaps.Length-1);
	}
	
	return bIsADeadEnd;
}

void ChangeRandomMap(int iMapI, int iMapPackId = -1, const string &in sTags = "")
{
	rmgLoadedGame.tMaps[iMapI] = RM_Map(rmgLoadedGame.tMaps[iMapI].iRMUI_X, rmgLoadedGame.tMaps[iMapI].iRMUI_Y, rmgLoadedGame.tMaps[iMapI].iReward, iMapPackId, sTags);
	PreloadRandomMap(CreateQueryURL(iMapPackId, sTags), iMapI);
}

void RequestMapPreload(RM_Map@ rmMap)
{
	int iMapI;
	for(int i = 0; i < rmgLoadedGame.tMaps.Length; i++)
	{
		if(rmMap.iRMUI_X == rmgLoadedGame.tMaps[i].iRMUI_X && rmMap.iRMUI_Y == rmgLoadedGame.tMaps[i].iRMUI_Y)
		{
			iMapI = i;
			break;
		}
	}

	if(rmMap.iTmxId > 0)
	{
		PreloadRandomMap(CreateQueryURLForTmxID(rmMap.iTmxId), iMapI);
		
	}
	else
	{
		PreloadRandomMap(CreateQueryURL(rmMap.iMapPackId, rmMap.sMapTags), iMapI);
	}
}

bool MapExistsAtCoordinates(int iX, int iY)
{
	for(int i = 0; i < rmgLoadedGame.tMaps.Length; i++)
	{
		if (rmgLoadedGame.tMaps[i] !is null && rmgLoadedGame.tMaps[i].iRMUI_X == iX && rmgLoadedGame.tMaps[i].iRMUI_Y == iY)
		{
			return true;
		}
	}
	
	return false;
}

int RandomReward()
{
	return Math::Rand(50, 150);
}