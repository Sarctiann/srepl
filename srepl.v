module main

import os
import os.cmdline
import term.ui as tui

fn main() {
	args := cmdline.options_after(os.args, ['./srepl', 'srepl'])

	mut repl := new_repl(args)

	repl.tui.run()?
}

fn new_repl(args []string) &Repl {
	ini_mode := if '-ow' in args { Mode.overwrite } else { Mode.normal }
	mut app := &Repl{
		mode: ini_mode
		prompt: Prompt{
			color: match ini_mode {
				.normal { colors[.normal_prompt] }
				.overwrite { colors[.overwrite_prompt] }
			}
		}
	}
	app.tui = tui.init(
		user_data: app
		event_fn: read
		frame_fn: frame
		frame_rate: frame_rate
	)
	return app
}

struct Repl {
mut:
	tui    &tui.Context = unsafe { 0 }
	mode   Mode
	prompt Prompt
	dataio DataIO
}

fn (mut r Repl) input_insert(s string) {
	r.dataio.in_txt.insert(r.dataio.index, s.runes())
	r.dataio.index++
}

fn (mut r Repl) input_remove() {
	if r.dataio.index > 0 {
		r.dataio.index--
		r.dataio.in_txt.delete(r.dataio.index)
	}
}

fn (mut r Repl) input_delete() {
	if r.dataio.index < r.dataio.in_txt.len {
		r.dataio.in_txt.delete(r.dataio.index)
	}
}

fn (mut r Repl) cursor_backward(i int) {
	if r.dataio.index > 0 {
		r.dataio.index -= i
	}
}

fn (mut r Repl) cursor_forward(i int) {
	if r.dataio.index < r.dataio.in_txt.len {
		r.dataio.index += i
	}
}

fn (mut r Repl) eval() {
	in_txt := r.dataio.in_txt.string()
	if in_txt.starts_with(cpfix) {
		cmd := in_txt.trim(cpfix).trim_space()
		if cmd in functions {
			functions[cmd](mut r)
		} else {
			r.dataio.result = 'Unknown command ${colors[.error](cmd)}'
		}
	} else {
		r.dataio.should_print = true
		r.dataio.result = in_txt.trim_space()
	}
}

fn (mut r Repl) print() {
	if r.dataio.should_print {
		r.tui.draw_text(1, 2, r.dataio.result)
	}
	r.dataio.should_print = true
}

fn (mut r Repl) set_cursor() {
	r.tui.set_cursor_position(r.prompt.offset() + r.dataio.index, 1)
}

struct Prompt {
mut:
	prompt string = '>>>'
	color  fn (string) string
}

fn (p &Prompt) show() string {
	return p.color(p.prompt)
}

fn (p &Prompt) offset() int {
	return p.prompt.len + 2
}

struct DataIO {
mut:
	in_txt       []rune
	index        int
	result       string
	indent_level int
	should_print bool
}
