module common

import strconv

pub struct Pagination {
pub mut:
	cursor_index int
	page int
	page_size fn (mut App) int @[required]
	total_elements fn (mut App) int @[required]
}

pub fn (mut ctx Pagination) move_up(mut app App) {
	if ctx.cursor_index > 0 {
		ctx.cursor_index -= 1
	}


	if ctx.cursor_index < ctx.page * ctx.page_size(mut app) {
		ctx.page -= 1
	}
}

pub fn (mut ctx Pagination) move_down(mut app App) {
	if ctx.cursor_index + 1 < ctx.total_elements(mut app) {
		ctx.cursor_index += 1
	}

	if ctx.cursor_index >= (ctx.page + 1) * ctx.page_size(mut app) {
		ctx.page += 1
	}
}

pub fn system(cmd string) int {
	c_cmd := cmd.str
	return unsafe { C.system(c_cmd) }
}

pub fn bytes_to_readable(bytes u64) string {
	mut result := "b"
	mut res_f64 := 0.0

	if bytes > 1024 {
		res_f64 = f64(bytes)/1024.0
		result = "Kb"
	}
	if res_f64 > 1024 {
		res_f64 = res_f64/1024.0
		result = "Mb"
	}
	if res_f64 > 1024 {
		res_f64 = res_f64/1024.0
		result = "Gb"
	}


	return strconv.f64_to_str_lnd1(res_f64, 2) + result
}