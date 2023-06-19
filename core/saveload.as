array<string> tLoadedSaveGames;
array<string> tLoadedSaveGamesPaths;
int iXddKey = 10;

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

void SG_Save(RM_Game@ rmgGame, bool bBackUp = false)
{
	if(iMapsLoading > 0) {return;}

	string sJson = Json::Write(rmgGame.ToJson());
	string sFileName = rmgGame.sName + ".ROGUEMANIA";
	if (bBackUp) {sFileName += "_BACKUP";}
	
	IO::File fFile(IO::FromStorageFolder(sFileName));
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
		if(i % 2 == 0)
		{
			sNewString[i] = sNewString[i] + iKey;
		}
		else
		{
			sNewString[i] = sNewString[i] - iKey;
		}
	}
	
	return sNewString;
}

string SG_DecryptXDD(const string &in sString, int iKey)
{
	string sNewString = sString;

	for(int i = 0; i < sString.Length-1; i++)
	{
		if(i % 2 == 0)
		{
			sNewString[i] = sNewString[i] - iKey;
		}
		else
		{
			sNewString[i] = sNewString[i] + iKey;
		}
	}
	
	return sNewString;
}