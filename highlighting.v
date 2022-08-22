module main

import regex as re

const (
	word_level_tokens = {
		'as':        THC.keyword
		'asm':       THC.keyword
		'assert':    THC.keyword
		'atomic':    THC.keyword
		'break':     THC.keyword
		'const':     THC.keyword
		'continue':  THC.keyword
		'defer':     THC.keyword
		'else':      THC.keyword
		'enum':      THC.keyword
		'false':     THC.keyword
		'for':       THC.keyword
		'fn':        THC.keyword
		'global':    THC.keyword
		'go':        THC.keyword
		'goto':      THC.keyword
		'if':        THC.keyword
		'import':    THC.keyword
		'in':        THC.keyword
		'interface': THC.keyword
		'is':        THC.keyword
		'match':     THC.keyword
		'module':    THC.keyword
		'nil':       THC.keyword
		'shared':    THC.keyword
		'lock':      THC.keyword
		'rlock':     THC.keyword
		'none':      THC.keyword
		'return':    THC.keyword
		'select':    THC.keyword
		'sizeof':    THC.keyword
		'isreftype': THC.keyword
		'likely':    THC.keyword
		'unlikely':  THC.keyword
		'offsetof':  THC.keyword
		'struct':    THC.keyword
		'true':      THC.keyword
		'type':      THC.keyword
		'typeof':    THC.keyword
		'dump':      THC.keyword
		'orelse':    THC.keyword
		'union':     THC.keyword
		'static':    THC.keyword
		'volatile':  THC.keyword
		'unsafe':    THC.keyword
		'it':        THC.modifier
		'a':         THC.modifier
		'b':         THC.modifier
		'mut':       THC.modifier
		'pub':       THC.modifier
		'any':       THC._type
		'bool':      THC._type
		'i8':        THC._type
		'i16':       THC._type
		'int':       THC._type
		'i64':       THC._type
		'u8':        THC._type
		'u16':       THC._type
		'u32':       THC._type
		'u64':       THC._type
		'f32':       THC._type
		'f64':       THC._type
		'string':    THC._type
		'rune':      THC._type
		'voidptr':   THC._type
	}
	// Order matters, by precedence last will result in higher priority
	char_level_tokens = {
		':=': THC.assign
		'=':  THC.assign
		'+':  THC.operator
		'-':  THC.operator
		'*':  THC.operator
		'/':  THC.operator
		'%':  THC.operator
		'!':  THC.operator
		'<':  THC.operator
		'>':  THC.operator
		'&':  THC.operator
		'|':  THC.operator
		'(':  THC.parentesis
		')':  THC.parentesis
		'{':  THC.parentesis
		'}':  THC.parentesis
	}
)

fn highlight_input(in_text string) string {
	if in_text.starts_with(':') {
		cmd := in_text.trim(cpfix).trim_space()
		if cmd in functions {
			return colors[.repl_fn](in_text)
		} else {
			return colors[.msg_warn](in_text)
		}
	} else {
		// First we need to replace the numbers and brackets in one go,
		// since these characters are used in the terminal colorization.
		mut re_number := re.regex_opt(r'([0-9\[\]\.])') or { panic(error) }
		first_epoch := re_number.replace_by_fn(in_text, colored_number)

		// Now we split the text in words to replace the word level tokens
		mut second_epoch := first_epoch.split(' ')
		second_epoch = second_epoch.map(if it in word_level_tokens {
			t := word_level_tokens[it]
			colors[t](it)
		} else {
			it
		})

		// Now we join them into a string and replace the char level tokens
		mut third_epoch := second_epoch.join(' ')
		for k, v in char_level_tokens {
			third_epoch = third_epoch.replace(k, colors[v](k))
		}

		// Finally we replace the literal strings
		mut re_string := re.regex_opt('(["\'].*["\'])') or { panic(error) }
		fourth_epoch := re_string.replace_by_fn(third_epoch, colored_string)

		return fourth_epoch
	}
}

fn colored_number(re re.RE, text string, start int, end int) string {
	g := re.get_group_by_id(text, 0)
	color := if g in ['[', ']'] { THC.parentesis } else { THC.number }
	return colors[color](g)
}

fn colored_string(re re.RE, text string, start int, end int) string {
	g := re.get_group_by_id(text, 0)
	return colors[._string](g)
}
