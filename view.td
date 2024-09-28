import "canvas"
import "image"
import "json"
import "os"
import "strings"
import "openlink"
import "characters"

var fontdata = embed("res/PlaywriteDEGrund-Regular.ttf")
var margin_x = 20
var margin_y = 20
var ratio = 0
var bounds = []

fn find_mal_link(arr) {
	for a in arr {
		if strings.contains(a, "myanimelist") {
			return a
		}
	}
	return arr[0]
}

fn view_anime(anime, img) {
	var b = img.bounds()
	w := 600
	h := 400
	iw := 0
	ih := 0
	text_i := 0
	text_gap := 0
	anime_link := find_mal_link(anime.sources)
	var ch = characters(anime_link)
	
	
	fn text(ctx, str, font_size, color) {
		str = strings.trim_space(str)
		text_gap += 18
		X := margin_x*2*ratio + iw
		Y := margin_y + text_gap
		ctx.hex(color)
		ctx.fontface(fontdata, font_size)
		l := ""
		line := ""
		arr := strings.split(str, " ")
		for _, word in arr {
			l += (word + " ")
			if (X + ctx.measure_text(l)[0]) > w {
				break
			}
			line = l
		}
		line = strings.trim_suffix(line, " ")
		if line != str {
			line += "..."
		}
		ctx.text(line, X, Y)
		WH := ctx.measure_text(line)
		bounds.push([X, Y-font_size, WH[0], font_size, "text-"+string(text_i)])
		text_i++
	}
	
	fn button(ctx, X, Y, str, size, id) {
		m := 10
		mh := m/2
		ctx.fontface(fontdata, size)
		kw := ctx.measure_text(str)
		ctx.hex("#3c8bfa")
		ctx.rect(X, Y, kw[0]+m, size+m)
		ctx.fill()
		ctx.hex("#fff")
		ctx.text(str, X+mh, Y+size+mh)
		bounds.push([X, Y, kw[0]+m, size+m, id])
	}
	
	fn draw(ctx) {
		bounds = []
		text_i = 0
		text_gap = 0
		ctx.hex(`#191a1c`)
		ctx.clear()
		
		ctx.push()
		ratio = (float(h)/b.size.height) * 0.9
		ih = float(b.size.height)*ratio
		iw = float(b.size.width)*ratio
		margin_y = ((h-ih)/2)*ratio
		ctx.scale(ratio, ratio)
		ctx.drawimage(img.encode("png"), margin_x, (h-ih)/2)
		ctx.pop()
		
		// ctx.hex("#0f0")
		// ctx.rect(margin_x, ((h-ih)/2)*ratio, 10, 10)
		// ctx.stroke()
		
		text(ctx, anime.title, 18, "#eee")
		text(ctx, format("%+v Episodes [%s] [%s]", anime.episodes, anime.status, anime.type), 10, "#ccc")
		text(ctx, format("%+v [%s]", anime.animeSeason.year, anime.animeSeason.season), 10, "#ccc")
		text_gap += 18
		text(ctx, format("Tags: %s", strings.join(anime.tags, ", ")), 13, "#3c8bfa")
		text_gap += 18
		button(ctx, margin_x*2*ratio + iw, margin_y + text_gap, "MyAnimeList", 12, "btn-mal")
		
		text_gap += 25
		if ch {
			for i, c in ch.data {
				if (h/2 - ih/2 + text_gap + 30) > ih+(h-ih)/2 {
					if i < ch.data.length - 1 {
						text(ctx, format("%d more...", len(ch.data)-i-1), 10, "#aaa")
					}
					break
				}
				text(ctx, c.character.name, 10, "#aaa")
			}
		}
		
	}
	
	if os.platform != "windows" {
		var ctx = canvas.new_context(w, h)
		draw(ctx)
		ctx.save_png("out.png")
		sysout "Preview has rendered to \"out.png\"\n".blue
		return
	}
	
	sysout "Opening preview window...\n".blue

	canvas.new_window(w, h, "AnimeDB", fn(window){
		ctx := window.new_context(w, h)
		draw(ctx)
		window.update(w, h)
		for {
			e := window.next_event()
			if e.type == "size" {
				w = e.width_px 
				h = e.height_px
				ctx = window.new_context(e.width_px, e.height_px)
				draw(ctx)
				window.update(w, h)
			}
			else if e.type == "lifecycle" && e.from == 3 && e.to == 0 {
				window.release()
				break
			}
			else if e.type == "mouse" && e.direction == 1 {
				for b_index, b in bounds {
					ax := b[0]
					ay := b[1]
					aw := b[2]
					ah := b[3]
					if ax < e.x && ay < e.y && ax + aw > e.x && ay + ah > e.y {
						// debug(b)
						if b[4] == "btn-mal" {
							openlink(anime_link)
						}
						// ctx.hex("#00ff0080")
						// ctx.rect(b[0], b[1], b[2], b[3])
						// ctx.fill()
						// window.update(w, h)
					}
				}
			}
		}
	})
}


args := os.args()

obj := json.decode(args[2])
img := image.load(args[3])

if !img {
	img = image.decode(embed("res/no_pic.png"))
}
// import("io").writefile("a.json", args[2])

view_anime(obj, img)