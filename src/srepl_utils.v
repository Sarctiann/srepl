module main

struct TextArea {
mut:
	prompt    &Prompt
	fixed     bool
	in_text   []rune
	in_offset int
	in_hist   []string
}

fn (mut ta TextArea) input_insert(s string) {
	ta.in_text.insert(ta.in_text.len - ta.in_offset, s.runes())
}

fn (mut ta TextArea) cursor_backward(d Displacement) {
	match d {
		.char {
			if ta.in_offset < ta.in_text.len {
				ta.in_offset += 1
			}
		}
		.word {
			if ta.in_offset < ta.in_text.len {
				ta.in_offset += 1
			}
			for ta.in_offset < ta.in_text.len {
				if ta.in_text[ta.in_text.len - 1 - ta.in_offset] in word_separators {
					ta.in_offset += 1
				} else {
					break
				}
			}
			for ta.in_offset < ta.in_text.len {
				if ta.in_text[ta.in_text.len - 1 - ta.in_offset] !in word_separators {
					ta.in_offset += 1
				} else {
					break
				}
			}
		}
	}
}

fn (mut ta TextArea) cursor_forward(d Displacement) {
	match d {
		.char {
			if ta.in_offset > 0 {
				ta.in_offset -= 1
			}
		}
		.word {
			if ta.in_offset > 0 {
				ta.in_offset -= 1
			}
			for ta.in_offset > 0 {
				if ta.in_text[ta.in_text.len - ta.in_offset] in word_separators {
					ta.in_offset -= 1
				} else {
					break
				}
			}
			for ta.in_offset > 0 {
				if ta.in_text[ta.in_text.len - ta.in_offset] !in word_separators {
					ta.in_offset -= 1
				} else {
					break
				}
			}
		}
	}
}

fn (mut ta TextArea) input_remove() {
	if ta.in_text.len - ta.in_offset > 0 {
		ta.in_text.delete(ta.in_text.len - ta.in_offset - 1)
	}
}

fn (mut ta TextArea) input_delete() {
	if ta.in_offset > 0 {
		ta.in_text.delete(ta.in_text.len - ta.in_offset)
		ta.in_offset--
	}
}

fn (ta &TextArea) colored_in() string {
	// TODO: handle multiline prompt
	if ta.in_text.len > 0 {
		in_lines := ta.in_text.string().split('\n').map(highlight_input(it))
		glue := '\n' + ta.prompt.more_colored() + ' '
		return ta.prompt.colored() + ' ' + in_lines.join(glue)
	} else {
		return ta.prompt.colored()
	}
}

fn (mut ta TextArea) switch_mode() (string, THC) {
	match ta.prompt.mode {
		.normal {
			ta.prompt.mode = .overwrite
			ta.prompt.color = .overwrite_prompt
			return 'switched to overwrite mode', THC.msg_warn
		}
		.overwrite {
			ta.prompt.mode = .normal
			ta.prompt.color = .normal_prompt
			return 'switched to normal mode', THC.msg_info
		}
	}
}

struct Prompt {
mut:
	color        THC
	mode         Mode
	indent_level int
}

fn (p &Prompt) colored() string {
	return colors[p.color]('>>>')
}

fn (p &Prompt) more_colored() string {
	return colors[p.color]('...')
}

struct BGInfo {
	frame_count &u64
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
	new_w  &int
	new_h  &int
}
