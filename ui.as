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
const int RM_PAGE_SKILLS	= 12;

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
array<UI::Texture@> ttSkills;
nvg::Texture@ tIntro;
nvg::Texture@ tLogo;
nvg::Texture@ tMapBg;
Audio::Sample@ sVictorySong;
Audio::Sample@ sClick;
Audio::Sample@ sClaim;
Audio::Sample@ sReward;
Audio::Sample@ sSkip;

string sSaveGameName = "SaveGame";
int iRMUI_Difficulty = 0;
int iRMUI_GameMode = GAMEMODE_REGULAR;

void RMUI_Load()
{
	fRMUI_ARScale = GetARScale(Draw::GetWidth(), Draw::GetHeight(), float(Draw::GetHeight())/float(Draw::GetWidth()));
	int iFontScale = Math::Floor(42 * fRMUI_ARScale);
	if(iFontScale > 72) {iFontScale = 72;}

	@fButton = UI::LoadFont("data/fonts/MainFont.ttf",  iFontScale, -1, -1, true, true, true);
	//@fCredit = UI::LoadFont("data/fonts/Cinzel.ttf", 42, -1, -1, true, true, true);
	@tMapImagePlaceholder = UI::LoadTexture("data/images/mapimage_placeholder.jpg");
	@tChest = UI::LoadTexture("data/images/chest.png");
	@tCasino = UI::LoadTexture("data/images/casino.png");	
	ttSkills.InsertLast(@tMapImagePlaceholder);	
	ttSkills.InsertLast(UI::LoadTexture("data/images/skills/skill_1.png"));	
	ttSkills.InsertLast(UI::LoadTexture("data/images/skills/skill_2.png"));	
	ttSkills.InsertLast(UI::LoadTexture("data/images/skills/skill_3.png"));	
	ttSkills.InsertLast(UI::LoadTexture("data/images/skills/skill_4.png"));	
	ttSkills.InsertLast(UI::LoadTexture("data/images/skills/skill_5.png"));	
	@tIntro = nvg::LoadTexture("data/images/intro.png", nvg::TextureFlags::GenerateMipmaps);
	@tLogo = nvg::LoadTexture("data/images/logo2.png", nvg::TextureFlags::Nearest);
	@sVictorySong = Audio::LoadSample("data/sound/victory.wav");
	@sClick = Audio::LoadSample("data/sound/click.wav");
	@sClaim = Audio::LoadSample("data/sound/claim.wav");
	@sReward = Audio::LoadSample("data/sound/reward.wav");
	@sSkip = Audio::LoadSample("data/sound/skip.wav");
}

