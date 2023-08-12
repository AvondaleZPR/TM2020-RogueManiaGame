const int RM_PAGE_MAIN 		= 1;
const int RM_PAGE_GAME 		= 2;
const int RM_PAGE_LOAD 		= 3;
const int RM_PAGE_CREDITS 	= 4;
const int RM_PAGE_SETTINGS 	= 5;
const int RM_PAGE_DEV 		= 6;
const int RM_PAGE_SAVE		= 7;
const int RM_PAGE_STORE		= 8;
const int RM_PAGE_STATS		= 9;
const int RM_PAGE_GAMEMODE	= 10;
const int RM_PAGE_VICTORY	= 11;

int iRMUI_CurrentPage = RM_PAGE_MAIN;
int iRMUI_DevModeCheck = 0;
float iRMUI_IntroTime = 0.0;
float fRMUI_ARScale = 1.0;

bool bRMUI_IsInMenu = true;
bool bRMUI_Intro = true;
bool bRMUI_InDevMode = false;

UI::Font@ fButton;
UI::Font@ fCredit;
UI::Texture@ tMapImagePlaceholder;
UI::Texture@ tChest;
UI::Texture@ tCasino;
nvg::Texture@ tIntro;
nvg::Texture@ tLogo;
nvg::Texture@ tMapBg;
Audio::Sample@ sVictorySong;

string sSaveGameName = "SaveGame";
int iRMUI_Difficulty = 0;
int iRMUI_GameMode = GAMEMODE_REGULAR;

void RMUI_Load()
{
	fRMUI_ARScale = GetARScale(Draw::GetWidth(), Draw::GetHeight(), 0.0);
	int iFontScale = Math::Floor(72 * fRMUI_ARScale);
	if(iFontScale > 72) {iFontScale = 72;}

	@fButton = UI::LoadFont("data/fonts/Cinzel.ttf",  iFontScale, -1, -1, true, true, true);
	//@fCredit = UI::LoadFont("data/fonts/Cinzel.ttf", 42, -1, -1, true, true, true);
	@tMapImagePlaceholder = UI::LoadTexture("data/images/mapimage_placeholder.jpg");
	@tChest = UI::LoadTexture("data/images/chest.png");
	@tCasino = UI::LoadTexture("data/images/casino.png");	
	@tIntro = nvg::LoadTexture("data/images/intro.png", 0);
	@tLogo = nvg::LoadTexture("data/images/logo2.png", 0);
	//@tMapBg = nvg::LoadTexture("data/images/mapbg.png", 0);
	@sVictorySong = Audio::LoadSample("data/sound/victory.wav");
}

