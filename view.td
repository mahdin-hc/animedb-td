import "canvas"
import "image"
import "json"
import "os"
import "strings"

fn view_anime(anime, img) {
	w := 600
	h := 400
	
	debug(anime)

	fn draw(ctx) {
		ctx.hex(`#121212`)
		ctx.clear()
		
		ctx.push()
		iw := img.bounds().size.width
		ih := img.bounds().size.height
		ctx.drawimage(img.encode("png"), 20, h/2-ih/2)
		ctx.pop()
		
		ctx.hex("#ddd")
		ctx.load_fontface("PlaywriteDEGrund-Regular.ttf", 18)
		ctx.text(anime.title, 20+iw+20, h/2-ih/2+18)
		ctx.hex("#aaa")
		ctx.load_fontface("PlaywriteDEGrund-Regular.ttf", 11.2)
		ctx.text(format("%+v Episodes [%s]", anime.episodes, anime.status), 20+iw+20, h/2-ih/2+18*2)
		ctx.text(format("%+v [%s]", anime.animeSeason.year, anime.animeSeason.season), 20+iw+20, h/2-ih/2+18*3)
		// ctx.text(strings.join(anime.synonyms, " "), 20+iw+20, h/2-ih/2+18*5)
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
		}
	})
}


args := os.args()

obj := json.decode(args[2])
img := image.load(args[3])

// import("io").writefile("a.json", args[2])

view_anime(obj, img)