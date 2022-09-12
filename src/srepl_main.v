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
		text_area: &TextArea{
			prompt: &Prompt{
				prompt: '>>>'
				mode: ini_mode
				color: match ini_mode {
					.normal { THC.normal_prompt }
					.overwrite { THC.overwrite_prompt }
				}
			}
			fixed: ini_fix_top
		}
		prog_list: &ProgList{}
		repl_data: &ReplData{
			srepl_folder: 'srepl-$rand.ulid()'
			files: {
				'main': 'main.v'
			}
		}
		focus: Focus.text_area
		action: .read
	}
	app.tui = tui.init(
		user_data: app
		event_fn: handle_events
		frame_fn: each_frame
		frame_rate: frame_rate
	)
	app.bg_info = &BGInfo{
		frame_count: &app.tui.frame_count
		msg_text: 'Wellcome to SREPL!, type :help for more information!'
		msg_color: THC.msg_info
		msg_hide_tick: 3 * frame_rate
	}
	app.drawer = ViewDrawer{
		draw_text: unsafe { app.tui.draw_text }
		draw_line: unsafe { app.tui.draw_line }
		set_cur_pos: unsafe { app.tui.set_cursor_position }
		set_bg_color: unsafe { app.tui.set_bg_color }
		set_color: unsafe { app.tui.set_color }
		size: &WinSize{
			new_w: &app.tui.window_width
			new_h: &app.tui.window_height
		}
		text_area: app.text_area
		prog_list: app.prog_list
		bg_info: &app.bg_info
		focus: &app.focus
	}
	return app
}

fn handle_events(e &tui.Event, app voidptr) {
	mut r := &Repl(app)
	match e.modifiers {
		.ctrl {}
		.shift {
			match e.code {
				.up {
					r.drawer.scroll_up()
				}
				.down {
					r.drawer.scroll_down()
				}
				.left, .right {
					r.change_focus()
				}
				else {}
			}
		}
		.alt {}
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
						r.text_area.cursor_backward(1)
					}
					.right {
						r.text_area.cursor_forward(1)
					}
					.backspace {
						r.text_area.input_remove()
					}
					.delete {
						r.text_area.input_delete()
					}
					.enter {
						// TODO: handle new line on multiline expression
						r.drawer.puts(r.text_area.colored_in())
						r.action = .eval
					}
					else {
						// TODO: handle new line on width limit
						r.text_area.input_insert(e.utf8)
					}
				}
			} else {
				// TODO: handle mouse events
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