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
