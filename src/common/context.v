module common

import term.ui as tui

pub interface CContext {
mut:
	input(e &tui.Event, mut app App)!
	frame(mut app App)!
}