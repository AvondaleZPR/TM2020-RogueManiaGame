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
	
	void AddCash(int iInc)
	{
		iCash += iInc;
		if (iInc > 0)
		{
			iStatsTotalCash += iInc;
		}
	}
}

void UserStartNewGame()
{
	@rmgLoadedGame = RM_Game(sSaveGameName, iDifficulty);
	
	if (sSaveGameName == "ineedcash")
	{
		rmgLoadedGame.AddCash(99999);
	}
	
	AddNewRandomMap(0, 0, 100, 40, "");
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
	
	//ExitToMainMenuPls();
	//bRMUI_IsInMenu = true;	
}

void UserClaimAMap(int iMapI)
{
	rmgLoadedGame.tMaps[iMapI].bClaimed = true;
	rmgLoadedGame.AddCash(rmgLoadedGame.tMaps[iMapI].iReward);
	
	int iMapX = rmgLoadedGame.tMaps[iMapI].iRMUI_X;
	int iMapY = rmgLoadedGame.tMaps[iMapI].iRMUI_Y;
	
	AddNewRandomMap(iMapX + 1, iMapY, RandomReward());
	AddNewRandomMap(iMapX - 1, iMapY, RandomReward());	
	AddNewRandomMap(iMapX, iMapY + 1, RandomReward());
	AddNewRandomMap(iMapX, iMapY - 1, RandomReward());	
}

void UserRerollMap(int iMapI)
{
	rmgLoadedGame.iRerolls -= 1;
	rmgLoadedGame.iStatsRerollsUsed += 1;
	
	ChangeRandomMap(iMapI, rmgLoadedGame.tMaps[iMapI].iMapPackId, rmgLoadedGame.tMaps[iMapI].sMapTags);
}

void UserSkipMap(int iMapI)
{
	rmgLoadedGame.iSkips -= 1;
	rmgLoadedGame.iStatsSkipsUsed += 1;
	
	rmgLoadedGame.tMaps[iMapI].bBeaten = true;
	rmgLoadedGame.tMaps[iMapI].iReward = 0;
	UserClaimAMap(iMapI);
}

void AddNewRandomMap(int iX, int iY, int iReward = 0, int iMapPackId = -1, const string &in sTags = "")
{
	if (MapExistsAtCoordinates(iX, iY)) { return; }

	PreloadRandomMap(CreateQueryURL(iMapPackId, sTags));
	while (isLoadingPreload) {yield();}
	rmgLoadedGame.tMaps.InsertLast(RM_Map(preloadedMap, iX, iY, iReward, iMapPackId, sTags));
}

void ChangeRandomMap(int iMapI, int iMapPackId = -1, const string &in sTags = "")
{
	PreloadRandomMap(CreateQueryURL(iMapPackId, sTags));
	while (isLoadingPreload) {yield();}
	rmgLoadedGame.tMaps[iMapI] = RM_Map(preloadedMap, rmgLoadedGame.tMaps[iMapI].iRMUI_X, rmgLoadedGame.tMaps[iMapI].iRMUI_Y, rmgLoadedGame.tMaps[iMapI].iReward, iMapPackId, sTags);
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
	return Math::Rand(100, 200);
}