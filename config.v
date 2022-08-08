module main

import term

enum Mode {
	normal
	overwrite
}

enum THC { // token highlighting color ...what do you think?
	normal_prompt
	overwrite_prompt
	error
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
		'file':  'f' // show current file name
		'path':  'p' // show current file path
		'save':  's' // save accumulated program
	}
	colors = {
		THC.normal_prompt:    term.blue
		THC.overwrite_prompt: term.magenta
		THC.error:            term.red
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
