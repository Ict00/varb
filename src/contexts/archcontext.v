module contexts

import common
import term.ui as tui

pub struct ArchContext {
	common.Pagination
pub mut:
	search string
	packages []common.ArchPackage
	reached_end bool
	searching bool
	requesting_now bool

	packages_channel chan []common.ArchPackage
}

pub fn make_archctx() ArchContext {
	pkgs := common.fetch_from_arch("", common.fetch_amount, 1)

	return ArchContext{search: "", packages: pkgs, total_elements: fn (mut it common.App) int {
		return (it.ctx as ArchContext).packages.len
	}, page_size: fn (mut it common.App) int {
		return it.tui.window_height-1
	}}
}

pub fn update(mut ctx ArchContext, mut app common.App) {
	common.draw_wait(mut app)
	pkgs := common.fetch_from_arch(ctx.search, common.fetch_amount, 1)

	ctx.packages = pkgs
	ctx.page = 0
	ctx.cursor_index = 0

	if pkgs.len != common.fetch_amount {
		ctx.reached_end = true
	}
}

pub fn (mut ctx ArchContext) input(e &tui.Event, mut app common.App)! {
	if e.typ == .key_down {
		if ctx.searching {
			match e.code {
				.backspace {
					if ctx.search.len > 0 {
						ctx.search = ctx.search[..ctx.search.len-1]
					}
				}
				.enter {
					ctx.searching = false
					ctx.reached_end = false
					ctx.packages.clear()
					update(mut ctx, mut app)
				}
				else {
					ctx.search += e.utf8
				}
			}
		}
		else {
			match e.code {
				.w, .up {
					ctx.move_up(mut app)
				}
				.s, .down {
					ctx.move_down(mut app)
				}
				.d, .enter, .space {
					if ctx.packages.len == 0 {
						return
					}
					new_ctx := make_pkgctx(ctx.packages[ctx.cursor_index])
					app.ctx_stack.push(new_ctx)
					app.ctx = new_ctx
				}
				.f {
					ctx.searching = true
				}
				else {}
			}
		}
	}
}

pub fn fetch_more(mut ctx ArchContext, channel chan []common.ArchPackage) {
	res := common.fetch_from_arch(ctx.search, common.fetch_amount, (ctx.packages.len/common.fetch_amount)+1)

	channel <- res
}

pub fn (mut ctx ArchContext) frame(mut app common.App)! {
	app.tui.clear()

	app.tui.set_bg_color(tui.Color{52, 127, 247})
	app.tui.draw_line(0, 0, 5, 0)
	app.tui.draw_text(2, 0, "ARCH")
	app.tui.set_bg_color(tui.Color{18, 9, 71})
	app.tui.set_color(tui.Color{255,255,255})
	app.tui.draw_line(7, 0, app.tui.window_width, 0)
	if ctx.searching {
		app.tui.draw_text(7, 0, "> ${ctx.search}")
	}
	else {
		app.tui.draw_text(8, 0, " ${ctx.search}")
	}
	app.tui.reset()

	if ctx.packages.len == 0 {
		app.tui.draw_text(0, 2, "Nothing here. Try searching something else :D")

		app.tui.reset()
		app.tui.flush()
		return
	}

	mut b := 0
	page_size := ctx.page_size(mut app)

	for i in (ctx.page * page_size)..((ctx.page+1)*page_size) {
		if i >= ctx.packages.len {
			if !ctx.reached_end && !ctx.requesting_now{
				ctx.requesting_now = true
				spawn fetch_more(mut ctx, ctx.packages_channel)
			}
			if !ctx.reached_end {
				common.draw_wait(mut app)

				select {
					new_packages := <-ctx.packages_channel {
						if new_packages.len != common.fetch_amount {
							ctx.reached_end = true
						}
						ctx.requesting_now = false
						ctx.packages << new_packages
						break
					}
				}
			}

			break
		}

		pkg := ctx.packages[i]
		mut name := pkg.pkgname

		if name.len > 18 {
			name = name[..17]+".."
		}

		max_desc := app.tui.window_width-27

		mut desc := pkg.pkgdesc

		if desc.len >= max_desc {
			desc = desc[..max_desc-4]+".."
		}
		if ctx.cursor_index == i {
			app.tui.set_bg_color(tui.Color{42, 147, 245})
			app.tui.set_color(tui.Color{0,0,0})
		}
		app.tui.draw_line(0, b+2, app.tui.window_width-1, b+2)
		app.tui.draw_text(0, b+2, "${name}")
		app.tui.draw_text(21, b+2, "${desc}")

		app.tui.reset()
		b++
	}

	app.tui.flush()
	app.tui.reset()
}