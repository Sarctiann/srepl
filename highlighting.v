module main

const tokens = {
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
	// FIXME
	'+':         THC.operator
	'-':         THC.operator
	'*':         THC.operator
	'/':         THC.operator
	'%':         THC.operator
	'<':         THC.operator
	'>':         THC.operator
	'&':         THC.operator
	'|':         THC.operator
	'!':         THC.operator
	'(':         THC.parentesis
	')':         THC.parentesis
	'[':         THC.parentesis
	']':         THC.parentesis
	'{':         THC.parentesis
	'}':         THC.parentesis
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
	'it':        THC.modifier
	'a':         THC.modifier
	'b':         THC.modifier
	'mut':       THC.modifier
	'pub':       THC.modifier
	':=':        THC.assign
	'=':         THC.assign
	'+=':        THC.assign
	'-=':        THC.assign
	'*=':        THC.assign
	'/=':        THC.assign
}

fn highlight_input(in_text string) string {
	if in_text.len > 0 {
		if in_text.starts_with(':') {
			return colors[.repl_fn](in_text)
		} else {
			// FIXME
			mut fields := in_text.fields()
			fields = fields.map(if it in tokens {
				t := tokens[it]
				colors[t](it)
			} else {
				it
			})
			return fields.join(' ')
		}
	} else {
		return ''
	}
}
