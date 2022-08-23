module main

import term.ui as tui

struct Repl {
mut:
	tui           &tui.Context = unsafe { nil }
	mode          Mode
	focus         Focus
	fixed         bool
	should_redraw bool
	w             int
	h             int
	side_bar_pos  int
	prompt        &Prompt
	dataio        &DataIO
	databuff      &DataBuff
	filesio       &FilesIO
	msg           &Msg
}

fn (mut r Repl) next_focus() {
	r.focus = match r.focus {
		.prompt {
			Focus.result
		}
		.result {
			if r.tui.window_width > 109 { Focus.prog_list } else { Focus.prompt }
		}
		.prog_list {
			Focus.prompt
		}
	}
}

fn (mut r Repl) prev_focus() {
	r.focus = match r.focus {
		.prompt {
			if r.tui.window_width > 109 { Focus.prog_list } else { Focus.result }
		}
		.result {
			Focus.prompt
		}
		.prog_list {
			Focus.result
		}
	}
}

fn (mut r Repl) input_insert(s string) {
	mut d := r.dataio
	d.in_txt.insert(d.in_txt.len + d.in_offset, s.runes())
}

fn (mut r Repl) input_remove() {
	mut d := r.dataio
	if d.in_offset > 0 - d.in_txt.len {
		r.tui.draw_text(r.prompt.offset(), d.in_lineno, ' '.repeat(d.in_txt.len))
		d.in_txt.delete(d.in_txt.len + d.in_offset - 1)
	}
}

fn (mut r Repl) input_delete() {
	mut d := r.dataio
	if d.in_offset < 0 {
		r.tui.draw_text(r.prompt.offset(), d.in_lineno, ' '.repeat(d.in_txt.len))
		d.in_txt.delete(d.in_txt.len + d.in_offset)
		d.in_offset++
	}
}

fn (mut r Repl) cursor_backward(i int) {
	mut d := r.dataio
	if d.in_offset > 0 - d.in_txt.len {
		d.in_offset -= i
	}
}

fn (mut r Repl) cursor_forward(i int) {
	mut d := r.dataio
	if d.in_offset < 0 {
		d.in_offset += i
	}
}

fn (mut r Repl) set_cursor() {
	d := r.dataio
	r.tui.set_cursor_position(r.prompt.offset() + d.in_txt.len + d.in_offset, d.in_lineno)
}

fn (mut r Repl) check_w_h() {
	if r.w != r.tui.window_width || r.h != r.tui.window_height {
		r.w = r.tui.window_width
		r.h = r.tui.window_height
		if r.tui.window_width < 110 && r.focus == .prog_list {
			r.focus == .prompt
		}
		r.should_redraw = true // FIXME
	}
	r.draw_prog_list()
	r.draw_footer()
}

fn (mut r Repl) draw_prog_list() {
	if r.tui.window_width > 109 {
		r.tui.set_bg_color(custom_colors[.ui_bg_elem])
		r.side_bar_pos = r.tui.window_width - r.tui.window_width / 4 - 1
		r.tui.draw_line(r.side_bar_pos, 1, r.side_bar_pos, r.tui.window_height)
		r.tui.reset()
	}
}

fn (mut r Repl) draw_footer() {
	if r.tui.window_width > 99 && r.tui.window_height > 31 {
		r.tui.set_bg_color(custom_colors[.ui_bg_elem])
		r.tui.set_color(custom_colors[.ui_fg_text])
		y := r.tui.window_height
		mode := 'Mode: $r.mode'
		focus := 'Focus on: $r.focus'
		fixed := 'Fixed: $r.fixed'
		lineno := 'Line No. in: $r.dataio.in_lineno out: $r.dataio.out_lineno'
		status := '$mode | $focus | $fixed | $lineno'
		x := (r.tui.window_width - status.len) / 2
		r.tui.draw_line(1, y, r.tui.window_width, y)
		r.tui.draw_text(x, y, status)
		r.tui.reset()
	}
}

fn (mut r Repl) eval() {
	mut d := r.dataio
	// handle existing message before moving cursor
	r.tui.draw_text(1, r.dataio.in_lineno + 1, ' '.repeat(r.msg.content.len))
	in_txt := d.in_txt.string()
	if in_txt.starts_with(cpfix) {
		cmd := in_txt.trim(cpfix).trim_space()
		if cmd in functions {
			functions[cmd](mut r)
		} else {
			d.result = 'Unknown command ${colors[.msg_error](cmd)}'
		}
	} else {
		d.result = in_txt.trim_space()
	}
	r.set_in_out_lineno()
	r.tui.draw_text(r.prompt.offset(), d.in_lineno, ' '.repeat(d.in_txt.len))
	d.in_offset = 0
	d.in_txt.clear()
}

fn (mut r Repl) print() {
	if r.dataio.should_print {
		r.tui.draw_text(1, r.dataio.out_lineno, r.dataio.result)
	}
	r.dataio.should_print = true
}

fn (mut r Repl) set_in_out_lineno() {
	if r.fixed {
		r.dataio.in_lineno = 1
		r.dataio.out_lineno = 2
	} else {
		if r.dataio.should_print {
			in_lines_len := r.dataio.in_txt.filter(it == `\n`).len + 1
			out_lines_len := r.dataio.result.count('\n') + 1
			r.dataio.out_lineno = r.dataio.in_lineno + in_lines_len
			r.dataio.in_lineno = r.dataio.out_lineno + out_lines_len
		}
	}
}

// FIXME on Enter pressed
fn (mut r Repl) handle_message() {
	pos_x := if debug {
		r.dataio.in_lineno
	} else {
		r.dataio.in_lineno + 1
	}
	pos_y := if debug {
		r.side_bar_pos - 'redraw on frame $r.tui.frame_count'.len - 1
	} else {
		1
	}
	if r.msg.content != '' && r.tui.frame_count >= r.msg.msg_hide_tick {
		r.tui.draw_text(pos_y, pos_x, ' '.repeat(r.msg.content.len))
		r.msg.content = ''
	}
	if r.msg.content != '' {
		r.tui.draw_text(pos_y, pos_x, colors[r.msg.color](r.msg.content))
	}
}

fn (mut r Repl) show_msg(text string, color THC, time int) {
	frames := time * frame_rate
	r.msg.msg_hide_tick = if time > 0 { int(r.tui.frame_count) + frames } else { -1 }
	r.msg.content = text
	r.msg.color = color
}