void RMUI_Render()
{
	if (!bRMUI_IsInMenu) {return;}

	int iWidth = Draw::GetWidth();
	int iHeight = Draw::GetHeight();
	fRMUI_ARScale = GetARScale(iWidth, iHeight, 0.0);

	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::SetNextWindowPos(0, 0);
	UI::SetNextWindowSize(iWidth, iHeight);
	UI::Begin("NoMenuClicks", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings + UI::WindowFlags::NoBringToFrontOnFocus);
	//bLMBPressed = UI::InvisibleButton("MouseMovement", vec2(iWidth, iHeight-50), UI::ButtonFlags::MouseButtonLeft);
	UI::End();
	UI::PopStyleColor();	

	nvg::BeginPath();
	nvg::RoundedRect(0, 0, iWidth, iHeight, 0);
	nvg::FillColor(vec4(0,0,0,255));
	nvg::Fill();
	nvg::ClosePath();

	if (bRMUI_Intro)
	{
		iRMUI_IntroTime = iRMUI_IntroTime + 1.0;
	
		nvg::BeginPath();
		nvg::FillPaint(nvg::TexturePattern(vec2(500*fRMUI_ARScale, 300*fRMUI_ARScale), vec2(900*fRMUI_ARScale, 450*fRMUI_ARScale), 0.0, tIntro, 1.0 - (iRMUI_IntroTime / 1000) * 2));
		nvg::Fill();
		nvg::ClosePath();		
		
		if (iRMUI_IntroTime >= 500) {
			iRMUI_IntroTime = 0;
			bRMUI_Intro = false; 
		}
		
		return;
	}

	if (iRMUI_CurrentPage != RM_PAGE_GAME && iRMUI_CurrentPage != RM_PAGE_DEV && iRMUI_CurrentPage != RM_PAGE_STORE && iRMUI_CurrentPage != RM_PAGE_STATS) // Logo
	{
		nvg::BeginPath();
		nvg::FillPaint(nvg::TexturePattern(vec2(660*fRMUI_ARScale, 0), vec2(600*fRMUI_ARScale, 300*fRMUI_ARScale), 0.0, tLogo, 255.0));
		nvg::Fill();
		nvg::ClosePath();
	}

	if (iRMUI_CurrentPage == RM_PAGE_GAME || iRMUI_CurrentPage == RM_PAGE_STORE || iRMUI_CurrentPage == RM_PAGE_STATS || iRMUI_CurrentPage == RM_PAGE_VICTORY)
	{
		UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
		UI::PushFont(fButton);	
		UI::SetNextWindowPos(iWidth-300*fRMUI_ARScale, 0, UI::Cond::Always);
		UI::SetNextWindowSize(300*fRMUI_ARScale, 500*fRMUI_ARScale);
		UI::Begin("Consumables", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
		UI::TextWrapped("Cash: $" + rmgLoadedGame.iCash);
		UI::TextWrapped("Rerolls: " + rmgLoadedGame.iRerolls);	
		UI::TextWrapped("Skips: " + rmgLoadedGame.iSkips);
		UI::End();	
		UI::PopFont();
		UI::PopStyleColor();		
	}

	if (iRMUI_CurrentPage == RM_PAGE_GAME) 		{ RMUI_RenderGamePage();  return; }
	if (iRMUI_CurrentPage == RM_PAGE_STORE) 	{ RMUI_RenderStorePage(); return; }

	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::PushFont(fButton);
	UI::SetNextWindowPos(800*fRMUI_ARScale, 300*fRMUI_ARScale);
	UI::SetNextWindowSize(1000*fRMUI_ARScale, 800*fRMUI_ARScale);
	UI::Begin("MenuButtons", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
	if (iRMUI_CurrentPage == RM_PAGE_MAIN) 		{ RMUI_RenderMainPage(); }
	if (iRMUI_CurrentPage == RM_PAGE_LOAD) 		{ RMUI_RenderLoadPage(); }
	if (iRMUI_CurrentPage == RM_PAGE_CREDITS) 	{ RMUI_RenderCreditsPage(); }
	if (iRMUI_CurrentPage == RM_PAGE_SETTINGS) 	{ RMUI_RenderSettingsPage(); }
	if (iRMUI_CurrentPage == RM_PAGE_DEV) 		{ RMUI_RenderDevPage(); }
	if (iRMUI_CurrentPage == RM_PAGE_SAVE) 		{ RMUI_RenderSavePage(); }
	if (iRMUI_CurrentPage == RM_PAGE_STATS) 	{ RMUI_RenderStatsPage(); }	
	if (iRMUI_CurrentPage == RM_PAGE_GAMEMODE) 	{ RMUI_RenderGamemodePage(); }	
	if (iRMUI_CurrentPage == RM_PAGE_VICTORY) 	{ RMUI_RenderVictoryPage(); }	
	UI::End();
	UI::PopFont();
	UI::PopStyleColor();
}

bool RMUI_RenderButton(const string &in sText)
{
	return UI::ButtonColored(sText, 0, 0, 0, vec2(300*fRMUI_ARScale,150*fRMUI_ARScale));
}

void RMUI_RenderText(const string &in sText)
{
	UI::TextWrapped(sText);
}

//------------------------------------------------------------------------------

void RMUI_RenderMainPage()
{
	if (RMUI_RenderButton("New Game"))
	{
		iRMUI_CurrentPage = RM_PAGE_GAMEMODE;
	}
	
	if (RMUI_RenderButton("Load"))
	{
		SG_LoadSaveGames();
		iRMUI_CurrentPage = RM_PAGE_LOAD;
	}	
	
	if (RMUI_RenderButton("Credits"))
	{
		iRMUI_CurrentPage = RM_PAGE_CREDITS;
	}	
	
	if (RMUI_RenderButton("Exit"))
	{
		bGameStarted = false;
	}	
	
	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::PushFont(fButton);
	if (bRMUI_InDevMode) { UI::PushStyleColor(UI::Col::Text, vec4(1.0, 0.0, 0.0, 1.0)); }
	UI::SetNextWindowPos(0, 980*fRMUI_ARScale);
	UI::SetNextWindowSize(150*fRMUI_ARScale, 100*fRMUI_ARScale);
	UI::Begin("Version", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
	if (UI::ButtonColored(sPluginVersion, 0, 0, 0, vec2(140*fRMUI_ARScale,80*fRMUI_ARScale)) && !bRMUI_InDevMode)
	{
		if (iRMUI_DevModeCheck >= 5)
		{
			bRMUI_InDevMode = true;
		}
		else
		{
			iRMUI_DevModeCheck += 1;
		}
	}	
	UI::End();
	if (bRMUI_InDevMode) 
	{ 
		if (iRMUI_DevModeCheck >= 5)
		{
			iRMUI_DevModeCheck = 0;
		}
		else
		{
			UI::PopStyleColor(); 
		}
	}	
	UI::PopFont();
	UI::PopStyleColor();		
}

void RMUI_RenderGamePage() //ns
{
	for(int i = 0; i < rmgLoadedGame.tMaps.Length; i++)
	{
		int iXPos = 960 + ((rmgLoadedGame.tMaps[i].iRMUI_X * 400) + (rmgLoadedGame.iCameraPosX * 100));
		int iYPos = 540 - ((rmgLoadedGame.tMaps[i].iRMUI_Y * 400) + (rmgLoadedGame.iCameraPosY * 100));
		
		if (rmgLoadedGame.tMaps[i].iRMUI_AAS > 0)
		{
			rmgLoadedGame.tMaps[i].iRMUI_AAS -= 1;
		}
		
		if (rmgLoadedGame.tMaps[i].iMapType > MAP_CELL_TYPE_DEADEND)
		{
			/*
			nvg::BeginPath();
			nvg::FillPaint(nvg::TexturePattern(vec2(iXPos, iYPos), vec2(200, 200), 0.0, tMapBg, 0.5));
			nvg::Fill();
			nvg::ClosePath();	
			*/		
		
			nvg::BeginPath();
			nvg::FillColor(vec4(1.0, 1.0, 1.0, 0.4));
			nvg::RoundedRect(iXPos+90, iYPos-100, 15, 400, 0.0);
			nvg::Fill();	
			nvg::ClosePath();		

			nvg::BeginPath();
			nvg::FillColor(vec4(1.0, 1.0, 1.0, 0.4));		
			nvg::RoundedRect(iXPos-100, iYPos+90, 400, 15, 0.0);
			nvg::Fill();
			nvg::ClosePath();		
		}
		
		if(rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_CHOICE)
		{
			UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.0, 0.0, 0.8));
			UI::SetNextWindowPos(iXPos, iYPos, UI::Cond::Always);
			UI::SetNextWindowSize(200, 230);
			UI::Begin("RMUI_Map_" + i, UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
			UI::TextWrapped("Select this map's style: ");
			if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag1.Name, 0.35, 0.7, 1.0))
			{
				UserSelectMapType(i, rmgLoadedGame.tMaps[i].RandomTag1.ID);
			}
			if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag2.Name, 0.35, 0.7, 1.0))
			{
				UserSelectMapType(i, rmgLoadedGame.tMaps[i].RandomTag2.ID);
			}
			if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag3.Name, 0.35, 0.7, 1.0))
			{
				UserSelectMapType(i, rmgLoadedGame.tMaps[i].RandomTag3.ID);
			}			
			UI::End();
			UI::PopStyleColor();			
		}
		else if(rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_MAP)
		{
			if (rmgLoadedGame.tMaps[i].bLoaded)
			{
				if (!rmgLoadedGame.tMaps[i].bBeaten) 
				{
					UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.0, 0.0, 0.8));
				}
				else
				{
					UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.4, 0.1, 0.7));
				}
				UI::SetNextWindowPos(iXPos, iYPos, UI::Cond::Always);
				UI::SetNextWindowSize(200, 240);
				UI::Begin("RMUI_Map_" + i, UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
				//if (rmgLoadedGame.tMaps[i].bBeaten) {UI::PushStyleColor(UI::Col::Text, vec4(0.0, 0.7, 0.1, 1.0));}
				UI::TextWrapped(rmgLoadedGame.tMaps[i].miMapInfo.Name + " by " + rmgLoadedGame.tMaps[i].miMapInfo.Username);
				//if (rmgLoadedGame.tMaps[i].bBeaten) {UI::PopStyleColor();}
				if (rmgLoadedGame.tMaps[i].ciMapImage.m_texture !is null)
				{
					UI::Image(rmgLoadedGame.tMaps[i].ciMapImage.m_texture, vec2(190, 85));
				}
				else if (rmgLoadedGame.tMaps[i].ciThumbnail.m_texture !is null)
				{
					UI::Image(rmgLoadedGame.tMaps[i].ciThumbnail.m_texture, vec2(190, 85));
				}
				else
				{
					UI::Image(tMapImagePlaceholder, vec2(190, 85));
				}
				if (!rmgLoadedGame.tMaps[i].bBeaten || rmgLoadedGame.tMaps[i].bClaimed)
				{
					if (UI::ButtonColored("Play", 0.35, 0.7, 0.5) && iMapsLoading < 1)
					{
						UserPlayAMap(i);
					}
				}
				else
				{
					if (UI::ButtonColored("Claim", 0.35, 0.8, 0.5))
					{
						UserClaimAMap(i);
					}			
				}
				if (!rmgLoadedGame.tMaps[i].bBeaten)
				{
					UI::SameLine();		
					if (UI::ButtonColored("Reroll", 0.8, 0.7, 1.0) && rmgLoadedGame.iRerolls > 0)
					{
						UserRerollMap(i);
					}		
					UI::SameLine();		
					if (UI::ButtonColored("Skip", 0, 0.7, 1.0) && rmgLoadedGame.iSkips > 0)
					{
						UserSkipMap(i);
					}	
				}
				UI::TextWrapped("Reward: $" + rmgLoadedGame.tMaps[i].iReward);
				UI::TextWrapped("Time to beat: " + FormatTimer(rmgLoadedGame.tMaps[i].iTimeToBeat));
				if(rmgLoadedGame.tMaps[i].iBestTime > 0)
				{
					UI::TextWrapped("PB: " + FormatTimer(rmgLoadedGame.tMaps[i].iBestTime));
				}
				UI::End();
				UI::PopStyleColor();
			}
			else
			{
				UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.0, 0.0, 0.8));
				UI::SetNextWindowPos(iXPos, iYPos, UI::Cond::Always);
				UI::SetNextWindowSize(200, 230);
				UI::Begin("RMUI_Map_" + i, UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);	
				UI::TextWrapped("MAP LOADING...");
				UI::End();
				UI::PopStyleColor();					
			}
		}
		else if(rmgLoadedGame.tMaps[i].iMapType > MAP_CELL_TYPE_DEADEND)
		{
				if (!rmgLoadedGame.tMaps[i].bBeaten) 
				{
					UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.0, 0.0, 0.8));
				}
				else
				{
					if (rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_CASINO)
					{
						UI::PushStyleColor(UI::Col::WindowBg, vec4(0.3, 0.0, 0.0, 0.7));
					}
					else
					{
						UI::PushStyleColor(UI::Col::WindowBg, vec4(0.0, 0.3, 0.1, 0.7));
					}
				}
				UI::SetNextWindowPos(iXPos, iYPos, UI::Cond::Always);
				UI::SetNextWindowSize(200, 230);
				UI::Begin("RMUI_Map_" + i, UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
				if(rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_LOOT)
				{
					UI::Image(tChest, vec2(190, 150));
					UI::TextWrapped("Reward: $" + rmgLoadedGame.tMaps[i].iReward);
					if (!rmgLoadedGame.tMaps[i].bBeaten)
					{
						if (UI::ButtonColored("Collect", 0.35, 0.8, 0.5))
						{
							UserLootedChest(i);
						}	
					}
				}
				else if(rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_CASINO)
				{
					UI::Image(tCasino, vec2(190, 150));
					if (!rmgLoadedGame.tMaps[i].bBeaten)
					{					
						UI::TextWrapped("50% Chance for x10!!!");
						if (UI::ButtonColored("PLAY ($" + rmgLoadedGame.tMaps[i].iCasinoCost + ")" , 0.35, 0.8, 0.5) && rmgLoadedGame.iCash >= rmgLoadedGame.tMaps[i].iCasinoCost)
						{
							UserPlayedCasino(i);
						}	
					}
					else
					{
						UI::TextWrapped("Unfortunately you lost :( Come back another time!");
					}
				}
				UI::End();
				UI::PopStyleColor();				
		}
		else // empty deadend
		{
			
		}
	}
	
	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::PushFont(fButton);
	UI::SetNextWindowPos(0, Draw::GetHeight()-300*fRMUI_ARScale, UI::Cond::Always);
	UI::SetNextWindowSize(180*fRMUI_ARScale, 300*fRMUI_ARScale);
	UI::Begin("GameButtons", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
	if (UI::ButtonColored("Store", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		iRMUI_CurrentPage = RM_PAGE_STORE;
	}	
	if (UI::ButtonColored("Stats", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		iRMUI_CurrentPage = RM_PAGE_STATS;
	}		
	if (UI::ButtonColored("Exit", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)) && iMapsLoading < 1)
	{
		SG_Save(@rmgLoadedGame);
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}	
	UI::End();
	UI::PushStyleColor(UI::Col::Text, vec4(0.9, 0.9, 0.0, 0.9));
	UI::SetNextWindowPos(0, 20*fRMUI_ARScale, UI::Cond::Always);
	UI::SetNextWindowSize(600*fRMUI_ARScale, 90*fRMUI_ARScale);
	UI::Begin("Guide", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
	if(!rmgLoadedGame.bGameBeaten)
	{
		UI::TextWrapped("Use WASDR to move");
	}
	else
	{
		UI::TextWrapped("Victory!");
	}
	UI::End();	
	UI::PopStyleColor();
	UI::PopFont();
	UI::PopStyleColor();	
}

void RMUI_RenderLoadPage()
{
	if(tLoadedSaveGames.Length > 0)
	{
		for(int i = 0; i < tLoadedSaveGames.Length; i++)
		{
			if (!tLoadedSaveGamesPaths[i].EndsWith("_BACKUP") && RMUI_RenderButton(tLoadedSaveGames[i]))
			{
				SG_Load(tLoadedSaveGamesPaths[i]);
				iRMUI_CurrentPage = RM_PAGE_GAME;
				SG_Save(rmgLoadedGame, true);
			}	
		}
	}
	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}	
}

void RMUI_RenderCreditsPage()
{
	RMUI_RenderText("Developer:");
	RMUI_RenderText("Avondale");
	RMUI_RenderText("");
	RMUI_RenderText("Thanks to:");
	RMUI_RenderText("Miss");
	RMUI_RenderText("Greep");
	RMUI_RenderText("Geekid");

	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}	
}

