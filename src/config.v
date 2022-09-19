module main

import os
import term
import term.ui as tui

const (
	cpfix    = ':' // command prefix
	commands = {
		'list':  'l' // show accumulated program
		'reset': 'r' // clean accumulated program
		'help':  'h' // show commands
		'clear': 'c' // clean the screen
		'quit':  'q' // quit repl
		'exit':  'x' // quit repl
		'mode':  'm' // alternate between normal and overwrite mode
		'fixed': 't' // fix prompt on top
		'file':  'f' // show current file name
		'path':  'p' // show current file path
		'save':  's' // save accumulated program
	}
	colors = {
		THC.normal_prompt:    &term.blue
		THC.overwrite_prompt: &term.magenta
		THC.msg_info:         &term.cyan
		THC.msg_warn:         &term.yellow
		THC.msg_error:        &term.bright_red
		THC.repl_fn:          &term.bright_green
		THC.keyword:          &term.bright_magenta
		THC.operator:         &term.red
		THC.parentesis:       &term.blue
		THC._type:            &term.bright_cyan
		THC.modifier:         &term.magenta
		THC.assign:           &term.bright_yellow
		THC.number:           &term.yellow
		THC._string:          &term.green
		THC.arrows:           &term.bright_yellow
	}
	custom_colors = {
		THC.ui_bg_elem: &tui.Color{
			r: 90
			g: 90
			b: 90
		}
	}
	functions = {
		'list':            &list
		commands['list']:  &list
		'reset':           &reset
		commands['reset']: &reset
		'help':            &show_help
		commands['help']:  &show_help
		'clear':           &clear
		commands['clear']: &clear
		'quit':            &quit
		commands['quit']:  &quit
		'exit':            &quit
		commands['exit']:  &quit
		'mode':            &mode
		commands['mode']:  &mode
		'fixed':           &fix_top
		commands['fixed']: &fix_top
		'file':            &file
		commands['file']:  &file
		'path':            &path
		commands['path']:  &path
		'save':            &save
		commands['save']:  &save
	}
	srepl_base_dir  = os.dir(os.args[0])
	debug           = '-debug' in os.args
	temp_dir        = os.temp_dir()
	help_file       = os.join_path(srepl_base_dir, 'src', 'help.txt')
	u_arrow         = '\u2227'
	d_arrow         = '\u2228'
	frame_rate      = 30
	indent          = '\t'
	word_separators = ' +-*/()[]{}.,\n\t'.runes() // ( CTRL + LEFT/RIGHT events )
	ml_flag_chars   = '[({,+-*/'.runes() // ( ENTER event )
	ml_clousures    = {
		`[`: `]`
		`{`: `}`
		`(`: `)`
	}
)

enum Mode {
	normal
	overwrite
}

enum THC { // token highlighting color ...what do you thought?
	normal_prompt
	overwrite_prompt
	msg_info
	msg_warn
	msg_error
	ui_bg_elem
	repl_fn
	keyword
	operator
	parentesis
	_type
	modifier
	assign
	number
	_string
	arrows
}

enum Focus {
	text_area
	prog_list
}

enum Action {
	read
	eval
	print
}

enum Displacement {
	char
	word
}
