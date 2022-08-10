module main

import os
import term.ui as tui

fn read(e &tui.Event, x voidptr) {
	mut r := &Repl(x)
	if e.modifiers == .shift {
		match e.code {
			.up {
				r.prev_focus()
			}
			.down {
				r.next_focus()
			}
			else {}
		}
	}
	match r.focus {
		.prompt {
			if e.typ == .key_down {
				match e.code {
					.escape {
						quit(mut r)
					}
					.up, .down {}
					.left {
						r.cursor_backward(1)
					}
					.right {
						r.cursor_forward(1)
					}
					.backspace {
						r.input_remove()
					}
					.delete {
						r.input_delete()
					}
					.enter {
						r.eval()
					}
					else {
						r.input_insert(e.utf8)
					}
				}
			} else {
			}
		}
		.result {}
		.prog_list {}
	}
}

fn frame(x voidptr) {
	mut r := &Repl(x)
	d := r.dataio

	r.check_w_h()
	if r.should_redraw {
		r.tui.clear()
		r.should_redraw = false
	}
	
	r.handle_message()
	r.draw_prog_list()
	r.draw_footer()
	r.tui.draw_text(1, r.dataio.in_lineno, r.prompt.show())
	r.tui.draw_text(r.prompt.offset(), d.in_lineno, d.in_txt.string())
	r.print()
	r.set_cursor()

	r.tui.reset()
	r.tui.flush()
}

fn list(mut r Repl) {
}

fn reset(mut r Repl) {
}

fn show_help(mut r Repl) {
	help_file := os.read_file('help.txt') or { panic('Missing Help File') }
	mut f_hf := help_file.replace('cpfix', cpfix)
	for k, v in commands {
		f_hf = f_hf.replace('-$k', '$k or $cpfix$v')
	}
	r.dataio.should_print = true
	r.dataio.result = f_hf
}

fn clear(mut r Repl) {
	r.dataio.in_txt.clear()
	r.dataio.result = ''
	r.dataio.index = 0
	r.dataio.in_lineno = 1
	r.dataio.out_lineno = 2
}

fn quit(mut r Repl) {
	exit(0)
}

fn mode(mut r Repl) {
	r.mode = match r.mode {
		.normal { .overwrite }
		.overwrite { .normal }
	}
	r.prompt.color = match r.mode {
		.normal { colors[.normal_prompt] }
		.overwrite { colors[.overwrite_prompt] }
	}
}

fn fix_top(mut r Repl) {
	match r.fixed {
		true {
			r.fixed = false
		}
		false {
			r.fixed = true
			clear(mut r)
		}
	}
}

fn file(mut r Repl) {
}

fn path(mut r Repl) {
}

fn save(mut r Repl) {
}
