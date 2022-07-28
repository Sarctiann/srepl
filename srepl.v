module main

import os
import readline
import os.cmdline

struct Repl {
mut:
	readline readline.Readline
	indent   int
	mode     Mode
	prompt   string = '>>> '
	pcolor   fn (string) string
	cur_inln string
	result   string
}

fn main() {
	args := cmdline.options_after(os.args, ['./srepl', 'srepl'])

	mut repl := new_repl(args)
	repl.loop()
	exit(0)
}

fn new_repl(args []string) Repl {
	ini_mode := if '-ow' in args { Mode.overwrite } else { Mode.normal }
	return Repl{
		readline: readline.Readline{
			skip_empty: true
		}
		mode: ini_mode
		pcolor: match ini_mode {
			.normal { colors[.normal_prompt] }
			.overwrite { colors[.overwrite_prompt] }
		}
		// result: OptPrint{}
	}
}

fn (mut repl Repl) loop() {
	for {
		repl.read()
		repl.eval()
		repl.print()
	}
}

fn (mut repl Repl) read() {
	repl.cur_inln = repl.readline.read_line(repl.pcolor(repl.prompt)) or {
		println('')
		exit(0)
	}
}

fn (mut repl Repl) eval() {
	if repl.cur_inln.starts_with(cpfix) {
		cmd := repl.cur_inln.trim(cpfix).trim_space()
		if cmd in functions {
			functions[cmd](mut repl)
		} else {
			eprintln('Unknown command ${colors[.error](cmd)}')
		}
	} else {
		repl.result = repl.cur_inln.trim_space()
	}
}

fn (mut repl Repl) print() {
		println(repl.result)
}
