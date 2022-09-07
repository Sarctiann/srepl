module main

import os

fn list(mut r Repl) {
	result := colors[.msg_error]('Not implemented yet')
	r.drawer.puts(result)
	r.action = .print
}

fn reset(mut r Repl) {
	result := colors[.msg_error]('Not implemented yet')
	r.drawer.puts(result)
	r.action = .print
}

fn show_help(mut r Repl) {
	help := os.read_file(help_file) or { panic('Missing Help File') }
	mut f_hf := help.replace('cpfix', cpfix)
	for k, v in commands {
		f_hf = f_hf.replace('-$k', '$k or $cpfix$v')
	}
	r.drawer.puts(f_hf)
	r.action = .print
}

fn clear(mut r Repl) {
	r.text_area.in_text.clear()
	r.drawer.out_text.clear()
	r.text_area.in_offset = 0
	r.drawer.in_linen = 1
	r.drawer.out_linen = 1
}

fn quit(mut r Repl) {
	println('')
	exit(0)
}

fn mode(mut r Repl) {
	prompt_msg, severity := r.text_area.switch_mode()
	r.bg_info.show_msg(prompt_msg, severity, 2)
}

fn fix_top(mut r Repl) {
	match r.text_area.fixed {
		true {
			r.text_area.fixed = false
			r.bg_info.show_msg('Switched to no fixed prompt', .msg_info, 2)
		}
		false {
			r.text_area.fixed = true
			r.drawer.out_linen = 2
			clear(mut r)
			r.bg_info.show_msg('Switched to fixed prompt', .msg_warn, 2)
		}
	}
}

fn file(mut r Repl) {
	result := colors[.msg_error]('Not implemented yet')
	r.drawer.puts(result)
	r.action = .print
}

fn path(mut r Repl) {
	result := colors[.msg_error]('Not implemented yet')
	r.drawer.puts(result)
	r.action = .print
}

fn save(mut r Repl) {
	result := colors[.msg_error]('Not implemented yet')
	r.drawer.puts(result)
	r.action = .print
}
