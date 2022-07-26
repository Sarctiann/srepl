module main

const (
	cpfix    = ':' // command prefix
	commands = {
		'list':  's' // show accumulated program
		'reset': 'r' // clean accumulated program
		'help':  'h' // show commands
		'clear': 'c' // clean the screen
		'quit':  'q' // quit repl
		'mode':  'm' // alternate between normal and overwrite mode
		'file':  'f' // show current file name
		'path':  'p' // show current file path
		'save':  's' // save accumulated program
	}
)
