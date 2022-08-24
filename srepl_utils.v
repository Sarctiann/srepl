module main

struct Prompt {
mut:
	prompt       string = '>>>'
	color        fn (string) string
	indent_level int
}

fn (p &Prompt) show() string {
	return p.color(p.prompt)
}

fn (p &Prompt) offset() int {
	return p.prompt.len + 2
}

struct DataIO {
mut:
	in_txt     []rune
	in_offset  int // in_offset must be always <= 0
	in_lineno  int = 1
	result     string
	out_lineno int = 2
}

fn (d DataIO) colored_in() string {
	if d.in_txt.len > 0 {
		return highlight_input(d.in_txt.string())
	} else {
		return ''
	}
}

struct DataBuff {
mut:
	history     []string
	hist_lineno int = 1
	prog_list   []string
	prog_lineno int = 1
}

struct FilesIO {
mut:
	srepl_folder string
	files        map[string]string
}

struct Msg {
mut:
	content       string
	color         THC
	msg_hide_tick int
}
