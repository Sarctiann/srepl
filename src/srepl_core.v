module main

import term.ui as tui

struct Repl {
mut:
	tui       &tui.Context = unsafe { nil }
	text_area &TextArea    = unsafe { nil }
	prog_list &ProgList    = unsafe { nil }
	repl_data &ReplData    = unsafe { nil }
	bg_info   BGInfo
	drawer    ViewDrawer
	focus     Focus
	action    Action
}

[inline]
fn (mut r Repl) on_cycle_start() {
	r.tui.clear()
	r.drawer.handle_change_size()
	r.bg_info.handle_msg()
}

[inline]
fn (mut r Repl) read() {
	if r.action == .read {
		r.drawer.draw()
	}
}

[inline]
fn (mut r Repl) eval() {
	if r.action == .eval {
		// TODO: handle new line on multiline expression
		r.drawer.puts(r.text_area.colored_in())
		mut ta := r.text_area
		in_text := ta.in_text.string()
		if in_text.starts_with(cpfix) {
			// SREPL functions
			cmd := in_text.trim(cpfix).trim_space()
			if cmd in functions {
				functions[cmd](mut r)
			} else {
				result := 'Unknown command ${colors[.msg_error](cmd)}'
				r.drawer.puts(result)
				r.action = .print
			}
		} else {
			// EVAL
			if in_text.trim_space() != '' {
				todo := colors[.msg_error](' EVAL ENGINE NOT IMPLEMENTED YET')
				r.drawer.puts(in_text.trim_space() + todo)
			}
			r.action = .print
		}

		// Execute Always
		ta.in_offset = 0
		r.drawer.out_offset = 0
		ta.in_text.clear()
		r.action = .read
	}
}

[inline]
fn (mut r Repl) print() {
	if r.action == .print {
		r.drawer.draw()
		r.action = .read
	}
}

[inline]
fn (mut r Repl) on_cycle_end() {
	r.tui.reset()
	r.tui.flush()
}

fn (mut r Repl) change_focus() {
	if r.tui.window_width > 109 {
		match r.focus {
			.text_area {
				r.focus = .prog_list
				r.tui.hide_cursor()
			}
			.prog_list {
				r.focus = .text_area
				r.tui.show_cursor()
			}
		}
	} else {
		r.focus = .text_area
	}
}

// TODO, FIXME, SUPER -WIP
[inline]
fn (mut r Repl) should_eval() {
	if r.text_area.in_text.len > 0 {
			last_rune := r.text_area.in_text.filter(it != ` `).last()
			match true {
				last_rune in ml_flag_chars {
					if last_rune in ml_clousures {
						r.text_area.ml_flags << ml_clousures[last_rune]
					}
					r.text_area.input_insert('\n')
				}
				r.text_area.ml_flags.len == 0 {
					r.action = .eval
				} 
				last_rune == r.text_area.ml_flags.last() {
						r.text_area.ml_flags.delete_last()
				}
				else {
				}
			} 
		}
	else {
		r.action = .eval
	}
}
