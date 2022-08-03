module main

import os
import readline
import os.cmdline
import term.ui as tui

struct Repl {
mut:
	tui      &tui.Context = unsafe { 0 }
	indent   int
	mode     Mode
	prompt   string = '>>> '
	pcolor   fn (string) string
	cur_inln string
	result   OptPrint
}

struct OptPrint {
mut:
	content      string
	should_print bool
}

fn main() {
	args := cmdline.options_after(os.args, ['./srepl', 'srepl'])
	mut repl := new_repl(args)

	repl.tui = tui.init(
		user_data: repl
		event_fn: event
		frame_fn: frame
		frame_rate: frame_rate
		hide_cursor: true
	)

	repl.tui.run()?
}

fn new_repl(args []string) &Repl {
	ini_mode := if '-ow' in args { Mode.overwrite } else { Mode.normal }
	return &Repl{
		readline: readline.Readline{
			skip_empty: true
		}
		mode: ini_mode
		pcolor: match ini_mode {
			.normal { colors[.normal_prompt] }
			.overwrite { colors[.overwrite_prompt] }
		}
	}
}

fn event(e &tui.Event, x voidptr) {
	if e.typ == .key_down && e.code == .escape {
		exit(0)
	}
}

fn frame(x voidptr) {
	mut repl := &Repl(x)

	repl.tui.clear()
	repl.tui.draw_text(0, 0, repl.prompt)
	repl.tui.set_bg_color(r: 63, g: 81, b: 181)
	repl.tui.draw_rect(20, 6, 40, 10)
	repl.tui.draw_text(22, 8, 'Hi Sarctiann RELP')
	repl.tui.set_cursor_position(0, 0)

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
