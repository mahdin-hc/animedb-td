import "http"
import "strings"
import "json"
import "fs"
import "crypto"

var filename

fn fetch(mal_url) {
	id := strings.split(mal_url, "/")
	id = id[id.length-1]
	
	resp := http.get(format("https://api.jikan.moe/v4/anime/%s/characters", id))
	
	if resp {
		obj := json.decode(resp)
		if obj {
			if !fs.exists("cache/characters") {
				fs.mkdir_all("cache/characters")
			}
			fs.writefile(filename, resp)
			return obj
		}
	}
	
	return null
}

export fn(url) {
	filename = format("cache/characters/%s.json", crypto.md5(url))
	if fs.exists(filename) {
		ch := json.decode(fs.readfile(filename))
		if ch {
			return ch
		}
		return fetch(url)
	} 
	
	return fetch(url)
}