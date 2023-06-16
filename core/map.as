class RM_Map 
{
	bool bNotAMapYet = false;
	bool bBeaten = false;
	bool bClaimed = false;
	
    CachedImage@ ciThumbnail;
    CachedImage@ ciMapImage;	
	
	MapInfo@ miMapInfo;
	int iMapPackId;
	string sMapTags;
	
	int iRMUI_X;
	int iRMUI_Y;
	int iRMUI_AAS;
	
	int iReward;
	int iTimeToBeat;
	int iBestTime = -1;
	
	RM_Map() { }
	
	RM_Map(MapInfo@ miMapInfo, int iX, int iY, int iReward, int iMapPackId = -1, const string &in sMapTags = "")
	{
		@this.miMapInfo = miMapInfo;
		this.iRMUI_X = iX;
		this.iRMUI_Y = iY;
		this.iRMUI_AAS = 500;
		this.iReward = iReward;
		this.iMapPackId = iMapPackId;
		this.sMapTags = sMapTags;
		
		this.iTimeToBeat = miMapInfo.AuthorTime;		
		if (rmgLoadedGame.iDifficulty == 1)
		{
			this.iTimeToBeat *= 1.5;
		}
		if (rmgLoadedGame.iDifficulty == 2)
		{
			this.iTimeToBeat *= 1.25;
		}		
		
        @this.ciThumbnail = Images::CachedFromURL("https://trackmania.exchange/maps/screenshot_normal/" + miMapInfo.TrackID);
        @this.ciMapImage = Images::CachedFromURL("https://trackmania.exchange/maps/" + miMapInfo.TrackID + "/image/1");	
	}	
}