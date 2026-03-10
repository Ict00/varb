module contexts

import common
import term.ui as tui

pub struct PkgContext {
	pub mut:
	package common.ArchPackage
	inputs bool
	passwd string
}

pub fn make_pkgctx(pkg common.ArchPackage) PkgContext {
	return PkgContext{package: pkg}
}

pub fn (mut ctx PkgContext) input(e &tui.Event, mut app common.App)! {
	if e.typ == .key_down {
		if ctx.inputs {
			match e.code {
				.backspace {
					if ctx.passwd.len == 0 {
						return
					}
					ctx.passwd = ctx.passwd[..ctx.passwd.len-1]
				}
				.enter {
					ctx.package.install(ctx.passwd)
					ctx.inputs = false
					ctx.passwd = ""
				}
				else {
					ctx.passwd += e.utf8
				}
			}
			return
		}

		match e.code {
			.d, .enter, .space {
				app.tui.clear()
				app.tui.set_cursor_position(0, 0)
				app.tui.draw_text(0, 0, "PASSWD > ")
				app.tui.flush()
				ctx.inputs = true
			}
			.a, .q {
				app.ctx_stack.pop() or {}
				app.ctx = app.ctx_stack.peek()!
			}
			else { }
		}
	}
}

pub fn (mut ctx PkgContext) frame(mut app common.App)! {
	if ctx.inputs {
		return
	}

	app.tui.clear()

	app.tui.set_bg_color(tui.Color{52, 127, 247})
	app.tui.draw_line(0, 0, app.tui.window_width-1, 0)
	app.tui.draw_text(0, 0, "${ctx.package.pkgname} ${ctx.package.pkgver} ${ctx.package.repo} ${ctx.package.arch}")
	app.tui.draw_text(2, 0, "")
	app.tui.reset_bg_color()

	app.tui.draw_text(0, 3, ctx.package.pkgdesc)
	app.tui.draw_text(0, 4, "Maintainers  : ${ctx.package.maintainers.join(" ")}")
	app.tui.draw_text(0, 5, "Licenses     : ${ctx.package.licenses.join(" ")}")
	app.tui.draw_text(0, 6, "Compressed   : ${common.bytes_to_readable(ctx.package.compressed_size)}")
	app.tui.draw_text(0, 7, "Installed    : ${common.bytes_to_readable(ctx.package.installed_size)}")

	if ctx.package.dependencies.len > 0 {
		app.tui.draw_text(0, 9, "Dependencies : ${ctx.package.dependencies.join(" ")}")
	}

	app.tui.reset()
	app.tui.flush()
}