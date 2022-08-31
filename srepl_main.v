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
		// size: &WinSize{}
		focus: Focus.text_area
		repl_data: &ReplData{
			srepl_folder: 'srepl-$rand.ulid()'
			files: {
				'main': 'main.v'
			}
		}
		bg_info: &BGInfo{
			msg_text: 'Wellcome to SREPL!, type :help for more information!'
			msg_color: THC.msg_info
			msg_hide_tick: 3 * frame_rate
		}
		prog_list: &ProgList{}
	}
	app.tui = tui.init(
		user_data: app
		event_fn: handle_events
		frame_fn: each_frame
		frame_rate: frame_rate
	)
	app.size = WinSize{
		new_w: &app.tui.window_width
		new_h: &app.tui.window_height
	}
	app.text_area = &ScrollableTA{
		prompt: &Prompt{
			prompt: '>>>'
			mode: ini_mode
			color: match ini_mode {
				.normal { THC.normal_prompt }
				.overwrite { THC.overwrite_prompt }
			}
		}
		fixed: ini_fix_top
		tui_draw: unsafe { app.tui.draw_text }
	}
	return app
}

fn handle_events(e &tui.Event, app voidptr) {
	mut r := &Repl(app)
	if e.modifiers == .shift {
		match e.code {
			.up, .down {
				// r.change_focus()
			}
			else {}
		}
	}
	match r.focus {
		.text_area {
			if e.typ == .key_down {
				match e.code {
					.escape {
						quit(mut r)
					}
					.up, .down {}
					.left {
						// r.text_area.cursor_backward(1)
					}
					.right {
						// r.text_area.cursor_forward(1)
					}
					.backspace {
						// r.text_area.input_remove(mut r)
					}
					.delete {
						// r.text_area.input_delete(mut r)
					}
					.enter {
						// r.should_eval = true
					}
					else {
						// r.text_area.input_insert(e.utf8)
					}
				}
			} else {
			}
		}
		.prog_list {}
	}
}

fn each_frame(app voidptr) {
	mut r := &Repl(app)

	r.on_cycle_start()
	r.read()
	r.eval()
	r.print()
	r.on_cycle_end()
}
