module main

import os

fn list(mut r Repl) {
	// r.text_area.out_text << colors[.msg_error]('Not implemented yet')
	// r.should_print = true
}

fn reset(mut r Repl) {
	// r.text_area.out_text << colors[.msg_error]('Not implemented yet')
	// r.should_print = true
}

fn show_help(mut r Repl) {
	// help_file := os.read_file('help.txt') or { panic('Missing Help File') }
	// mut f_hf := help_file.replace('cpfix', cpfix)
	// for k, v in commands {
	// 	f_hf = f_hf.replace('-$k', '$k or $cpfix$v')
	// }
	// r.text_area.out_text << f_hf
	// r.should_print = true
}

fn clear(mut r Repl) {
	// r.tui.clear()
	// r.text_area.in_text.clear()
	// r.text_area.out_text << ''
	// r.text_area.in_offset = 0
	// r.text_area.in_linen = 1
	// r.text_area.out_linen = 2
}

fn quit(mut r Repl) {
	println('')
	exit(0)
}

fn mode(mut r Repl) {
	// prompt_msg := r.text_area.switch_mode()
	// r.bg_info.show_msg(mut r, prompt_msg, .msg_info, 2)
	// r.should_print = false
}

fn fix_top(mut r Repl) {
// 	match r.text_area.fixed {
// 		true {
// 			r.text_area.fixed = false
// 			r.bg_info.show_msg(mut r, 'Switched to no fixed prompt', .msg_info, 2)
// 		}
// 		false {
// 			r.text_area.fixed = true
// 			r.text_area.out_linen = 2
// 			clear(mut r)
// 			r.bg_info.show_msg(mut r, 'Switched to fixed prompt', .msg_warn, 2)
// 		}
// 	}
}

fn file(mut r Repl) {
	// r.text_area.out_text << colors[.msg_error]('Not implemented yet')
	// r.should_print = true
}

fn path(mut r Repl) {
	// r.text_area.out_text << colors[.msg_error]('Not implemented yet')
	// r.should_print = true
}

fn save(mut r Repl) {
	// r.text_area.out_text << colors[.msg_error]('Not implemented yet')
	// r.should_print = true
}
