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

fn (mut ta TextArea) cursor_backward(i int) {
	if ta.in_offset < ta.in_text.len {
		ta.in_offset += i
	}
}

fn (mut ta TextArea) cursor_forward(i int) {
	if ta.in_offset > 0 {
		ta.in_offset -= i
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
	if ta.in_text.len > 0 {
		return ta.prompt.colored() + ' ' + highlight_input(ta.in_text.string())
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
	prompt       string
	color        THC
	mode         Mode
	indent_level int
}

fn (p &Prompt) colored() string {
	return colors[p.color](p.prompt)
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

// fn (mut r Repl) draw_prog_list() {
// 	if r.tui.window_width > 109 {
// 		r.tui.set_bg_color(custom_colors[.ui_bg_elem])
// 		r.side_bar_pos = r.tui.window_width - r.tui.window_width / 4 - 1
// 		r.tui.draw_line(r.side_bar_pos, 1, r.side_bar_pos, r.tui.window_height)
// 		r.tui.reset()
// 	}
// }

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

struct ViewDrawer {
	draw_text   fn (int, int, string)
	draw_line   fn (int, int, int, int)
	set_cur_pos fn (int, int)
mut:
	size      &WinSize
	text_area &TextArea
	prog_list &ProgList
	bg_info   &BGInfo
	out_text  []string
	in_linen  int = 1
	out_linen int = 1
}

fn (mut vd ViewDrawer) draw() {
	ta := vd.text_area
	bgi := vd.bg_info

	// draw bg_info.msg
	if bgi.msg_text != '' {
		msg := colors[bgi.msg_color](bgi.msg_text)
		vd.draw_text(1, vd.in_linen + 1, msg)
	}

	// set line position before join output lines
	vd.set_in_out_linen()

	// draw output
	output := vd.out_text.join('\n')
	vd.draw_text(1, vd.out_linen, output)

	// draw input text
	vd.draw_text(1, vd.in_linen, ta.colored_in())

	// draw bg ui and footer
	vd.draw_footer()

	// draw program list

	// set cursor
	in_index := ta.prompt.prompt.len + 2 + ta.in_text.len - ta.in_offset
	vd.set_cur_pos(in_index, vd.in_linen)
}

fn (vd &ViewDrawer) draw_footer() {
	// if vd.size.width > 99 && vd.size.height > 31 {
		// vd.tui.set_bg_color(custom_colors[.ui_bg_elem])
		// vd.tui.set_color(custom_colors[.ui_fg_text])
		y := vd.size.height
		mode := 'Mode: $vd.text_area.prompt.mode'
		// focus := 'Focus on: $vd.focus'
		focus := ''
		out_len := vd.out_text.len
		fixed := 'Fixed: $vd.text_area.fixed'
		lineno := 'Line No. in: $vd.in_linen out: $vd.out_linen'
		status := '$mode | $focus | $fixed | $lineno | $out_len'
		x := (vd.size.width - status.len) / 2
		// vd.draw_line(1, y, vd.size.width, y)
		vd.draw_text(x, y, status)
	// }
}

fn (mut vd ViewDrawer) set_in_out_linen() {
	if vd.text_area.fixed {
		vd.in_linen = 1
		vd.out_linen = 2
	} else {
		vd.in_linen =  vd.out_text.len + 1
	}
}

fn (mut vd ViewDrawer) puts(lines ...string) {
	for line in lines {
		vd.out_text << line.split('\n')
	}
}

struct WinSize {
mut:
	width  int
	height int
	new_w  &int
	new_h  &int
}

fn (mut ws WinSize) handle_change_size() bool {
	if ws.width != ws.new_w || ws.height != ws.new_h {
		ws.width = ws.new_w
		ws.height = ws.new_h
		return true
	}
	return false
}
