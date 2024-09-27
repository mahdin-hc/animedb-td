import "http"
import "bufio"
import "strings"
import "json"


for {
	print("Enter MyAnimeList UserName: ")
	input := strings.trim_space(bufio.readline())
	raw_data := http.get(format(`https://myanimelist.net/animelist/%s/load.json`, input))
	arr := json.decode(raw_data)
	
	for anime in arr {
		id := string(anime.anime_id) || ""
		title := anime.anime_title_eng || ""
		sysout id.iyellow, " ", title.iwhite, "\n"
		sysout "      Score: ", anime.score, ", AVG: ", anime.anime_score_val, "\n"
	}
}