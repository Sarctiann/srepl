module main

import term
import term.ui as termui

enum Mode {
	normal
	overwrite
}

enum THC { // token highlighting color ...what do you thought?
	normal_prompt
	overwrite_prompt
	error
	ui_bg_elem
	ui_fg_text
}

enum Focus {
	prompt
	result
	prog_list
}

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
		THC.normal_prompt:    term.blue
		THC.overwrite_prompt: term.magenta
		THC.error:            term.red
	}
	custom_colors = {
		THC.ui_bg_elem: termui.Color{
			r: 90
			g: 90
			b: 90
		}
		THC.ui_fg_text: termui.Color{
			r: 255
			g: 255
			b: 255
		}
	}
	functions = {
		'list':            list
		commands['list']:  list
		'reset':           reset
		commands['reset']: reset
		'help':            show_help
		commands['help']:  show_help
		'clear':           clear
		commands['clear']: clear
		'quit':            quit
		commands['quit']:  quit
		'exit':            quit
		commands['exit']:  quit
		'mode':            mode
		commands['mode']:  mode
		'fixed':           fix_top
		commands['fixed']: fix_top
		'file':            file
		commands['file']:  file
		'path':            path
		commands['path']:  path
		'save':            save
		commands['save']:  save
	}
	frame_rate = 60
	indent     = '\t'
)
