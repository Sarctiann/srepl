module main

import os
import term
import readline
import os.cmdline

struct Repl {
mut:
	readline readline.Readline
	prompt   string = term.bright_blue('>>> ')
	cur_line string
}

fn main() {
	args := cmdline.options_after(os.args, ['repl'])

	mut repl := new_repl(args)
	repl.loop()
	exit(0)
}

fn new_repl(args []string) Repl {
	return Repl{
		readline: readline.Readline{
			skip_empty: true
		}
	}
}

fn (mut r Repl) read() {
	r.cur_line = r.readline.read_line(r.prompt) or { 
		println('')
		exit(0)	
	}
}

fn (mut r Repl) eval() {
}

fn (mut r Repl) print() {
	print(r.cur_line)
}

fn (mut r Repl) loop() {
	for {
		r.read()
		r.eval()
		r.print()
	}
}
