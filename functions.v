module main

import os
import term

fn list() {
}

fn reset() {
}

fn show_help() {
	help_file := os.read_file('help.txt') or { panic('Missing Help File') }
	mut f_hf := help_file.replace('cpfix', cpfix)
	for k, v in commands {
		f_hf = f_hf.replace('-$k', v)
	}
	println(f_hf)
}

fn clear() {
	term.clear()
}

fn quit() {
	exit(0)
}

fn mode() {
}

fn file() {
}

fn path() {
}

fn save() {
}
