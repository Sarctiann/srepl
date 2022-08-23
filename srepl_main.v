module main

import os
import rand
import os.cmdline
import term.ui as tui

fn main() {
	args := cmdline.options_after(os.args, ['./srepl', 'srepl'])

	mut repl := new_repl(args)

	repl.tui.run()?
}

fn new_repl(args []string) &Repl {
	ini_mode := if '-ow' in args { Mode.overwrite } else { Mode.normal }
	ini_fix_top := '-ft' in args
	mut app := &Repl{
		mode: ini_mode
		focus: Focus.prompt
		fixed: ini_fix_top
		prompt: &Prompt{
			color: match ini_mode {
				.normal { colors[.normal_prompt] }
				.overwrite { colors[.overwrite_prompt] }
			}
		}
		dataio: &DataIO{}
		databuff: &DataBuff{}
		filesio: &FilesIO{
			srepl_folder: 'srepl-$rand.ulid()'
			files: {
				'main': 'main.v'
			}
		}
		msg: &Msg{
			content: 'Wellcome to SREPL!, type :help for more information!'
			color: THC.msg_info
			msg_hide_tick: 3 * frame_rate
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

fn read(e &tui.Event, app voidptr) {
	mut r := &Repl(app)
	if e.modifiers == .shift {
		match e.code {
			.up {
				r.prev_focus()
			}
			.down {
				r.next_focus()
			}
			else {}
		}
	}
	match r.focus {
		.prompt {
			if e.typ == .key_down {
				match e.code {
					.escape {
						quit(mut r)
					}
					.up, .down {}
					.left {
						r.cursor_backward(1)
					}
					.right {
						r.cursor_forward(1)
					}
					.backspace {
						r.input_remove()
					}
					.delete {
						r.input_delete()
					}
					.enter {
						r.eval()
					}
					else {
						r.input_insert(e.utf8)
					}
				}
			} else {
			}
		}
		.result {}
		.prog_list {}
	}
}

fn frame(app voidptr) {
	mut r := &Repl(app)
	d := r.dataio

	if r.should_redraw {
		r.tui.clear()
		if debug {
			r.show_msg('redraw on frame $r.tui.frame_count', .msg_info, 1)
		}
		r.should_redraw = false
	}

	r.handle_message()
	r.check_w_h()

	r.tui.draw_text(1, d.in_lineno, r.prompt.show())
	r.tui.draw_text(r.prompt.offset(), d.in_lineno, d.colored_in())

	r.print()
	r.set_cursor()

	r.tui.reset()
	r.tui.flush()
}