void RMUI_RenderSettingsPage()
{
	RMUI_RenderText("Difficulty:");
	UI::PushStyleColor(UI::Col::Text, vec4(0.8, 0.5, 0.2, 1.0));
	if (RMUI_RenderButton("Easy"))
	{
		iRMUI_Difficulty = 1;
		iRMUI_CurrentPage = RM_PAGE_SAVE;
	}
	UI::PopStyleColor();
	UI::PushStyleColor(UI::Col::Text, vec4(1.0, 1.0, 0.2, 1.0));
	if (RMUI_RenderButton("Normal"))
	{
		iRMUI_Difficulty = 2;
		iRMUI_CurrentPage = RM_PAGE_SAVE;
	}	
	UI::PopStyleColor();
	UI::PushStyleColor(UI::Col::Text, vec4(0.0, 0.7, 0.1, 1.0));	
	if (RMUI_RenderButton("Hard"))
	{
		iRMUI_Difficulty = 3;
		iRMUI_CurrentPage = RM_PAGE_SAVE;
	}	
	UI::PopStyleColor();
	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}	
}

void RMUI_RenderDevPage()
{
	/*
	
	*/
}

void RMUI_RenderSavePage()
{
	sSaveGameName = UI::InputText("Name", sSaveGameName, UI::InputTextFlags::AutoSelectAll);
	sSaveGameName = sSaveGameName.SubStr(0, 10);
	
	UI::PushStyleColor(UI::Col::Text, vec4(0.0, 1.0, 0.0, 1.0));	
	if (RMUI_RenderButton("Start"))
	{
		UserStartNewGame();
		
		iRMUI_CurrentPage = RM_PAGE_GAME;			
	}	
	UI::PopStyleColor();
	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}	
}

