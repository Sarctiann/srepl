module main

struct TextArea {
	Prompt
mut:
	fixed     bool
	in_text   [][]rune = [][]rune{len: 1, init: []rune{}}
	in_offset int
	line_offs int
	in_hist   []string
}

fn (mut ta TextArea) input_insert(s string) {
	ta.in_text[ta.cur_line_idx()]
		.insert(ta.cur_line().len - ta.in_offset, s.runes())
}

fn (mut ta TextArea) should_eval_else_new_line() bool {
	// TODO: handle new based on the cursor position
	last_rune := ta.in_text[ta.cur_line_idx()].filter(it != ` `).last()
	mut ml_flags := []rune{}
	for line in ta.in_text {
		for r in line {
			if r in ml_clousures {
				ml_flags.prepend(ml_clousures[r])
			}
		}
	}
	for line in ta.in_text {
		for r in line {
			if r in ml_flags {
				ml_flags.delete(ml_flags.index(r))
				if r == last_rune && ta.indent_level > 0 {
					ta.indent_level -= 1
				}
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
		temp := ta.cur_line()[ta.cur_line().len - ta.in_offset..]
		ta.in_text << []rune{}
		ta.in_text[ta.cur_line_idx()] << temp
		ta.input_insert('\t'.repeat(ta.indent_level))
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
	how_many_lines := ta.in_text.len
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
			if ta.cur_line().len - ta.in_offset > 0 {
				idx := ta.cur_line().len - ta.in_offset - 1
				if ta.cur_line()[idx] == `\t` && ta.indent_level > 0 {
					ta.indent_level -= 1
				}
				ta.in_text[ta.cur_line_idx()].delete(idx)
			} else if ta.in_text.len > 1 && ta.line_offs < ta.in_text.len - 1 {
				ta.in_text[ta.cur_line_idx() - 1] << ta.cur_line()
				ta.in_text.delete(ta.cur_line_idx())
			}
		}
		.sup {
			// FIXME
			if ta.in_offset > 0 {
				idx := ta.in_text.len - ta.in_offset
				if ta.in_text[ta.line_offs][idx] == `\t` && ta.indent_level > 0 {
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
		in_lines := ta.in_text.map(highlight_input(it.string()))
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
	return ta.in_text[ta.cur_line_idx()]
}

fn (ta &TextArea) cur_line_idx() int {
	return ta.in_text.len - 1 - ta.line_offs
}

fn (ta &TextArea) raw_string() string {
	return ta.in_text.map(it.string()).join('\n')
}

fn (mut ta TextArea) clear() {
	ta.in_text = [][]rune{len: 1, init: []rune{}}
}

struct Prompt {
mut:
	color        THC
	mode         Mode
	indent_level int
}

fn (p &Prompt) prompt() string {
	return colors[(p.color)]('>>>')
}

fn (p &Prompt) more_prompt() string {
	return colors[(p.color)]('...')
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
