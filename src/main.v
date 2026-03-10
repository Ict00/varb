module main

import term.ui as tui
import common
import contexts


fn input(e &tui.Event, x voidptr) {
	mut app := unsafe { &common.App(x) }

	if e.typ == .key_down {
		match e.code {
			.escape {
				exit(0)
			}
			else {}
		}
	}

	app.ctx.input(e, mut app) or { }
}

fn frame(x voidptr) {
	mut app := unsafe { &common.App(x) }
	app.ctx.frame(mut app) or { }
}

fn main() {
	mut app := &common.App{ctx: contexts.make_archctx()}
	app.ctx_stack.push(app.ctx)

	app.tui = tui.init(
		user_data:   app
		event_fn:    input
		frame_fn:    frame
		hide_cursor: true
	)
	app.tui.run()!
}