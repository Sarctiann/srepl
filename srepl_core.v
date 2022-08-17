module main

import term.ui as tui

struct Repl {
mut:
	tui           &tui.Context = unsafe { 0 }
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
	r.dataio.in_txt.insert(r.dataio.index, s.runes())
	r.dataio.index++
}

fn (mut r Repl) input_remove() {
	if r.dataio.index > 0 {
		r.dataio.index--
		r.dataio.in_txt.delete(r.dataio.index)
		r.should_redraw = true
	}
}

fn (mut r Repl) input_delete() {
	if r.dataio.index < r.dataio.in_txt.len {
		r.dataio.in_txt.delete(r.dataio.index)
		r.should_redraw = true
	}
}

fn (mut r Repl) cursor_backward(i int) {
	if r.dataio.index > 0 {
		r.dataio.index -= i
	}
}

fn (mut r Repl) cursor_forward(i int) {
	if r.dataio.index < r.dataio.in_txt.len {
		r.dataio.index += i
	}
}

fn (mut r Repl) set_cursor() {
	d := r.dataio
	r.tui.set_cursor_position(r.prompt.offset() + d.index, d.in_lineno)
}

fn (mut r Repl) check_w_h() {
	if r.w != r.tui.window_width {
		r.should_redraw = true
		r.w = r.tui.window_width
		if r.tui.window_width < 110 && r.focus == .prog_list {
			r.focus == .prompt
		}
	}
	if r.h != r.tui.window_height {
		r.should_redraw = true
		r.w = r.tui.window_height
	}
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
	in_txt := r.dataio.in_txt.string()
	if in_txt.starts_with(cpfix) {
		cmd := in_txt.trim(cpfix).trim_space()
		if cmd in functions {
			functions[cmd](mut r)
		} else {
			r.dataio.result = 'Unknown command ${colors[.error](cmd)}'
		}
	} else {
		r.dataio.should_print = true
		r.dataio.result = in_txt.trim_space()
		r.set_in_out_lineno()
	}
	r.cursor_backward(r.dataio.in_txt.len)
	r.dataio.in_txt.clear()
	r.should_redraw = true
}

fn (mut r Repl) print() {
	if r.dataio.should_print {
		r.tui.draw_text(1, r.dataio.out_lineno, r.dataio.result)
	}
	r.dataio.should_print = true
}

fn (mut r Repl) set_in_out_lineno() {
	if !r.fixed {
		r.dataio.out_lineno = r.dataio.in_lineno + 1
		r.dataio.in_lineno += 2
	}
}

fn (mut r Repl) handle_message() {
	if r.msg.content != '' && r.tui.frame_count >= r.msg.msg_hide_tick {
		r.msg.content = ''
	}
	if r.msg.content != '' {
		r.tui.draw_text(1, r.dataio.in_lineno + 1, colors[.message](r.msg.content))
	}
}

fn (mut r Repl) show_msg(text string, time int) {
	frames := time * frame_rate
	r.msg.msg_hide_tick = if time > 0 { int(r.tui.frame_count) + frames } else { -1 }
	r.msg.content = text
}
