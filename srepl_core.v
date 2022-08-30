module main

import term.ui as tui

struct Repl {
mut:
	tui          &tui.Context = unsafe { nil }
	// general
	size         WinSize
	focus        Focus
	repl_data    &ReplData
	// views
	text_area    &ScrollableTA
	bg_info      &BGInfo
	prog_list    &ProgList
	// helpers
	should_eval  bool
	should_print bool
}

fn (mut r Repl) on_cycle_start() {
// 	if r.size.is_size_changed(r) {
// 		r.tui.clear()
// 		r.bg_info.draw(r)
// 		r.prog_list.draw(r)
// 	}
// 	r.bg_info.handle_msg(mut r)
}

fn (mut r Repl) read() {
// 	r.tui.draw_text(1, r.text_area.in_linen, r.text_area.colored_in())
}

fn (mut r Repl) eval() {
// 	if r.should_eval {
// 		mut t := r.text_area
// 		// handle existing message before moving cursor
// 		r.tui.draw_text(1, t.in_linen + 1, ' '.repeat(r.bg_info.msg_text.len))
// 		in_text := t.in_text.string()
// 		if in_text.starts_with(cpfix) {
// 			cmd := in_text.trim(cpfix).trim_space()
// 			if cmd in functions {
// 				functions[cmd](mut r)
// 			} else {
// 				t.out_text << 'Unknown command ${colors[.msg_error](cmd)}'
// 				r.should_print = true
// 			}
// 		} else {
// 			if in_text.trim_space() != '' {
// 				todo := colors[.msg_error](' EVAL ENGINE NOT IMPLEMENTED YET')
// 				t.out_text << in_text.trim_space() + todo
// 			}
// 			r.should_print = true
// 		}
// 		r.set_in_out_linen()
// 		r.tui.draw_text(t.prompt.prompt.len + 2, t.in_linen, ' '.repeat(t.in_text.len))
// 		t.in_offset = 0
// 		t.in_text.clear()

// 		r.should_eval = false
// 	}
}

fn (mut r Repl) print() {
// 	if r.should_print {
// 		r.tui.draw_text(1, r.text_area.out_linen, r.text_area.out_text.join('\n'))
// 		r.should_print = false
// 	}
}

fn (mut r Repl) on_cycle_end() {
// 	r.set_cursor()
// 	r.tui.reset()
// 	r.tui.flush()
}

fn (mut r Repl) change_focus() {
// 	r.focus = match r.focus {
// 		.text_area {
// 			if r.tui.window_width > 109 { Focus.prog_list } else { Focus.text_area }
// 		}
// 		.prog_list {
// 			Focus.text_area
// 		}
// 	}
}
