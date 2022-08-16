module main

import os

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
