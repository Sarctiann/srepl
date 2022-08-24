module main

import os

fn list(mut r Repl) {
	r.dataio.result = colors[.msg_error]('Not implemented yet')
	r.should_print = true
}

fn reset(mut r Repl) {
	r.dataio.result = colors[.msg_error]('Not implemented yet')
	r.should_print = true
}

fn show_help(mut r Repl) {
	help_file := os.read_file('help.txt') or { panic('Missing Help File') }
	mut f_hf := help_file.replace('cpfix', cpfix)
	for k, v in commands {
		f_hf = f_hf.replace('-$k', '$k or $cpfix$v')
	}
	r.dataio.result = f_hf
	r.should_print = true
}

fn clear(mut r Repl) {
	r.tui.clear()
	r.dataio.in_txt.clear()
	r.dataio.result = ''
	r.dataio.in_offset = 0
	r.dataio.in_lineno = 1
	r.dataio.out_lineno = 2
}

fn quit(mut r Repl) {
	println('')
	exit(0)
}

fn mode(mut r Repl) {
	r.should_print = false
	match r.mode {
		.normal {
			r.mode = .overwrite
			r.prompt.color = colors[.overwrite_prompt]
			r.show_msg('switched to overwrite mode', .msg_warn, 2)
		}
		.overwrite {
			r.mode = .normal
			r.prompt.color = colors[.normal_prompt]
			r.show_msg('switched to normal mode', .msg_info, 2)
		}
	}
}

fn fix_top(mut r Repl) {
	match r.fixed {
		true {
			r.fixed = false
			r.show_msg('Switched to no fixed prompt', .msg_info, 2)
		}
		false {
			r.fixed = true
			r.dataio.out_lineno = 2
			clear(mut r)
			r.show_msg('Switched to fixed prompt', .msg_warn, 2)
		}
	}
}

fn file(mut r Repl) {
	r.dataio.result = colors[.msg_error]('Not implemented yet')
	r.should_print = true
}

fn path(mut r Repl) {
	r.dataio.result = colors[.msg_error]('Not implemented yet')
	r.should_print = true
}

fn save(mut r Repl) {
	r.dataio.result = colors[.msg_error]('Not implemented yet')
	r.should_print = true
}
