module main

import term.ui as tui

struct Repl {
mut:
	tui       &tui.Context = unsafe { nil }
	text_area &TextArea
	prog_list &ProgList
	repl_data &ReplData
	bg_info   BGInfo
	drawer    ViewDrawer
	focus     Focus
	action    Action
}

fn (mut r Repl) on_cycle_start() {
	r.tui.clear()
	r.drawer.size.handle_change_size()
	r.bg_info.handle_msg()
}

fn (mut r Repl) read() {
	if r.action == .read {
		r.drawer.draw()
	}
}

fn (mut r Repl) eval() {
	if r.action == .eval {
		mut ta := r.text_area

		in_text := ta.in_text.string()
		if in_text.starts_with(cpfix) {
			cmd := in_text.trim(cpfix).trim_space()
			if cmd in functions {
				functions[cmd](mut r)
			} else {
				result := 'Unknown command ${colors[.msg_error](cmd)}'
				r.drawer.puts(result)
				r.action = .print
			}
		} else {
			if in_text.trim_space() != '' {
				todo := colors[.msg_error](' EVAL ENGINE NOT IMPLEMENTED YET')
				r.drawer.puts(in_text.trim_space() + todo)
			}
			r.action = .print
		}
		ta.in_offset = 0
		ta.in_text.clear()
		r.action = .read
	}
}

fn (mut r Repl) print() {
	if r.action == .print {
		r.drawer.draw()
		r.action = .read
	}
}

fn (mut r Repl) on_cycle_end() {
	r.tui.reset()
	r.tui.flush()
}

fn (mut r Repl) change_focus() {
	if r.tui.window_width > 109 {
		r.focus = match r.focus {
			.text_area { .prog_list }
			.prog_list { .text_area }
		}
	} else {
		r.focus = .text_area
	}
}
