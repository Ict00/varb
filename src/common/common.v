module common
import term.ui as tui
import datatypes

pub const fetch_amount = 80

pub struct App {
pub mut:
	tui &tui.Context = unsafe { nil }
	ctx CContext
	ctx_stack datatypes.Stack[CContext]
}

pub fn draw_wait(mut app App) {
	x := (app.tui.window_width/2)-3
	y := (app.tui.window_height/2)+2

	app.tui.set_bg_color(tui.Color{89, 89, 89})
	app.tui.draw_rect(x, y, x+6, y-2)
	app.tui.set_bg_color(tui.Color{255,255,255})
	app.tui.draw_point(x+1, y-1)
	app.tui.draw_point(x+3, y-1)
	app.tui.draw_point(x+5, y-1)
	app.tui.reset_bg_color()
	app.tui.flush()
}

