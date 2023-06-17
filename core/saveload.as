array<string> tLoadedSaveGames;
array<string> tLoadedSaveGamesPaths;
int iXddKey = 69;

void SG_LoadSaveGames()
{
	if (IO::FolderExists(IO::FromStorageFolder("")))
	{
		tLoadedSaveGamesPaths = IO::IndexFolder(IO::FromStorageFolder(""), true);
		tLoadedSaveGames = tLoadedSaveGamesPaths;
		for(int i = 0; i < tLoadedSaveGamesPaths.Length; i++)
		{
			string[]@ split = tLoadedSaveGamesPaths[i].Split("/");
			tLoadedSaveGames[i] = split[split.Length-1].Split(".")[0];
		}
	}
}

void SG_Save(RM_Game@ rmgGame)
{
	if(iMapsLoading > 0) {return;}

	string sJson = Json::Write(rmgGame.ToJson());
	IO::File fFile(IO::FromStorageFolder(rmgGame.sName + ".ROGUEMANIA"));
	fFile.Open(IO::FileMode::Write);
	fFile.WriteLine(SG_EncryptXDD(tostring(sJson), iXddKey));
	fFile.Close();
}

void SG_Load(const string &in sPath)
{
	IO::File fFile(sPath);
	fFile.Open(IO::FileMode::Read);
	@rmgLoadedGame = RM_Game(Json::Parse(SG_DecryptXDD(fFile.ReadToEnd(), iXddKey)));
	fFile.Close();
}

string SG_EncryptXDD(const string &in sString, int iKey)
{
	string sNewString = sString;

	for(int i = 0; i < sString.Length; i++)
	{
		sNewString[i] = sNewString[i] + iKey;
	}
	
	return sNewString;
}

string SG_DecryptXDD(const string &in sString, int iKey)
{
	string sNewString = sString;

	for(int i = 0; i < sString.Length-1; i++)
	{
		sNewString[i] = sNewString[i] - iKey;
	}
	
	return sNewString;
}