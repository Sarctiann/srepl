module main

import os
import os.cmdline
import term.ui as tui

struct Repl {
mut:
	tui      &tui.Context = unsafe { 0 }
	inline   string
	indent   int
	mode     Mode
	prompt   string = '>>>'
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
	
	repl.tui.run()?
}

fn new_repl(args []string) &Repl {
	ini_mode := if '-ow' in args { Mode.overwrite } else { Mode.normal }
	mut app := &Repl{
		mode: ini_mode
		pcolor: match ini_mode {
			.normal { colors[.normal_prompt] }
			.overwrite { colors[.overwrite_prompt] }
		}	
	}
	app.tui = tui.init(
		user_data: app
		event_fn: event
		frame_fn: frame
		frame_rate: frame_rate
		// hide_cursor: true
	)
	return app
}
