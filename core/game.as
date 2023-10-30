RM_Game@ rmgLoadedGame;
string sCurrentTrackUID = "";
int iCurrentTrackI = -1;

const int STORE_REROLL_PRICE = 200;
const int STORE_SKIP_PRICE = 1000;
const int STORE_VICTORY_PRICE = 30000;
const int STORE_SKILLPOINT_PRICE = 350;

const int GAMEMODE_REGULAR = 1;
const int GAMEMODE_KACKY = 2;
const int GAMEMODE_CAMPAIGN = 3;
const int GAMEMODE_TOTD = 4;

class RM_Game 
{
	string sName;
	int iDifficulty;
	array<RM_Map@> tMaps;
	array<RM_Skill@> tSkills;
	int iGameMode;
	bool bGameBeaten = false;
	
	int iCameraPosX;
	int iCameraPosY;
	
	int iCash;
	int iSkips;
	int iRerolls;
	int iSkillpoints = 0;
	
	int iStatsTotalCash = 0;
	int iStatsMapsBeaten = 0;
	int iStatsLootedChests = 0;	
	int iStatsCasinoPlayed = 0;	
	int iStatsCasinoWin = 0;
	int iStatsCasinoLost = 0;
	int iStatsSkipsUsed = 0;
	int iStatsRerollsUsed = 0;
	int iStatsSkillsUpgraded = 0;
	
