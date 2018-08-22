# StoreDeathsound
Death sounds for Zephyrus Store


add this to your `.\addons\sourcemod\translations\store.phrases.txt`
```
	"death_sound"
	{
		"en" "Death sound"
	}
```

add something like this to your `.\addons\sourcemod\configs\store\items.txt`
```
	"Death sounds"
	{
		"Tribute"
		{
			"path" "hg/cannon.mp3"
			"origin" "1"  // 1 - global (map)/ 2 - local (player)/ 3 - player voice
			"volume" "1.0"
			"price" "100"
			"block" "1"   // 1 - block orignal death voice
			"type" "death_sound"
		}
		"I'm dying!"
		{
			"path" "player/dying.mp3"
			"origin" "2"  // 1 - global / 2 - local / 3 - player voice
			"volume" "0.5"
			"price" "100"
			"block" "0"   // 1 - block orignal death voice
			"type" "death_sound"
		}
		"Argh"
		{
			"path" "player/argh.mp3"
			"origin" "2"  // 1 - global / 2 - local / 3 - player voice
			"volume" "1.0"
			"price" "100"
			"block" "1"   // 1 - block orignal death voice
			"type" "death_sound"
		}
	}
```
no need for manual adding to downloader/precacher plugins

no sounds included.
