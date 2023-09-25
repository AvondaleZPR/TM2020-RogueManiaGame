const int RM_SKILL_EMPTY_TYPE				= 0;
const int RM_SKILL_MAP_REWARD_BONUS 		= 1;
const int RM_SKILL_CHEST_REWARD_BONUS 		= 2;
const int RM_SKILL_CASINO_BONUS 			= 3;
const int RM_SKILL_MAP_PREVIEW	 			= 4;
const int RM_SKILL_FAVORITE_STYLE 			= 5;

const int RM_SKILL_COUNT = 5;

class RM_Skill 
{
	int iSkillType = RM_SKILL_EMPTY_TYPE;
	bool bLearned = false;
	int iCost = 1;
	int iLevel = 0;
	int iMaxLevel = 0;
	float fPerLevelBonus = 0.0;
	string sStyleName = "Tech";
	
	RM_Skill(int iSkillType, int iMaxLevel, float fPerLevelBonus)
	{
		this.iSkillType = iSkillType;
		this.iCost = iCost;
		this.iMaxLevel = iMaxLevel;
		this.fPerLevelBonus = fPerLevelBonus;	
	}
	
	RM_Skill(const Json::Value &in json)
	{
		this.iSkillType = json["iSkillType"];
		this.bLearned = json["bLearned"];
		this.iCost = json["iCost"];
		this.iLevel = json["iLevel"];
		this.iMaxLevel = json["iMaxLevel"];
		this.fPerLevelBonus = json["fPerLevelBonus"];
		this.sStyleName = json["sStyleName"];
	}
	
	Json::Value ToJson()
	{
		Json::Value json = Json::Object();

		json["iSkillType"] = iSkillType;
		json["bLearned"] = bLearned;
		json["iCost"] = iCost;
		json["iLevel"] = iLevel;
		json["iMaxLevel"] = iMaxLevel;
		json["fPerLevelBonus"] = fPerLevelBonus;				
		json["sStyleName"] = sStyleName;
		
		return json;
	}
}

void InitSkills()
{
	if (rmgLoadedGame.tSkills.Length == 0)
	{
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_EMPTY_TYPE, 0, 0));
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_MAP_REWARD_BONUS, 5, 0.5));
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_CHEST_REWARD_BONUS, 5, 1.0));
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_CASINO_BONUS, 3, 0.0));
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_MAP_PREVIEW, 1, 0.0));
		rmgLoadedGame.tSkills.InsertLast(RM_Skill(RM_SKILL_FAVORITE_STYLE, 1, 0.0));
		
		rmgLoadedGame.tSkills[RM_SKILL_FAVORITE_STYLE].iCost = 5;
	}
}

void UpgradeSkill(int iSkillType)
{
	rmgLoadedGame.tSkills[iSkillType].bLearned = true;
	rmgLoadedGame.tSkills[iSkillType].iLevel++;
	
	rmgLoadedGame.iStatsSkillsUpgraded++;
}

int GetSkillBonus(int iValue, int iSkillType)
{
	if (rmgLoadedGame.tSkills[iSkillType].bLearned)
	{
		if(iSkillType == RM_SKILL_CASINO_BONUS)
		{
			iValue += (10*rmgLoadedGame.tSkills[iSkillType].iLevel);
		}
		else
		{
			iValue += iValue*(rmgLoadedGame.tSkills[iSkillType].fPerLevelBonus * rmgLoadedGame.tSkills[iSkillType].iLevel);
		}
	}
	
	return iValue;
}

string GetSkillName(int iSkillType)
{
	if (iSkillType == RM_SKILL_MAP_REWARD_BONUS)
	{
		return "Map Claim Reward Multiplier";
	}
	else if(iSkillType == RM_SKILL_CHEST_REWARD_BONUS)
	{
		return "Chest Reward Multiplier";
	}
	else if(iSkillType == RM_SKILL_CASINO_BONUS)
	{
		return "Casino Luck Boost";
	}	
	else if(iSkillType == RM_SKILL_MAP_PREVIEW)
	{
		return "See Through Fog Chance";
	}
	else if(iSkillType == RM_SKILL_FAVORITE_STYLE)
	{
		return "Increased Chance for Style";
	}

	return "Unnamed Skill";
}