module main

import os
import readline
import os.cmdline

struct Repl {
mut:
	readline readline.Readline
}

fn main() {
	args := cmdline.options_after(os.args, ['repl'])

	mut repl := new_repl(args)
	repl.loop()
}

fn new_repl(args []string) Repl {
	return Repl{
		readline: readline.Readline{
			skip_empty: true
		}
	}
}

fn (mut r Repl) read() {
	r.readline.read_line('>>> ') or { exit(0) }
}

fn (mut r Repl) eval() {
}

fn (mut r Repl) print() {
}

fn (mut r Repl) loop() {
	r.read()
	r.eval()
	r.print()
}