void RMUI_RenderStorePage() //ns
{
	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::PushFont(fButton);
	UI::SetNextWindowPos(560*fRMUI_ARScale, 395*fRMUI_ARScale);
	UI::SetNextWindowSize(800*fRMUI_ARScale, 740*fRMUI_ARScale);
	UI::Begin("StoreItems", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);		
	if (UI::ButtonColored("Reroll = $" + STORE_REROLL_PRICE, 0, 0, 0, vec2(400*fRMUI_ARScale,250*fRMUI_ARScale)) && rmgLoadedGame.iCash >= STORE_REROLL_PRICE)
	{
		rmgLoadedGame.AddCash(-STORE_REROLL_PRICE);
		rmgLoadedGame.iRerolls++;
	}
	UI::SameLine();
	if (UI::ButtonColored("Skip = $" + STORE_SKIP_PRICE, 0, 0, 0, vec2(400*fRMUI_ARScale,250*fRMUI_ARScale))&& rmgLoadedGame.iCash >= STORE_SKIP_PRICE)
	{
		rmgLoadedGame.AddCash(-STORE_SKIP_PRICE);		
		rmgLoadedGame.iSkips++;
	}		
	if (!rmgLoadedGame.bGameBeaten)
	{
		if (UI::ButtonColored("Victory = $" + STORE_VICTORY_PRICE, 0, 0, 0, vec2(500*fRMUI_ARScale,250*fRMUI_ARScale))&& rmgLoadedGame.iCash >= STORE_VICTORY_PRICE)
		{
			rmgLoadedGame.AddCash(-STORE_VICTORY_PRICE);		
			iRMUI_CurrentPage = RM_PAGE_VICTORY;
			rmgLoadedGame.iSkips = 999;
			rmgLoadedGame.iRerolls = 999;
			rmgLoadedGame.bGameBeaten = true;
			Audio::Play(sVictorySong);
		}
	}	
	UI::End();	
	UI::SetNextWindowPos(0, 980*fRMUI_ARScale);
	UI::SetNextWindowSize(160*fRMUI_ARScale, 100*fRMUI_ARScale);
	UI::Begin("StoreBackButton", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);		
	if (UI::ButtonColored("Back", 0, 0, 0, vec2(150*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		SG_Save(@rmgLoadedGame);
		iRMUI_CurrentPage = RM_PAGE_GAME;
	}	
	UI::End();
	UI::PopFont();
	UI::PopStyleColor();	
}

void RMUI_RenderStatsPage()
{
	RMUI_RenderText("Maps Beaten: " + rmgLoadedGame.iStatsMapsBeaten);
	RMUI_RenderText("Cash Earned: $" + rmgLoadedGame.iStatsTotalCash);
	RMUI_RenderText("Chests Looted: " + rmgLoadedGame.iStatsLootedChests);
	RMUI_RenderText("Times Played Casino: " + rmgLoadedGame.iStatsCasinoPlayed);
	RMUI_RenderText("Casino Money Won: $" + rmgLoadedGame.iStatsCasinoWin);
	RMUI_RenderText("Casino Money Lost: $" + rmgLoadedGame.iStatsCasinoLost);	
	RMUI_RenderText("Rerolls Used: " + rmgLoadedGame.iStatsRerollsUsed);	
	RMUI_RenderText("Skips Used: " + rmgLoadedGame.iStatsSkipsUsed);
	
	if(rmgLoadedGame.iGameMode == GAMEMODE_REGULAR)
	{
		RMUI_RenderText("Game Mode: Regular");
	}
	else if(rmgLoadedGame.iGameMode == GAMEMODE_KACKY)
	{
		RMUI_RenderText("Game Mode: Kacky");
	}
	else if(rmgLoadedGame.iGameMode == GAMEMODE_CAMPAIGN)
	{
		RMUI_RenderText("Game Mode: Nadeo Campaign");
	}	

	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_GAME;
	}		
}

void RMUI_RenderGamemodePage()
{
	RMUI_RenderText("GameMode:");

	if (RMUI_RenderButton("Regular"))
	{
		iRMUI_GameMode = GAMEMODE_REGULAR;
		iRMUI_CurrentPage = RM_PAGE_SETTINGS;
	}
	UI::PushStyleColor(UI::Col::Text, vec4(0.9, 0.0, 0.0, 1.0));
	if (RMUI_RenderButton("Kacky"))
	{
		iRMUI_GameMode = GAMEMODE_KACKY;
		iRMUI_CurrentPage = RM_PAGE_SETTINGS;
	}	
	UI::PopStyleColor();
	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_MAIN;
	}		
}

void RMUI_RenderVictoryPage()
{
	RMUI_RenderText("You Win!");
	if (RMUI_RenderButton("Continue"))
	{
		iRMUI_CurrentPage = RM_PAGE_GAME;
	}	
}