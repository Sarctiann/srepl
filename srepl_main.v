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
		event_fn: handle_events
		frame_fn: each_frame
		frame_rate: frame_rate
	)
	return app
}

fn handle_events(e &tui.Event, app voidptr) {
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

fn each_frame(app voidptr) {
	mut r := &Repl(app)

	r.on_cycle_start()

	r.read()

	if r.should_eval {
		r.eval()
	}

	if r.should_print {
		r.print()
	}

	r.on_cycle_end()
}
