module main

import term.ui { Color }

struct ViewDrawer {
	draw_text    fn (int, int, string)
	draw_line    fn (int, int, int, int)
	set_cur_pos  fn (int, int)
	set_bg_color fn (c Color)
	set_color    fn (c Color)
mut:
	size      &WinSize
	text_area &TextArea
	prog_list &ProgList
	bg_info   &BGInfo
	focus     &Focus
	out_text  []string
	in_linen  int = 1
	out_linen int = 1
}

fn (mut vd ViewDrawer) draw() {
	ta := vd.text_area
	bgi := vd.bg_info
	sbp := bgi.scrollbar_pos

	// draw bg_info.msg
	if bgi.msg_text != '' {
		msg := colors[bgi.msg_color](bgi.msg_text)
		vd.draw_text(1, vd.in_linen + 1, msg)
	}

	// set line position before join output lines
	vd.set_in_out_linen()

	// draw output
	for i, line in vd.out_text {
		if line.len > sbp {
			vd.out_text[i] = line[..sbp]
			vd.out_text.insert(i + 1, line[sbp..])
		}
	}
	output := vd.out_text.join('\n')
	vd.draw_text(1, vd.out_linen, output)

	// draw input text
	vd.draw_text(1, vd.in_linen, ta.colored_in())

	// draw bg ui and footer
	vd.draw_ui_bg()
	vd.draw_ui_content()

	// draw program list

	// set cursor
	in_index := ta.prompt.prompt.len + 2 + ta.in_text.len - ta.in_offset
	vd.set_cur_pos(in_index, vd.in_linen)
}

fn (vd &ViewDrawer) draw_ui_bg() {
	if vd.size.width > 109 {
		sbp := vd.bg_info.scrollbar_pos
		vd.set_bg_color(*custom_colors[.ui_bg_elem])
		vd.set_color(*custom_colors[.ui_fg_text])
		vd.draw_line(sbp, 1, sbp, vd.size.height)
		vd.draw_line(1, vd.size.height, vd.size.width, vd.size.height)
	}
}

fn (vd &ViewDrawer) draw_ui_content() {
	if vd.size.width > 109 {
		mode := 'mode: $vd.text_area.prompt.mode'
		focus := 'focus: $vd.focus'
		fixed := 'fixed: $vd.text_area.fixed'
		lineno := 'in: $vd.in_linen out: $vd.out_linen'
		out_len := 'buff lines: $vd.out_text.len'
		sbp := 'sbp: $vd.bg_info.scrollbar_pos'
		in_len := 'in len: $vd.text_area.colored_in().len'
		status := '$mode | $focus | $fixed | $lineno | $out_len | $sbp | $in_len'
		x := (vd.size.width - status.len) / 2
		vd.draw_text(x, vd.size.height, status)
	}
}

fn (mut vd ViewDrawer) set_in_out_linen() {
	if vd.text_area.fixed {
		vd.in_linen = 1
		vd.out_linen = 2
	} else {
		vd.in_linen = vd.out_text.len + 1
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
