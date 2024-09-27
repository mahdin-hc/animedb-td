import "canvas"
import "image"
import "json"
import "os"
import "strings"
import "openlink"

var margin = 20
var bounds = []

fn view_anime(anime, img) {
	w := 600
	h := 400
	iw := img.bounds().size.width
	ih := img.bounds().size.height
	text_i := 0
	text_gap := 0
	
	fn text(ctx, str, font_size, color) {
		str = strings.trim_space(str)
		text_gap += 18
		X := margin*2 + iw
		Y := h/2 - ih/2 + text_gap
		ctx.hex(color)
		ctx.load_fontface("res/PlaywriteDEGrund-Regular.ttf", font_size)
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
		ctx.load_fontface("res/PlaywriteDEGrund-Regular.ttf", size)
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
		ctx.hex(`#eee`)
		ctx.clear()
		
		ctx.push()
		ctx.drawimage(img.encode("png"), margin, h/2-ih/2)
		ctx.pop()
		
		text(ctx, anime.title, 18, "#000")
		text(ctx, format("%+v Episodes [%s] [%s]", anime.episodes, anime.status, anime.type), 12, "#000")
		text(ctx, format("%+v [%s]", anime.animeSeason.year, anime.animeSeason.season), 12, "#000")
		text_gap += 18
		text(ctx, format("Tags: %s", strings.join(anime.tags, ", ")), 13, "#3c8bfa")
		text_gap += 18
		button(ctx, margin*2 + iw, h/2 - ih/2 + text_gap, "Open Browser", 12, "btn-mal")
	}

	canvas.new_window(600, 400, "AnimeDB", fn(window){
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
							openlink(anime.sources[0])
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
	img = image.load("res/no_pic.png")
}
// import("io").writefile("a.json", args[2])

view_anime(obj, img)