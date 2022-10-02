module main

struct TextArea {
	Prompt
mut:
	fixed     bool
	in_text   []rune // TODO: [][]rune{len: 1, init: []rune{}}
	in_offset int
	line_offs int
	in_hist   []string
}

fn (mut ta TextArea) input_insert(s string) {
	ta.in_text.insert(ta.in_text.len - ta.in_offset, s.runes())
}

fn (mut ta TextArea) should_eval() bool {
	last_rune := ta.in_text.filter(it != ` `).last()
	mut ml_flags := ta.in_text.filter(it in ml_clousures).map(ml_clousures[it]).reverse()
	for r in ta.in_text {
		if r in ml_flags {
			ml_flags.delete(ml_flags.index(r))
			if r == last_rune && ta.indent_level > 0 {
				ta.indent_level -= 1
			}
		}
	}
	if ml_flags.len == 0 && last_rune !in ml_flag_chars {
		ta.indent_level = 0
		return true
	} else {
		if last_rune in ml_clousures {
			ta.indent_level += 1
		}
		ta.input_insert('\n${'\t'.repeat(ta.indent_level)}')
		return false
	}
}

fn (mut ta TextArea) cursor_backward(d Displacement) {
	cur_line := ta.cur_line()
	match d {
		.char {
			ta.handle_cursor_movement(.back)
		}
		.word {
			for cur_line.len - ta.in_offset > 0 {
				if cur_line[cur_line.len - 1 - ta.in_offset] in word_separators {
					ta.handle_cursor_movement(.back)
				} else {
					break
				}
			}
			for cur_line.len - ta.in_offset > 0 {
				if cur_line[cur_line.len - 1 - ta.in_offset] !in word_separators {
					ta.handle_cursor_movement(.back)
				} else {
					break
				}
			}
			ta.handle_cursor_movement(.back)
		}
	}
}

fn (mut ta TextArea) cursor_forward(d Displacement) {
	cur_line := ta.cur_line()
	match d {
		.char {
			ta.handle_cursor_movement(.forth)
		}
		.word {
			for ta.in_offset > 0 {
				if cur_line[cur_line.len - ta.in_offset] in word_separators {
					ta.handle_cursor_movement(.forth)
				} else {
					break
				}
			}
			for ta.in_offset > 0 {
				if cur_line[cur_line.len - ta.in_offset] !in word_separators {
					ta.handle_cursor_movement(.forth)
				} else {
					break
				}
			}
			ta.handle_cursor_movement(.forth)
		}
	}
}

fn (mut ta TextArea) input_delete() {
	ta.handle_cursor_movement(.del)
}

fn (mut ta TextArea) input_suppress() {
	ta.handle_cursor_movement(.sup)
}

[inline]
fn (mut ta TextArea) handle_cursor_movement(cm CursorMovement) {
	cur_line := ta.cur_line()
	how_many_lines := ta.how_many_lines()
	match cm {
		.back {
			if ta.in_offset < cur_line.len {
				ta.in_offset += 1
			} else if ta.line_offs < how_many_lines - 1 {
				ta.in_offset = 0
				ta.line_offs += 1
			}
		}
		.forth {
			if ta.in_offset > 0 {
				ta.in_offset -= 1
			} else if how_many_lines > 1 && ta.line_offs > 0 {
				ta.line_offs -= 1
				ta.in_offset = ta.cur_line().len
			}
		}
		.del {
			if ta.in_text.len - ta.in_offset > 0 {
				idx := ta.in_text.len - ta.in_offset - 1
				if ta.in_text[idx] == `\t` && ta.indent_level > 0 {
					ta.indent_level -= 1
				}
				ta.in_text.delete(idx)
			}
		}
		.sup {
			if ta.in_offset > 0 {
				idx := ta.in_text.len - ta.in_offset
				if ta.in_text[idx] == `\t` && ta.indent_level > 0 {
					ta.indent_level -= 1
				}
				ta.in_text.delete(idx)
				ta.in_offset--
			}
		}
	}
}

fn (ta &TextArea) colored_in() string {
	if ta.in_text.len > 0 {
		in_lines := ta.in_text.string().split('\n').map(highlight_input(it))
		joiner := '\n' + ta.more_prompt() + ' '
		return ta.prompt() + ' ' + in_lines.join(joiner)
	} else {
		return ta.prompt()
	}
}

fn (mut ta TextArea) switch_mode() (string, THC) {
	match ta.mode {
		.normal {
			ta.mode = .overwrite
			ta.color = .overwrite_prompt
			return 'switched to overwrite mode', THC.msg_warn
		}
		.overwrite {
			ta.mode = .normal
			ta.color = .normal_prompt
			return 'switched to normal mode', THC.msg_info
		}
	}
}

fn (ta &TextArea) cur_line() []rune {
	lines := ta.in_text.string().split('\n')
	return lines[lines.len - ta.line_offs - 1].runes()
}

fn (ta &TextArea) how_many_lines() int {
	return ta.in_text.string().split('\n').len
}

struct Prompt {
mut:
	color        THC
	mode         Mode
	indent_level int
}

fn (p &Prompt) prompt() string {
	return colors[p.color]('>>>')
}

fn (p &Prompt) more_prompt() string {
	return colors[p.color]('...')
}

struct BGInfo {
	frame_count &u64 = unsafe { nil }
mut:
	scrollbar_pos int
	footer        string
	msg_text      string
	msg_color     THC
	msg_hide_tick int
}

fn (mut bgi BGInfo) handle_msg() {
	if bgi.msg_text != '' && *bgi.frame_count >= bgi.msg_hide_tick {
		bgi.msg_text = ''
	}
}

fn (mut bgi BGInfo) show_msg(text string, color THC, time int) {
	f := time * frame_rate
	bgi.msg_hide_tick = if time > 0 { int(*bgi.frame_count) + f } else { -1 }
	bgi.msg_text = text
	bgi.msg_color = color
}

struct ProgList {
mut:
	user_prog []string
	u_p_linen int
}

struct ReplData {
mut:
	srepl_folder string
	files        map[string]string
}

struct WinSize {
mut:
	width  int
	height int
	new_w  &int = unsafe { nil }
	new_h  &int = unsafe { nil }
}
