module main

import os
import term.ui as tui

fn read(e &tui.Event, x voidptr) {
	mut r := &Repl(x)
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

fn frame(x voidptr) {
	mut r := &Repl(x)

	r.tui.clear()

	r.tui.draw_text(1, 1, r.prompt.show())
	r.tui.draw_text(r.prompt.offset(), 1, r.dataio.in_txt.string())
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
	r.dataio.result = ''
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
	r.fixed = match r.fixed {
		true { false }
		false { true }
	}
}

fn file(mut r Repl) {
}

fn path(mut r Repl) {
}

fn save(mut r Repl) {
}
