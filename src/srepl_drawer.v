module main

import term.ui
import arrays

struct ViewDrawer {
	draw_text    fn (int, int, string)   = unsafe { nil }
	draw_line    fn (int, int, int, int) = unsafe { nil }
	set_cur_pos  fn (int, int) = unsafe { nil }
	set_bg_color fn (ui.Color) = unsafe { nil }
	set_color    fn (ui.Color) = unsafe { nil }
mut:
	size       &WinSize  = unsafe { nil }
	text_area  &TextArea = unsafe { nil }
	prog_list  &ProgList = unsafe { nil }
	bg_info    &BGInfo   = unsafe { nil }
	focus      &Focus    = unsafe { nil }
	out_text   []string
	out_offset int
	in_linen   int = 1
	out_linen  int = 1
}

[inline]
fn (mut vd ViewDrawer) draw() {
	ta := vd.text_area
	bgi := vd.bg_info
	sbp := bgi.scrollbar_pos

	// set line position before join output lines
	vd.set_in_out_linen()

	// draw output
	for i, line in vd.out_text {
		if !line.contains('>>>') && !line.contains('...') && line.len > sbp {
			vd.out_text[i] = line[..sbp]
			vd.out_text.insert(i + 1, line[sbp..])
		}
	}
	output := match vd.text_area.fixed {
		false {
			// 2 = 1 for the footer + 1 for new prompt
			// TODO: improve for multiline prompt
			if vd.out_text.len > vd.size.height - 2 {
				start := vd.out_text.len - vd.size.height + 2 - vd.out_offset
				end := vd.out_text.len - vd.out_offset
				vd.out_text[start..end].join('\n')
			} else {
				vd.out_text.join('\n')
			}
		}
		// same as above
		true {
			if vd.out_text.len > vd.size.height - 2 {
				start := vd.out_offset
				end := vd.size.height - 2 + vd.out_offset
				vd.out_text[start..end].join('\n')
			} else {
				vd.out_text.join('\n')
			}
		}
	}
	vd.draw_text(1, vd.out_linen, output)

	// draw input text
	vd.draw_text(1, vd.in_linen, ta.colored_in())

	// draw bg_info.msg
	if bgi.msg_text != '' {
		msg := colors[bgi.msg_color](bgi.msg_text)
		vd.draw_text(1, vd.in_linen + 1, msg)
	}

	// draw program list
	// TODO: when "evaluation" is implemented

	// draw bg ui and footer
	vd.draw_ui_bg()
	vd.draw_ui_content()

	vd.set_cursor()
}

[inline]
fn (vd &ViewDrawer) draw_ui_bg() {
	if vd.size.width > 109 {
		sbp := vd.bg_info.scrollbar_pos
		vd.set_bg_color(*custom_colors[.ui_bg_elem])
		vd.draw_line(sbp, 1, sbp, vd.size.height)
		vd.draw_line(1, vd.size.height, vd.size.width, vd.size.height)
	}
}

[inline]
fn (vd &ViewDrawer) draw_ui_content() {
	if vd.size.width > 109 {
		sb_pos := vd.bg_info.scrollbar_pos
		// To debug format and print the data you need !!!
		status := if debug {
			// mode := 'mode: $vd.text_area.prompt.mode'
			// focus := 'focus: $vd.focus'
			// fixed := 'fixed: $vd.text_area.fixed'
			// lineno := 'in: $vd.in_linen out: $vd.out_linen'
			// sbp := 'sbp: $sb_pos'
			color_in_len := 'colored in len: $vd.text_area.colored_in().len'
			in_len := 'in len: $vd.text_area.in_text.len'
			lines_len := 'lines len: $vd.text_area.lines_len'
			in_offset := 'in offset: $vd.text_area.in_offset'
			out_len := 'out lines len: $vd.out_text.len'
			winsize := 'w:$vd.size.width,h:$vd.size.height'
			'$color_in_len | $in_len | $lines_len | $in_offset | $out_len | $winsize'
		} else {
			mode := 'mode: $vd.text_area.prompt.mode'
			focus := 'focus: $vd.focus'
			fixed := 'fixed: $vd.text_area.fixed'
			'$mode | $focus | $fixed'
		}
		x := (vd.size.width - status.len) / 2
		vd.draw_text(x, vd.size.height, status)
		// draw scroll indicators
		up, down := vd.can_do_scroll()
		if up {
			vd.draw_text(sb_pos, 1, colors[.arrows](u_arrow))
		} else {
			vd.draw_text(sb_pos, 1, u_arrow)
		}
		if down {
			vd.draw_text(sb_pos, vd.size.height - 1, colors[.arrows](d_arrow))
		} else {
			vd.draw_text(sb_pos, vd.size.height - 1, d_arrow)
		}
	}
}

fn (mut vd ViewDrawer) set_in_out_linen() {
	if vd.text_area.fixed {
		vd.in_linen = 1
		vd.out_linen = 2
	} else {
		if vd.out_text.len + 1 < vd.size.height {
			vd.in_linen = vd.out_text.len + 1
		} else {
			vd.in_linen = vd.size.height - 1
		}
	}
}

fn (mut vd ViewDrawer) puts(lines ...string) {
	for line in lines {
		if vd.text_area.fixed {
			vd.out_text.prepend(line.split('\n'))
		} else {
			vd.out_text << line.split('\n')
		}
	}
}

fn (mut vd ViewDrawer) handle_change_size() {
	mut ws := vd.size
	if ws.width != ws.new_w || ws.height != ws.new_h {
		ws.width = ws.new_w
		ws.height = ws.new_h
		if ws.width > 109 {
			vd.bg_info.scrollbar_pos = ws.width - ws.width / 4 - 1
		} else {
			vd.bg_info.scrollbar_pos = ws.width
		}
	}
}

fn (mut vd ViewDrawer) scroll_up() {
	up, _ := vd.can_do_scroll()
	if up {
		match vd.text_area.fixed {
			false { vd.out_offset += 1 }
			true { vd.out_offset -= 1 }
		}
	}
}

fn (mut vd ViewDrawer) scroll_down() {
	_, down := vd.can_do_scroll()
	if down {
		match vd.text_area.fixed {
			false { vd.out_offset -= 1 }
			true { vd.out_offset += 1 }
		}
	}
}

fn (vd &ViewDrawer) can_do_scroll() (bool, bool) {
	mut up := false
	mut down := false
	match vd.text_area.fixed {
		false {
			// 2 = 1 for the footer + 1 for new prompt
			if vd.out_text.len > vd.size.height - 2
				&& vd.out_offset < vd.out_text.len - vd.size.height + 2 {
				up = true
			}
			if vd.out_text.len > vd.size.height - 2 && vd.out_offset > 0 {
				down = true
			}
		}
		// same as above
		true {
			if vd.out_text.len > vd.size.height - 2 && vd.out_offset > 0 {
				up = true
			}
			if vd.out_text.len > vd.size.height - 2
				&& vd.out_offset < vd.out_text.len - vd.size.height + 2 {
				down = true
			}
		}
	}
	return up, down
}

[inline]
fn (mut vd ViewDrawer) set_cursor() {
	// ta.lines_len and ta.line_offs were set in Repl.on_press_enter
	mut ta := vd.text_area
	in_index := if ta.lines_len.len > 0 {
		lines_len_sum := arrays.sum(ta.lines_len)  or { panic(error) }
		5 + ta.in_text.len - ta.in_offset - lines_len_sum
	} else {
		5 + ta.in_text.len - ta.in_offset
	}
	vd.set_cur_pos(in_index, vd.in_linen + ta.line_offs)
}