	RM_Game (const string &in sName, int iDifficulty, int iGameMode = GAMEMODE_REGULAR) 
	{ 
		this.sName = sName; 
		this.iDifficulty = iDifficulty; 
		this.iGameMode = iGameMode;
		
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
		
		if (json["bGameBeaten"] !is null)
		{
			this.bGameBeaten = json["bGameBeaten"];
		}

		if (json["iGameMode"] !is null)
		{
			iGameMode = json["iGameMode"];
		}
		else
		{
			iGameMode = GAMEMODE_REGULAR;
		}

		for(int i = 0; i < json["tMaps"]; i++)
		{
			tMaps.InsertLast(RM_Map(json["tMap" + i], i));
		}
		
		if(json["tSkills"] !is null)
		{
			for(int i = 0; i < json["tSkills"]; i++)
			{
				tSkills.InsertLast(RM_Skill(json["tSkill" + i]));
			}
		}
		
		if(json["iSkillpoints"] !is null)
		{
			this.iSkillpoints = json["iSkillpoints"];
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
		if(json["iStatsSkillsUpgraded"] !is null)
		{
			this.iStatsSkillsUpgraded = json["iStatsSkillsUpgraded"];
		}
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
		json["iGameMode"] = iGameMode;
		json["bGameBeaten"] = bGameBeaten;
	
		json["tMaps"] = tMaps.Length;
		for(int i = 0; i < tMaps.Length; i++)
		{
			json["tMap" + i] = tMaps[i].ToJson();
		}
		
		json["tSkills"] = tSkills.Length;
		for(int i = 0; i < tSkills.Length; i++)
		{
			json["tSkill" + i] = tSkills[i].ToJson();
		}
		
		json["iSkillpoints"] = iSkillpoints;
	
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
		json["iStatsSkillsUpgraded"] = iStatsSkillsUpgraded;
		
		return json;
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------
void UserStartNewGame()
{
	@rmgLoadedGame = RM_Game(sSaveGameName, iRMUI_Difficulty, iRMUI_GameMode);
	
	if (sSaveGameName == "ineedcash")
	{
		rmgLoadedGame.AddCash(99999);
	}
	if (sSaveGameName == "skilledaf")
	{
		rmgLoadedGame.iSkillpoints = 69;
	}	
	
	InitSkills();
	
	if (rmgLoadedGame.iGameMode == GAMEMODE_KACKY)
	{
		AddNewRandomMap(0, 0, 100);
	}
	else if (rmgLoadedGame.iGameMode == GAMEMODE_TOTD)
	{
		AddNewRandomMap(0, 0, 100);
	}
	else
	{
		AddNewRandomMap(0, 0, 100, 40, "");
	}
	
	for(int i = 0; i < Math::Rand(5,10); i++)
	{
		AddNewRandomMap(Math::Rand(-10,10), Math::Rand(-10,10), RandomReward(), -1, "", false, false);
	}
	
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
	
	Audio::Play(sReward);
	
	//ExitToMainMenuPls();
	//bRMUI_IsInMenu = true;	
}

void UserClaimAMap(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.AddCash(GetSkillBonus(rmgLoadedGame.tMaps[iMapI].iReward, RM_SKILL_MAP_REWARD_BONUS));
	
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
	rmgLoadedGame.AddCash(GetSkillBonus(rmgLoadedGame.tMaps[iMapI].iReward, RM_SKILL_CHEST_REWARD_BONUS));
	
	if(Math::Rand(0,100) <= 10)
	{
		rmgLoadedGame.iRerolls++;
	}
	if(Math::Rand(0,100) <= 25)
	{
		rmgLoadedGame.iSkillpoints++;
	}
	
	rmgLoadedGame.iStatsLootedChests++;
	
	SG_Save(@rmgLoadedGame);
}

void UserPlayedCasino(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bBeaten = true;
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.iStatsCasinoPlayed++;
	
	if (Math::Rand(0,100) <= GetSkillBonus(10, RM_SKILL_CASINO_BONUS))
	{
		rmgLoadedGame.tMaps[iMapI].bCasinoWon = true;
		rmgLoadedGame.AddCash(rmgLoadedGame.tMaps[iMapI].iCasinoCost*5);
		rmgLoadedGame.iStatsCasinoWin += (rmgLoadedGame.tMaps[iMapI].iCasinoCost*5);
		
		Audio::Play(sReward);
	}
	else
	{
		rmgLoadedGame.tMaps[iMapI].bCasinoWon = false;
		rmgLoadedGame.AddCash(-rmgLoadedGame.tMaps[iMapI].iCasinoCost);
		rmgLoadedGame.iStatsCasinoLost += rmgLoadedGame.tMaps[iMapI].iCasinoCost;
		
		Audio::Play(sSkip);
	}

	
	SG_Save(@rmgLoadedGame);
}

void Event_UserLoadedGame()
{
	InitSkills();
}
//-----------------------------------------------------------------------------------------------------------------------------------

bool AddNewRandomMap(int iX, int iY, int iReward = 0, int iMapPackId = -1, string &in sTags = "", bool bCanBeARandomDeadEndType = false, bool bDiscovered = true)
{
	int iExistingMapId = GetMapAtCoordinates(iX, iY);
	if (iExistingMapId > -1) 
	{
		rmgLoadedGame.tMaps[iExistingMapId].bDiscovered = true;
		return false; 
	}

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
	
	if (iMapType == MAP_CELL_TYPE_CHOICE && (rmgLoadedGame.iGameMode == GAMEMODE_CAMPAIGN || rmgLoadedGame.iGameMode == GAMEMODE_TOTD))
	{
		iMapType = MAP_CELL_TYPE_MAP;
	}
	
	if (rmgLoadedGame.iGameMode == GAMEMODE_KACKY)
	{
		if (Math::Rand(0,1) == 0)
		{
			sTags = "23"; //kacky
		}
		else
		{
			sTags = "10"; //trial
		}
	}
	
	if (rmgLoadedGame.iGameMode == GAMEMODE_CAMPAIGN)
	{
		iMapPackId = 3559;
	}
	
	if (rmgLoadedGame.tSkills[RM_SKILL_FAVORITE_STYLE].bLearned && Math::Rand(0, 100) <= 50)
	{
		sTags = tostring(FindMapTagByName(rmgLoadedGame.tSkills[RM_SKILL_FAVORITE_STYLE].sStyleName).ID);
	}

	rmgLoadedGame.tMaps.InsertLast(RM_Map(iX, iY, iReward, iMapPackId, sTags, iMapType, bDiscovered));

	if(iMapType == MAP_CELL_TYPE_MAP)
	{
		PreloadRandomMap(CreateQueryURL(iMapPackId, sTags), rmgLoadedGame.tMaps.Length-1);
	}
	
	if(bDiscovered && rmgLoadedGame.tSkills[RM_SKILL_MAP_PREVIEW].bLearned && Math::Rand(0,100) <= 75)
	{
		int iPx = iX;
		int iPy = iY;
		int iInc = Math::Rand(-1,1);
		
		if (iInc != 0)
		{
			if(Math::Rand(0,1) == 0)
			{
				iPx += iInc;
			}
			else
			{
				iPy += iInc;
			}
			
			AddNewRandomMap(iPy, iPx, RandomReward(), -1, "", false, false);
		}
	}
	
	return bIsADeadEnd;
}

void ChangeRandomMap(int iMapI, int iMapPackId = -1, const string &in sTags = "")
{
	rmgLoadedGame.tMaps[iMapI] = RM_Map(rmgLoadedGame.tMaps[iMapI].iRMUI_X, rmgLoadedGame.tMaps[iMapI].iRMUI_Y, rmgLoadedGame.tMaps[iMapI].iReward, iMapPackId, sTags);
	PreloadRandomMap(CreateQueryURL(iMapPackId, sTags), iMapI);
}

void RequestMapPreload(RM_Map@ rmMap, int iMapI)
{
	if(rmMap.iTmxId > 0)
	{
		PreloadRandomMap(CreateQueryURLForTmxID(rmMap.iTmxId), iMapI);
		
	}
	else
	{
		PreloadRandomMap(CreateQueryURL(rmMap.iMapPackId, rmMap.sMapTags), iMapI);
	}
}

int GetMapAtCoordinates(int iX, int iY)
{
	for(int i = 0; i < rmgLoadedGame.tMaps.Length; i++)
	{
		if (rmgLoadedGame.tMaps[i] !is null && rmgLoadedGame.tMaps[i].iRMUI_X == iX && rmgLoadedGame.tMaps[i].iRMUI_Y == iY)
		{
			return i;
		}
	}
	
	return -1;
}

int RandomReward()
{
	return Math::Rand(50, 150);
}