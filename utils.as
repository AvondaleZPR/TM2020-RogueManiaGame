class CachedImage
{
    string m_url;
    UI::Texture@ m_texture;

    void DownloadFromURLAsync()
    {
        auto req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Get;
        req.Url = m_url;
        req.Start();
        while (!req.Finished()) {
            yield();
        }
        @m_texture = UI::LoadTexture(req.Buffer());
        if (m_texture.GetSize().x == 0) {
            @m_texture = null;
			//error("couldnt load image");
        }
    }
}

namespace Images
{
    dictionary g_cachedImages;

    CachedImage@ FindExisting(const string &in url)
    {
        CachedImage@ ret = null;
        g_cachedImages.Get(url, @ret);
        return ret;
    }

    CachedImage@ CachedFromURL(const string &in url)
    {
        // Return existing image if it already exists
        auto existing = FindExisting(url);
        if (existing !is null) {
            return existing;
        }

        // Create a new cached image object and remember it for future reference
        auto ret = CachedImage();
        ret.m_url = url;
        g_cachedImages.Set(url, @ret);

        // Begin downloading
        startnew(CoroutineFunc(ret.DownloadFromURLAsync));
        return ret;
    }
}

string FormatTimer(int time) {
	int hundreths = time % 1000 / 10;
	time /= 1000;
	int hours = time / 60 / 60;
	int minutes = (time / 60) % 60;
	int seconds = time % 60;

	string result = "";

	if (hours > 0) {
		result += Text::Format("%02d", hours) + ":";
	}
	if (minutes > 0 || (hours > 0 && minutes < 10)) {
		result += Text::Format("%02d", minutes) + ":";
	}
	result += Text::Format("%02d", seconds) + "." + Text::Format("%02d", hundreths);

	return result;
}

MapTag@ RandomMapTag()
{
	return @m_mapTags[Math::Rand(0, m_mapTags.Length-1)];
}

MapTag@ FindMapTagByName(const string &in sName)
{
	for(int i = 0; i < m_mapTags.Length; i++)
	{
		if (m_mapTags[i].Name == sName)
		{
			return m_mapTags[i];
		}		
	}
	
	return MapTag();
}

float GetARScale(float fW, float fH, float fM = 0.5)
{
	return Math::Pow(fW/1920, 1.0 - fM) * Math::Pow(fH/1080, fM);
}

class Date
{
    int year;
    int month;
    int day;

    Date(const int &in _year, const int &in _month, const int &in _day) {
        year = _year;
        month = _month;
        day = _day;
    }

    bool isBefore(const Date@ &in date) {
        return year < date.year || (year == date.year && (month < date.month || (month == date.month && day <= date.day)));
    }

    bool isAfter(const Date@ &in date) {
        return !isBefore(date);
    }
}

string PlayerRankFromScore(int64 iScore)
{
    if (iScore < 1000)
    {
        return "Noob I";
    }
    if (iScore < 3000)
    {
        return "Noob II";
    }
    if (iScore < 5000)
    {
        return "Noob III";
    }
    if (iScore < 7000)
    {
        return "Noob IV";
    }
    if (iScore < 9000)
    {
        return "Noob V";
    }

    else if (iScore < 10000)
    {
        return "Beginner I";
    }
    else if (iScore < 18000)
    {
        return "Beginner II";
    }
    else if (iScore < 26000)
    {
        return "Beginner III";
    }
    else if (iScore < 34000)
    {
        return "Beginner IV";
    }
    else if (iScore < 42000)
    {
        return "Beginner V";
    }    

    else if (iScore < 50000)
    {
        return "Upcoming I";
    }   
    else if (iScore < 59000)
    {
        return "Upcoming II";
    }   
    else if (iScore < 68000)
    {
        return "Upcoming III";
    }   
    else if (iScore < 77000)
    {
        return "Upcoming IV";
    }   
    else if (iScore < 86000)
    {
        return "Upcoming V";
    }   

    else if (iScore < 100000)
    {
        return "Driver I";
    }        
    else if (iScore < 200000)
    {
        return "Driver II";
    }        
    else if (iScore < 300000)
    {
        return "Driver III";
    }        
    else if (iScore < 400000)
    {
        return "Driver IV";
    }        
    else if (iScore < 450000)
    {
        return "Driver V";
    }        

    else if (iScore < 500000)
    {
        return "Driving Enthusiast I";
    }     
    else if (iScore < 600000)
    {
        return "Driving Enthusiast II";
    }  
    else if (iScore < 700000)
    {
        return "Driving Enthusiast III";
    }  
    else if (iScore < 800000)
    {
        return "Driving Enthusiast IV";
    }  
    else if (iScore < 900000)
    {
        return "Driving Enthusiast V";
    }            

    else if (iScore < 1000000)
    {
        return "Racing Enthusiast I";
    }    
    else if (iScore < 1200000)
    {
        return "Racing Enthusiast II";
    }   
    else if (iScore < 1400000)
    {
        return "Racing Enthusiast III";
    }   
    else if (iScore < 1600000)
    {
        return "Racing Enthusiast IV";
    }   
    else if (iScore < 1800000)
    {
        return "Racing Enthusiast V";
    }        

    else if (iScore < 2000000)
    {
        return "Racer I";
    }    
    else if (iScore < 2200000)
    {
        return "Racer II";
    }   
    else if (iScore < 2400000)
    {
        return "Racer III";
    }   
    else if (iScore < 2600000)
    {
        return "Racer IV";
    }   
    else if (iScore < 2800000)
    {
        return "Racer V";
    }        
  
    else if (iScore < 3000000)
    {
        return "Competitive Racer I";
    }    
    else if (iScore < 3200000)
    {
        return "Competitive Racer II";
    }   
    else if (iScore < 3400000)
    {
        return "Competitive Racer III";
    }   
    else if (iScore < 3600000)
    {
        return "Competitive Racer IV";
    }   
    else if (iScore < 3800000)
    {
        return "Competitive Racer V";
    }          

    else if (iScore < 3000000)
    {
        return "Professional Racer I";
    }    
    else if (iScore < 3200000)
    {
        return "Professional Racer II";
    }   
    else if (iScore < 3400000)
    {
        return "Professional Racer III";
    }   
    else if (iScore < 3600000)
    {
        return "Professional Racer IV";
    }   
    else if (iScore < 3800000)
    {
        return "Professional Racer V";
    }  

    else if (iScore < 4000000)
    {
        return "Master I";
    }    
    else if (iScore < 5000000)
    {
        return "Master II";
    }   
    else if (iScore < 6000000)
    {
        return "Master III";
    }   
    else if (iScore < 7000000)
    {
        return "Master IV";
    }   
    else if (iScore < 8000000)
    {
        return "Master V";
    }  
     else if (iScore < 9000000)
    {
        return "Master X";
    }    

    else if (iScore < 10000000)
    {
        return "Champion I";
    }    
    else if (iScore < 20000000)
    {
        return "Champion II";
    }   
    else if (iScore < 30000000)
    {
        return "Champion III";
    }   
    else if (iScore < 40000000)
    {
        return "Champion IV";
    }   
    else if (iScore < 50000000)
    {
        return "Champion V";
    }  
    else if (iScore < 60000000)
    {
        return "Champion X";
    }    
    else if (iScore < 70000000)
    {
        return "Champion XX";
    }    
    else if (iScore < 80000000)
    {
        return "Champion XXX";
    }    
    else if (iScore < 100000000)
    {
        return "Legend";
    }    
    else
    {
        return "King of TrackMania";
    }
}
