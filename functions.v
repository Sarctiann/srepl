module main

import os
import term.ui as tui

fn event(e &tui.Event, x voidptr) {
	mut repl := &Repl(x)
	if e.typ == .key_down && e.code == .escape {
		exit(0)
	} else {
		repl.result.content += e.utf8
	}
}

fn frame(x voidptr) {
	mut repl := &Repl(x)

	repl.tui.clear()
	repl.tui.draw_text(0, 0, repl.pcolor(repl.prompt))
	repl.tui.draw_text(5, 0, repl.result.content)

	repl.tui.reset()
	repl.tui.flush()
}

// fn (mut repl Repl) loop() {
// 	for {
// 		repl.read()
// 		repl.eval()
// 		repl.print()
// 	}
// }

// fn (mut repl Repl) read() {
// 	repl.cur_inln = repl.readline.read_line(repl.pcolor(repl.prompt)) or {
// 		println('')
// 		exit(0)
// 	}
// }

// fn (mut repl Repl) eval() {
// 	if repl.cur_inln.starts_with(cpfix) {
// 		cmd := repl.cur_inln.trim(cpfix).trim_space()
// 		if cmd in functions {
// 			functions[cmd](mut repl)
// 		} else {
// 			eprintln('Unknown command ${colors[.error](cmd)}')
// 		}
// 	} else {
// 		repl.result.should_print = true
// 		repl.result.content = repl.cur_inln.trim_space()
// 	}
// }

// fn (mut repl Repl) print() {
// 	if repl.result.should_print {
// 		println(repl.result.content)
// 	}
// 	repl.result.should_print = true
// }

fn list(mut repl Repl) {
}

fn reset(mut repl Repl) {
}

fn show_help(mut repl Repl) {
	help_file := os.read_file('help.txt') or { panic('Missing Help File') }
	mut f_hf := help_file.replace('cpfix', cpfix)
	for k, v in commands {
		f_hf = f_hf.replace('-$k', '$k or $cpfix$v')
	}
	repl.result.content = f_hf
}

fn clear(mut repl Repl) {
	repl.tui.clear()
}

fn quit(mut repl Repl) {
	exit(0)
}

fn mode(mut repl Repl) {
	repl.mode = match repl.mode {
		.normal { .overwrite }
		.overwrite { .normal }
	}
	repl.pcolor = match repl.mode {
		.normal { colors[.normal_prompt] }
		.overwrite { colors[.overwrite_prompt] }
	}
}

fn file(mut repl Repl) {
}

fn path(mut repl Repl) {
}

fn save(mut repl Repl) {
}
