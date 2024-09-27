import "bufio"
import "os"
import "strings"
import "fs"
import "json"
import "http"
import "crypto"

var raw_data = embed("db.json")
sysout "Loading Anime Database...\n".yellow
var obj = json.decode(raw_data)
sysout "Anime Database has loaded! ".blue, string(obj.data.length).iblue, " animes total!\n".blue

XX := "%." + string(obj.data.length).length + "x "

fn name_query(a, b) {
	a = strings.to_upper(a)
	b = strings.to_upper(b)
	var out = ""
	aa := strings.split(a, b)
	for i, s in aa {
		out += s.iwhite
		if i < aa.length - 1 {
			out += b.on_green
		}
	}
	return out
}

fn parse_arg(str){
	ret := []
	arr := strings.split(str, " ")
	for a in arr {
		a = strings.trim_space(a)
		if a != "" {
			ret.push(a)
		}
	}
	return ret
}

fn search_anime(input) {
	arr := []
	for index, anime in obj.data {
		if strings.contains(strings.to_lower(anime.title), strings.to_lower(input)) {
			arr.push(index)
		}
	}
	limit := 20
	sysout "\nTotal search result: ", arr.length, "\n"
	for i := 0; i < (arr.length >= limit ? limit : arr.length); i++ {
		index := arr[i]
		sysout format(XX, index).igreen, name_query(obj.data[index].title, input), "\n"
	}
	if arr.length > limit {
		sysout string(arr.length - limit).iyellow, " more anime found!\n".yellow
	}
}

fn view_anime(id) {
	w := 600
	h := 400
	
	k := strings.parse_int(id, 16, 0)
	if is_error(k) {
		return
	}
	anime := obj.data[k]
	
	if anime == null {
		sysout "Undefined Anime ID!\n".ired
		return
	}
	
	if !fs.exists("temp") {
		fs.mkdir("temp")
	}
	
	imgname := format("temp/%s.png", crypto.md5(anime.picture))
	
	if !fs.exists(imgname) {
		img := http.get(anime.picture)
		fs.writefile(imgname, img)
	}
	
	cmd := os.exec("tender.exe", "view.td", json.encode(anime), imgname)
	// cmd.stdout(os.stdout)
	cmd.start()
}

fn print_help() {
	println()
	println("Commands: ")
	sysout "search <name>    ->    To search anime\n"
	sysout "view             ->    To view anime details in GUI\n"
	sysout "help             ->    To print help\n"
	sysout "exit             ->    To exit\n"
	println()	
}

sysout "Welcome to AnimeDB!\n".red
sysout "Last Updated, ".red, obj.lastUpdate.ired, "\n"
print_help()

for {
	print("$ ")
	var input = strings.trim_space(bufio.readline())
	args := parse_arg(input)
	if args.length > 0 {
		cmd := args[0]
		if cmd == "search" {
			search_anime(strings.join(splice(args, 1), " "))
		} 
		else if cmd == "view" {
			view_anime(args[1])
		}
		else if cmd == "help" {
			print_help()
		}
		else if cmd == "exit" {
			os.exit(0)
		}
		else {
			sysout format("Invalid command, \"%s\"!\n", cmd).red
		}
	}
}