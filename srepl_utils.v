module main

struct WinSize {
mut:
	width  &int
	height &int
}

// fn (mut ws WinSize) is_size_changed(r Repl) bool {
// 	if ws.width != r.tui.window_width || ws.height != r.tui.window_height {
// 		ws.width = r.tui.window_width
// 		ws.height = r.tui.window_height
// 		return true
// 	}
// 	return false
// }

struct ScrollableTA {
mut:
	prompt    &Prompt
	fixed     bool
	in_text   []rune
	in_offset int
	in_linen  int = 1
	in_hist   []string
	out_text  []string
	out_linen int = 2
}

// fn (mut ta ScrollableTA) input_insert(s string) {
// 	ta.in_text.insert(ta.in_text.len + ta.in_offset, s.runes())
// }

// fn (mut ta ScrollableTA) input_remove(mut r Repl) {
// 	p := r.text_area.prompt
// 	if ta.in_offset > 0 - ta.in_text.len {
// 		r.tui.draw_text(p.prompt.len + 2, ta.in_linen, ' '.repeat(ta.in_text.len))
// 		ta.in_text.delete(ta.in_text.len + ta.in_offset - 1)
// 	}
// }

// fn (mut ta ScrollableTA) input_delete(mut r Repl) {
// 	p := r.text_area.prompt
// 	if ta.in_offset < 0 {
// 		r.tui.draw_text(p.prompt.len + 2, ta.in_linen, ' '.repeat(ta.in_text.len))
// 		ta.in_text.delete(ta.in_text.len + ta.in_offset)
// 		ta.in_offset++
// 	}
// }

// fn (mut ta ScrollableTA) cursor_backward(i int) {
// 	if ta.in_offset > 0 - ta.in_text.len {
// 		ta.in_offset -= i
// 	}
// }

// fn (mut ta ScrollableTA) cursor_forward(i int) {
// 	if ta.in_offset < 0 {
// 		ta.in_offset += i
// 	}
// }

// fn (ta &ScrollableTA) colored_in() string {
// 	if ta.in_text.len > 0 {
// 		return ta.prompt.colored() + ' ' + highlight_input(ta.in_text.string())
// 	} else {
// 		return ta.prompt.colored()
// 	}
// }

// fn (mut ta ScrollableTA) switch_mode() string {
// 	match ta.prompt.mode {
// 		.normal {
// 			ta.prompt.mode = .overwrite
// 			ta.prompt.color = .overwrite_prompt
// 			return 'switched to overwrite mode'
// 		}
// 		.overwrite {
// 			ta.prompt.mode = .normal
// 			ta.prompt.color = .normal_prompt
// 			return 'switched to normal mode'
// 		}
// 	}
// }

// fn (mut r Repl) set_cursor() {
// 	mut t := r.text_area
// 	in_index := t.prompt.prompt.len + 2 + t.in_text.len + t.in_offset
// 	r.tui.set_cursor_position(in_index, t.in_linen)
// }


// fn (mut r Repl) set_in_out_linen() {
// 	if r.text_area.fixed {
// 		r.text_area.in_linen = 1
// 		r.text_area.out_linen = 2
// 	} else {
// 		if r.should_print {
// 			in_lines_len := r.text_area.in_text.filter(it == `\n`).len + 1
// 			out_lines_len := r.text_area.out_text.len + 1
// 			r.text_area.out_linen = r.text_area.in_linen + in_lines_len
// 			r.text_area.in_linen = r.text_area.out_linen + out_lines_len
// 		}
// 	}
// }

struct Prompt {
mut:
	prompt       string
	color        THC
	mode         Mode
	indent_level int
}

// fn (p &Prompt) colored() string {
// 	return colors[p.color](p.prompt)
// }

struct BGInfo {
mut:
	scrollbar_pos int
	footer        string
	msg_text      string
	msg_color     THC
	msg_hide_tick int
}

// fn (mut bgi BGInfo) draw(r Repl) {
// 	// FIXME
// }

// fn (mut r Repl) draw_prog_list() {
// 	if r.tui.window_width > 109 {
// 		r.tui.set_bg_color(custom_colors[.ui_bg_elem])
// 		r.side_bar_pos = r.tui.window_width - r.tui.window_width / 4 - 1
// 		r.tui.draw_line(r.side_bar_pos, 1, r.side_bar_pos, r.tui.window_height)
// 		r.tui.reset()
// 	}
// }

// fn (mut r Repl) draw_footer() {
// 	if r.tui.window_width > 99 && r.tui.window_height > 31 {
// 		r.tui.set_bg_color(custom_colors[.ui_bg_elem])
// 		r.tui.set_color(custom_colors[.ui_fg_text])
// 		y := r.tui.window_height
// 		mode := 'Mode: $r.mode'
// 		focus := 'Focus on: $r.focus'
// 		fixed := 'Fixed: $r.fixed'
// 		lineno := 'Line No. in: $r.dataio.in_linen out: $r.dataio.out_lineno'
// 		status := '$mode | $focus | $fixed | $lineno'
// 		x := (r.tui.window_width - status.len) / 2
// 		r.tui.draw_line(1, y, r.tui.window_width, y)
// 		r.tui.draw_text(x, y, status)
// 		r.tui.reset()
// 	}
// }

// fn (mut bgi BGInfo) handle_msg(mut r Repl) {
// 	pos_x := r.text_area.in_linen + 1
// 	pos_y := 1
// 	if bgi.msg_text != '' && r.tui.frame_count >= bgi.msg_hide_tick {
// 		r.tui.draw_text(pos_y, pos_x, ' '.repeat(bgi.msg_text.len))
// 		bgi.msg_text = ''
// 	}
// 	if bgi.msg_text != '' {
// 		r.tui.draw_text(pos_y, pos_x, colors[bgi.msg_color](bgi.msg_text))
// 	}
// }

// fn (mut bgi BGInfo) show_msg(mut r Repl, text string, color THC, time int) {
// 	f := time * frame_rate
// 	bgi.msg_hide_tick = if time > 0 { int(r.tui.frame_count) + f } else { -1 }
// 	bgi.msg_text = text
// 	bgi.msg_color = color
// }

struct ProgList {
mut:
	user_prog []string
	u_p_linen int
}

// fn (mut pl ProgList) draw(r Repl) {
// 	// FIXME
// }

struct ReplData {
mut:
	srepl_folder string
	files        map[string]string
}
