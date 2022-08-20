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
	in_txt       []rune
	index        int
	in_lineno    int = 1
	result       string
	out_lineno   int  = 2
	should_print bool = true
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
	msg_hide_tick int
}