void RMUI_Render()
{
	if (!bRMUI_IsInMenu) {return;}

	int iWidth = Draw::GetWidth();
	int iHeight = Draw::GetHeight();
	float fARValue = float(iHeight)/float(iWidth);
	fRMUI_ARScale = GetARScale(iWidth, iHeight, fARValue);

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

	if (iRMUI_CurrentPage != RM_PAGE_GAME && iRMUI_CurrentPage != RM_PAGE_DEV && iRMUI_CurrentPage != RM_PAGE_STORE && iRMUI_CurrentPage != RM_PAGE_STATS && iRMUI_CurrentPage != RM_PAGE_SKILLS) // Logo
	{
		nvg::BeginPath();
		nvg::FillPaint(nvg::TexturePattern(vec2(660*fRMUI_ARScale, 0), vec2(600*fRMUI_ARScale, 300*fRMUI_ARScale), 0.0, tLogo, 255.0));
		nvg::Fill();
		nvg::ClosePath();
	}

	if (iRMUI_CurrentPage == RM_PAGE_GAME || iRMUI_CurrentPage == RM_PAGE_STORE || iRMUI_CurrentPage == RM_PAGE_STATS || iRMUI_CurrentPage == RM_PAGE_VICTORY || iRMUI_CurrentPage == RM_PAGE_SKILLS)
	{
		UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
		UI::PushFont(fButton);	
		UI::SetNextWindowPos(iWidth-425*fRMUI_ARScale, 0, UI::Cond::Always);
		UI::SetNextWindowSize(425*fRMUI_ARScale, 500*fRMUI_ARScale);
		UI::Begin("Consumables", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
		UI::TextWrapped("Cash: $" + rmgLoadedGame.iCash);
		UI::TextWrapped("Rerolls: " + rmgLoadedGame.iRerolls);	
		UI::TextWrapped("Skips: " + rmgLoadedGame.iSkips);
		UI::TextWrapped("SkillPoints: " + rmgLoadedGame.iSkillpoints);
		UI::End();	
		UI::PopFont();
		UI::PopStyleColor();		
	}

	if (iRMUI_CurrentPage == RM_PAGE_GAME) 		{ RMUI_RenderGamePage();  return; }
	if (iRMUI_CurrentPage == RM_PAGE_STORE) 	{ RMUI_RenderStorePage(); return; }
	if (iRMUI_CurrentPage == RM_PAGE_SKILLS) 	{ RMUI_RenderSkillsPage(); return; }

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
	if (UI::ButtonColored(sText, 0, 0, 0, vec2(300*fRMUI_ARScale,150*fRMUI_ARScale)))
	{
		Audio::Play(sClick);
		return true;
	}
	
	return false;
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
			if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag1.Name, 0.35, 0.7, 0.5))
			{
				UserSelectMapType(i, rmgLoadedGame.tMaps[i].RandomTag1.ID);
			}
			else if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag2.Name, 0.35, 0.7, 0.5))
			{
				UserSelectMapType(i, rmgLoadedGame.tMaps[i].RandomTag2.ID);
			}
			else if (UI::ButtonColored(rmgLoadedGame.tMaps[i].RandomTag3.Name, 0.35, 0.7, 0.5))
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
				else if(!rmgLoadedGame.tMaps[i].bClaimed)
				{
					UI::PushStyleColor(UI::Col::WindowBg, vec4(0.7, 0.7, 0.1, 0.7));
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
				if(rmgLoadedGame.tMaps[i].bDiscovered)
				{
					if (!rmgLoadedGame.tMaps[i].bBeaten || rmgLoadedGame.tMaps[i].bClaimed)
					{
						if (UI::ButtonColored("Play", 0.35, 0.7, 0.5) && iMapsLoading < 1)
						{
							Audio::Play(sClick);
							UserPlayAMap(i);
						}
					}
					else
					{
						if (UI::ButtonColored("Claim", 0.35, 0.8, 0.5))
						{
							Audio::Play(sClaim);
							UserClaimAMap(i);
						}			
					}
					if (!rmgLoadedGame.tMaps[i].bBeaten)
					{
						UI::SameLine();		
						if (UI::ButtonColored("Reroll", 0.8, 0.7, 1.0) && rmgLoadedGame.iRerolls > 0)
						{
							Audio::Play(sSkip);
							UserRerollMap(i);
						}		
						UI::SameLine();		
						if (UI::ButtonColored("Skip", 0, 0.7, 1.0) && rmgLoadedGame.iSkips > 0)
						{
							Audio::Play(sSkip);
							UserSkipMap(i);
						}	
					}
				}
				UI::TextWrapped("Reward: $" + GetSkillBonus(rmgLoadedGame.tMaps[i].iReward, RM_SKILL_MAP_REWARD_BONUS));
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
					if (rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_CASINO && !rmgLoadedGame.tMaps[i].bCasinoWon)
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
					UI::TextWrapped("Reward: $" + GetSkillBonus(rmgLoadedGame.tMaps[i].iReward, RM_SKILL_CHEST_REWARD_BONUS));
					//UI::TextWrapped("Free Gold! And a small chance of finding Rerolls or SkillPoints!");
					if (!rmgLoadedGame.tMaps[i].bBeaten)
					{
						if (UI::ButtonColored("Collect", 0.35, 0.8, 0.5))
						{
							Audio::Play(sReward);
							UserLootedChest(i);
						}	
					}
				}
				else if(rmgLoadedGame.tMaps[i].iMapType == MAP_CELL_TYPE_CASINO)
				{
					UI::Image(tCasino, vec2(190, 150));
					if (!rmgLoadedGame.tMaps[i].bBeaten)
					{					
						UI::TextWrapped("50% Chance for x5!!!");
						if (UI::ButtonColored("PLAY ($" + rmgLoadedGame.tMaps[i].iCasinoCost + ")" , 0.35, 0.8, 0.5) && rmgLoadedGame.iCash >= rmgLoadedGame.tMaps[i].iCasinoCost)
						{
							UserPlayedCasino(i);
						}	
					}
					else
					{
						if (rmgLoadedGame.tMaps[i].bCasinoWon)
						{
							UI::TextWrapped("You win! Congratulations!");
						}
						else
						{
							UI::TextWrapped("Unfortunately you lost :( Come back another time!");
						}
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
	UI::SetNextWindowPos(0, Draw::GetHeight()-380*fRMUI_ARScale, UI::Cond::Always);
	UI::SetNextWindowSize(180*fRMUI_ARScale, 380*fRMUI_ARScale);
	UI::Begin("GameButtons", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
	if (UI::ButtonColored("Store", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		Audio::Play(sClick);
		iRMUI_CurrentPage = RM_PAGE_STORE;
	}
	if (UI::ButtonColored("Skills", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		//InitSkills();
		Audio::Play(sClick);
		iRMUI_CurrentPage = RM_PAGE_SKILLS;
	}		
	if (UI::ButtonColored("Stats", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		Audio::Play(sClick);
		iRMUI_CurrentPage = RM_PAGE_STATS;
	}		
	if (UI::ButtonColored("Exit", 0, 0, 0, vec2(170*fRMUI_ARScale,80*fRMUI_ARScale)) && iMapsLoading < 1)
	{
		Audio::Play(sClick);
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
				Event_UserLoadedGame();
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
	RMUI_RenderText("Smooch");

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
	UI::SetNextWindowPos(400*fRMUI_ARScale, 200*fRMUI_ARScale);
	UI::SetNextWindowSize(1000*fRMUI_ARScale, 900*fRMUI_ARScale);
	UI::Begin("StoreItems", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);		
	if (UI::ButtonColored("Reroll = $" + STORE_REROLL_PRICE, 0, 0, 0, vec2(400*fRMUI_ARScale,250*fRMUI_ARScale)) && rmgLoadedGame.iCash >= STORE_REROLL_PRICE)
	{
		Audio::Play(sReward);
		rmgLoadedGame.AddCash(-STORE_REROLL_PRICE);
		rmgLoadedGame.iRerolls++;
	}
	UI::SameLine();
	if (UI::ButtonColored("Skip = $" + STORE_SKIP_PRICE, 0, 0, 0, vec2(400*fRMUI_ARScale,250*fRMUI_ARScale))&& rmgLoadedGame.iCash >= STORE_SKIP_PRICE)
	{
		Audio::Play(sReward);
		rmgLoadedGame.AddCash(-STORE_SKIP_PRICE);		
		rmgLoadedGame.iSkips++;
	}		
	if (UI::ButtonColored("SkillPoint = $" + STORE_SKILLPOINT_PRICE, 0, 0, 0, vec2(500*fRMUI_ARScale,250*fRMUI_ARScale))&& rmgLoadedGame.iCash >= STORE_SKILLPOINT_PRICE)
	{
		Audio::Play(sReward);
		rmgLoadedGame.AddCash(-STORE_SKILLPOINT_PRICE);		
		rmgLoadedGame.iSkillpoints++;
	}		
	UI::SameLine();
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
	UI::SetNextWindowPos(0, Draw::GetHeight() - 100*fRMUI_ARScale);
	UI::SetNextWindowSize(160*fRMUI_ARScale, 100*fRMUI_ARScale);
	UI::Begin("StoreBackButton", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);		
	if (UI::ButtonColored("Back", 0, 0, 0, vec2(150*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		Audio::Play(sClick);
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
	RMUI_RenderText("Skills Upgraded: " + rmgLoadedGame.iStatsSkillsUpgraded);
	
	if(rmgLoadedGame.iGameMode == GAMEMODE_REGULAR)
	{
		RMUI_RenderText("Game Mode: Random TMX Maps");
	}
	else if(rmgLoadedGame.iGameMode == GAMEMODE_KACKY)
	{
		RMUI_RenderText("Game Mode: Random Kacky Maps");
	}
	else if(rmgLoadedGame.iGameMode == GAMEMODE_CAMPAIGN)
	{
		RMUI_RenderText("Game Mode: Random Nadeo Maps");
	}	
	else if(rmgLoadedGame.iGameMode == GAMEMODE_TOTD)
	{
		RMUI_RenderText("Game Mode: Random Track of the Day Maps");
	}
	else
	{
		RMUI_RenderText("Game Mode: Unspecified");
	}
	
	if(rmgLoadedGame.iDifficulty == 1)
	{
		RMUI_RenderText("Difficulty: Easy");
	}
	if(rmgLoadedGame.iDifficulty == 2)
	{
		RMUI_RenderText("Difficulty: Normal");
	}
	if(rmgLoadedGame.iDifficulty == 3)
	{
		RMUI_RenderText("Difficulty: Hard");
	}	

	if (RMUI_RenderButton("Back"))
	{
		iRMUI_CurrentPage = RM_PAGE_GAME;
	}		
}

void RMUI_RenderGamemodePage()
{
	RMUI_RenderText("GameMode:");

	if (RMUI_RenderButton("TMX"))
	{
		iRMUI_GameMode = GAMEMODE_REGULAR;
		iRMUI_CurrentPage = RM_PAGE_SETTINGS;
	}
	if (RMUI_RenderButton("Nadeo"))
	{
		iRMUI_GameMode = GAMEMODE_CAMPAIGN;
		iRMUI_CurrentPage = RM_PAGE_SETTINGS;
	}	
	if (RMUI_RenderButton("TOTD"))
	{
		iRMUI_GameMode = GAMEMODE_TOTD;
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

void RMUI_RenderSkillsPage() //ns
{
	for (int i = 1; i <= RM_SKILL_COUNT; i++)
	{
		if(i == RM_SKILL_FAVORITE_STYLE && rmgLoadedGame.iGameMode != GAMEMODE_REGULAR && rmgLoadedGame.iGameMode != GAMEMODE_TOTD)
		{
			continue;
		}
		
		UI::PushStyleColor(UI::Col::WindowBg, vec4(0.2, 0.2, 0.2, 0.2));
		UI::SetNextWindowPos(((i*300))*fRMUI_ARScale, 400*fRMUI_ARScale, UI::Cond::Always);
		UI::SetNextWindowSize(200*fRMUI_ARScale, 240*fRMUI_ARScale);
		UI::Begin("RMUI_Skill_" + i, UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);
		UI::PushStyleColor(UI::Col::Text, vec4(0.0, 0.9, 0.5, 1.0));
		UI::TextWrapped(GetSkillName(i));
		UI::PopStyleColor();
		UI::TextWrapped("Level: " + rmgLoadedGame.tSkills[i].iLevel + "/" + rmgLoadedGame.tSkills[i].iMaxLevel);
		if (rmgLoadedGame.tSkills[i].fPerLevelBonus > 0)
		{	
			UI::SameLine();
			UI::TextWrapped("Bonus: " + rmgLoadedGame.tSkills[i].fPerLevelBonus);
			UI::TextWrapped("Current Bonus: " + "+ x" + (rmgLoadedGame.tSkills[i].iLevel*rmgLoadedGame.tSkills[i].fPerLevelBonus));
		}
		UI::TextWrapped("Upgrade Cost: " + rmgLoadedGame.tSkills[i].iCost + " SkillPoint");

		if(ttSkills[i] !is null)
		{
			UI::Image(ttSkills[i], vec2(190, 85));
		}
		
		if(i == RM_SKILL_FAVORITE_STYLE)
		{
			if(!rmgLoadedGame.tSkills[i].bLearned)
			{
				if (UI::BeginCombo("Style", rmgLoadedGame.tSkills[i].sStyleName, UI::ComboFlags::None))
				{
					if (UI::Selectable("Tech", rmgLoadedGame.tSkills[i].sStyleName == "Tech", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Tech"; }
					if (UI::Selectable("FullSpeed", rmgLoadedGame.tSkills[i].sStyleName == "FullSpeed", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "FullSpeed"; }
					if (UI::Selectable("Dirt", rmgLoadedGame.tSkills[i].sStyleName == "Dirt", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Dirt"; }
					if (UI::Selectable("Ice", rmgLoadedGame.tSkills[i].sStyleName == "Ice", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Ice"; }
					if (UI::Selectable("Nascar", rmgLoadedGame.tSkills[i].sStyleName == "Nascar", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Nascar"; }
					if (rmgLoadedGame.iGameMode != GAMEMODE_TOTD && UI::Selectable("RPG", rmgLoadedGame.tSkills[i].sStyleName == "RPG", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "RPG"; }
					if (UI::Selectable("LOL", rmgLoadedGame.tSkills[i].sStyleName == "LOL", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "LOL"; }
					if (rmgLoadedGame.iGameMode != GAMEMODE_TOTD && UI::Selectable("Press Forward", rmgLoadedGame.tSkills[i].sStyleName == "Press Forward", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Press Forward"; }
					if (UI::Selectable("Grass", rmgLoadedGame.tSkills[i].sStyleName == "Grass", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Grass"; }
					if (UI::Selectable("Transitional", rmgLoadedGame.tSkills[i].sStyleName == "Transitional", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Transitional"; }
					if (UI::Selectable("Backwards", rmgLoadedGame.tSkills[i].sStyleName == "Backwards", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Backwards"; }
					if (UI::Selectable("Plastic", rmgLoadedGame.tSkills[i].sStyleName == "Plastic", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Plastic"; }
					if (UI::Selectable("Water", rmgLoadedGame.tSkills[i].sStyleName == "Water", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Water"; }
					if (UI::Selectable("Bobsleigh", rmgLoadedGame.tSkills[i].sStyleName == "Bobsleigh", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Bobsleigh"; }
					if (UI::Selectable("Sausage", rmgLoadedGame.tSkills[i].sStyleName == "Sausage", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Sausage"; }
					if (UI::Selectable("Scenery", rmgLoadedGame.tSkills[i].sStyleName == "Scenery", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Scenery"; }
					if (rmgLoadedGame.iGameMode != GAMEMODE_TOTD && UI::Selectable("Endurance", rmgLoadedGame.tSkills[i].sStyleName == "Endurance", UI::SelectableFlags::None)) { rmgLoadedGame.tSkills[i].sStyleName = "Endurance"; }
				
					UI::EndCombo();
				}
			}
			else
			{
				UI::TextWrapped("Style: " + rmgLoadedGame.tSkills[i].sStyleName);
			}
		}

		if (rmgLoadedGame.tSkills[i].iLevel < rmgLoadedGame.tSkills[i].iMaxLevel && UI::ButtonColored("Upgrade", 0.35, 0.7, 0.5) && rmgLoadedGame.iSkillpoints >= rmgLoadedGame.tSkills[i].iCost)
		{
			Audio::Play(sReward);
			rmgLoadedGame.iSkillpoints = rmgLoadedGame.iSkillpoints - rmgLoadedGame.tSkills[i].iCost;
			UpgradeSkill(i);
		}

		UI::End();
		UI::PopStyleColor();
	}

	UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, 0));
	UI::PushFont(fButton);
	UI::SetNextWindowPos(0, Draw::GetHeight() - 100*fRMUI_ARScale);
	UI::SetNextWindowSize(160*fRMUI_ARScale, 100*fRMUI_ARScale);
	UI::Begin("SkillsBackButton", UI::WindowFlags::NoTitleBar + UI::WindowFlags::NoResize + UI::WindowFlags::NoMove + UI::WindowFlags::NoSavedSettings);		
	if (UI::ButtonColored("Back", 0, 0, 0, vec2(150*fRMUI_ARScale,80*fRMUI_ARScale)))
	{
		Audio::Play(sClick);
		SG_Save(@rmgLoadedGame);
		iRMUI_CurrentPage = RM_PAGE_GAME;
	}	
	UI::End();
	UI::PopFont();
	UI::PopStyleColor();
}