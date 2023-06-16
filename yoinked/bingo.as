//yoinked from trackmania bingo https://github.com/Geekid812/TrackmaniaBingo/tree/main

bool bMapLoading = false;

void LoadMap(int TmxID) {
	bMapLoading = true;
	startnew(LoadMapCoroutine, CoroutineData(TmxID));
}

class CoroutineData {
	int Id;

	CoroutineData(int id) { this.Id = id; }
}

// This code is mostly taken from Greep's RMC
void LoadMapCoroutine(ref@ Data) {
	int TmxID = cast<CoroutineData>(Data).Id;
	auto App = cast<CTrackMania>(GetApp());
	bool MenuDisplayed = App.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed;
	if (MenuDisplayed) {
		// Close the in-game menu via ::Quit to avoid TM hanging / crashing. Also takes us back to the main menu.
		App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
	} else {
		// Go to main menu and wait until map loading is ready
		App.BackToMainMenu();
	}

	// Wait for the active module to be the main menu, and be ready. If getting back to the main menu fails, this will block until the user quits the map.
	while (App.Switcher.ModuleStack.Length == 0 || cast<CTrackManiaMenus>(App.Switcher.ModuleStack[0]) is null) {
		yield();
	}
	while (!App.ManiaTitleControlScriptAPI.IsReady) {
		yield();
	}

	App.ManiaTitleControlScriptAPI.PlayMap("https://trackmania.exchange/maps/download/" + TmxID, "", "");
	
	while (GetCurrentMap() is null)
	{
		yield();
	}
	bMapLoading = false;
}

void ExitToMainMenuPls()
{
	auto App = cast<CTrackMania>(GetApp());
	bool MenuDisplayed = App.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed;
	if (MenuDisplayed) {
		// Close the in-game menu via ::Quit to avoid TM hanging / crashing. Also takes us back to the main menu.
		App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
	} else {
		// Go to main menu and wait until map loading is ready
		App.BackToMainMenu();
	}

	// Wait for the active module to be the main menu, and be ready. If getting back to the main menu fails, this will block until the user quits the map.
	while (App.Switcher.ModuleStack.Length == 0 || cast<CTrackManiaMenus>(App.Switcher.ModuleStack[0]) is null) {
		yield();
	}
	while (!App.ManiaTitleControlScriptAPI.IsReady) {
		yield();
	}
}

CGameCtnChallenge@ GetCurrentMap() {
	auto App = cast<CTrackMania>(GetApp());
	return App.RootMap;
}

// Once again, this is mostly from RMC
// Only returns a defined value during the finish sequence of a run
RunResult GetRunResult() {
	// This is GetCurrentMap(), but because App is used in the function,
	// we redefine it here
	auto App = cast<CTrackMania>(GetApp());
	auto Map = App.RootMap;

	auto Playground = cast<CGamePlayground>(App.CurrentPlayground);
	if (Map is null || Playground is null) return RunResult();

	int AuthorTime = Map.TMObjective_AuthorTime;
	int GoldTime = Map.TMObjective_GoldTime;
	int SilverTime = Map.TMObjective_SilverTime;
	int BronzeTime = Map.TMObjective_BronzeTime;
	int Time = -1;

	auto PlaygroundScript = cast<CSmArenaRulesMode>(App.PlaygroundScript);
	if (PlaygroundScript is null || Playground.GameTerminals.Length == 0) return RunResult();

	CSmPlayer@ Player = cast<CSmPlayer>(Playground.GameTerminals[0].ControlledPlayer);
	if (Playground.GameTerminals[0].UISequence_Current != SGamePlaygroundUIConfig::EUISequence::Finish || Player is null) return RunResult();

	CSmScriptPlayer@ PlayerScriptAPI = cast<CSmScriptPlayer>(Player.ScriptAPI);
	auto Ghost = PlaygroundScript.Ghost_RetrieveFromPlayer(PlayerScriptAPI);
	if (Ghost is null) return RunResult();

	if (Ghost.Result.Time > 0 && Ghost.Result.Time < 4294967295) Time = Ghost.Result.Time;
	PlaygroundScript.DataFileMgr.Ghost_Release(Ghost.Id);

	if (Time != -1) {
		return RunResult(Time, CalculateMedal(Time, AuthorTime, GoldTime, SilverTime, BronzeTime));
	}
	return RunResult();
}

class RunResult {
    int Time = -1;
    Medal Medal = Medal::None;

    RunResult() { }
    RunResult(int time, Medal medal) {
        this.Time = time;
        this.Medal = medal;
    }

    string Display() {
        return symbolOf(this.Medal) + "\\$z " + Time::Format(this.Time);
    }

    string DisplayTime() {
        return Time::Format(this.Time);
    }
}

namespace Medals {
	const string None = "\\$444" + Icons::Circle;
	const string Bronze = "\\$964" + Icons::Circle; 
	const string Silver = "\\$899" + Icons::Circle; 
	const string Gold = "\\$db4" + Icons::Circle;
	const string Author = "\\$071" + Icons::Circle;
}

enum Medal {
    Author = 0,
    Gold = 1,
    Silver = 2,
    Bronze = 3,
    None = 4
}

string stringof(Medal medal) {
    if (medal == Medal::Author) return "Author";
    if (medal == Medal::Gold) return "Gold";
    if (medal == Medal::Silver) return "Silver";
    if (medal == Medal::Bronze) return "Bronze";
    return "None";
}

string symbolOf(Medal medal) {
    if (medal == Medal::Author) return Medals::Author;
    if (medal == Medal::Gold) return Medals::Gold;
    if (medal == Medal::Silver) return Medals::Silver;
    if (medal == Medal::Bronze) return Medals::Bronze;
    return Medals::None;
}

int objectiveOf(Medal medal, CGameCtnChallenge@ map) {
    if (medal == Medal::Author) return map.TMObjective_AuthorTime;
    if (medal == Medal::Gold) return map.TMObjective_GoldTime;
    if (medal == Medal::Silver) return map.TMObjective_SilverTime;
    if (medal == Medal::Bronze) return map.TMObjective_BronzeTime;
    return -1;
}

Medal CalculateMedal(int time, int author, int gold, int silver, int bronze) {
		Medal medal = Medal::None;
		if (time <= bronze) medal = Medal::Bronze;
		if (time <= silver) medal = Medal::Silver;
		if (time <= gold) medal = Medal::Gold;
		if (time <= author) medal = Medal::Author;
		return medal;
}

int GetMedalTime(CGameCtnChallenge@ map, Medal medal) {
	if (medal == Medal::Author) return map.TMObjective_AuthorTime;
	if (medal == Medal::Gold) return map.TMObjective_GoldTime;
	if (medal == Medal::Silver) return map.TMObjective_SilverTime;
	if (medal == Medal::Bronze) return map.TMObjective_BronzeTime;
	return -1;
}