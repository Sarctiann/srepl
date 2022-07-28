module main

import os
import term

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
	repl.result = f_hf
}

fn clear(mut repl Repl) {
	term.clear()
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
