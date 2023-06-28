bool bInCustomMenu = false;
bool bGameStarted = false;
string sPluginVersion = "YEPTREE";
bool bSkipTick = false;

void RenderMenu()
{
	if (!bGameStarted and UI::MenuItem("\\$f80" + Icons::Sitemap + "\\$fff Play \\$sROGUEMANIA", "", bGameStarted, bInCustomMenu)) {
		if (!Permissions::PlayLocalMap())
		{
			UI::ShowNotification("ROGUEMANIA", "You need atleast a standard access to play RogueMania Sadge", vec4(0.7, 0.0, 0.0, 1.0), 5000);	
			return;
		}
		
		bGameStarted = true;
		bRMUI_Intro = true;
		
		UI::HideOverlay();
	}
}

void Render()
{
	if (!bGameStarted) {
		return;
	}

	RMUI_Render();
}

void Main()
{
	RMUI_Load();
	FetchMapTags();
	
	auto app = GetApp();
	
	sPluginVersion = Meta::ExecutingPlugin().Version;
	
	while (true) {
		bInCustomMenu = false;
		for (uint i = 0; i < app.ActiveMenus.Length; i++) {
			if (app.ActiveMenus[i].CurrentFrame.IdName == "FrameMenuCustom") {
				bInCustomMenu = true;
			}
		}
		
		if (!bRMUI_IsInMenu && bGameStarted && !bMapLoading)
		{
			if (bInCustomMenu)
			{
				bRMUI_IsInMenu = true;
				sCurrentTrackUID = "";
				iCurrentTrackI = -1;				
			}
			else if(iCurrentTrackI > -1)
			{
				if (sCurrentTrackUID == GetCurrentTrackUID() && GetCurrentMapPBTime() > 0 && (GetCurrentMapPBTime() < rmgLoadedGame.tMaps[iCurrentTrackI].iBestTime || rmgLoadedGame.tMaps[iCurrentTrackI].iBestTime <= 0))
				{
					rmgLoadedGame.tMaps[iCurrentTrackI].iBestTime = GetCurrentMapPBTime();
					if (rmgLoadedGame.tMaps[iCurrentTrackI].iBestTime <= rmgLoadedGame.tMaps[iCurrentTrackI].iTimeToBeat)
					{
						UserBeatMap();
					}
				}
			}
		}
		
		yield();
		
		if(bGameStarted && bRMUI_IsInMenu && iRMUI_CurrentPage == RM_PAGE_GAME)
		{	
		
			if(bSkipTick)
			{
				bSkipTick = false;
			}
			else
			{
				vec2 vMousePos = UI::GetMousePos();
				int iWidth = Draw::GetWidth();
				int iHeight = Draw::GetHeight();
			
				if(vMousePos.x < 0 && vMousePos.y < 0)
				{
					// alt tab
				}
				else
				{
					if(vMousePos.x < (iWidth/100))
					{
						rmgLoadedGame.iCameraPosX += 1;
					}
					else if(vMousePos.x > iWidth - (iWidth/100))
					{
						rmgLoadedGame.iCameraPosX -= 1;
					}
					
					if(vMousePos.y < (iHeight/100))
					{
						rmgLoadedGame.iCameraPosY -= 1;
					}
					else if(vMousePos.y > iHeight - (iHeight/100))
					{
						rmgLoadedGame.iCameraPosY += 1;
					}
				}				
				
				bSkipTick = true;
			}
		}
		
		yield();
	}	
}

void OnKeyPress(bool down, VirtualKey key)
{
	if (!bGameStarted || !bRMUI_IsInMenu || iRMUI_CurrentPage != RM_PAGE_GAME || !down) { return; }

	if(key == VirtualKey::W)
	{
		rmgLoadedGame.iCameraPosY -= 1;
	}
	if(key == VirtualKey::S)
	{
		rmgLoadedGame.iCameraPosY += 1;
	}	
	if(key == VirtualKey::A)
	{
		rmgLoadedGame.iCameraPosX += 1;
	}
	if(key == VirtualKey::D)
	{
		rmgLoadedGame.iCameraPosX -= 1;
	}	

	if(key == VirtualKey::R)
	{
		rmgLoadedGame.iCameraPosX = -1;
		rmgLoadedGame.iCameraPosY = 1;
	}		
}	