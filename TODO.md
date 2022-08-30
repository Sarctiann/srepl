# QUICK TASK GUIDE

### IN PROGRESS:

* re-implement data structure

### IMPLEMENTATION GOALS:

* 3 drawers max (tui.draw_sth...)
* redraw only if the size changes
* all customizable values should be in config.v
* separate functionality in separate files

---

### EXPECTED DATA STRUCTURE:

```js 
// STRUCTS

Repl: {
    // general
    tui:          &tui.Context,
    size:         WinSize,
    focus:        Focus,
    // views (drawers)
    text_area:    ScrollableTA,
    bg_info:      BGInfo,
    prog_list:    ProgList,
    // helpers
    should_eval:  bool,
    should_print: bool
},

WinSize: {
    width:  int,
    height: int,
},

ScrollableTA: {
    prompt:    Prompt,
    fixed:     bool,
    in_text:   []rune,
    in_offset: int,
    in_linen:  int,
    in_hist:   []string,
    out_text:  []string,
    out_linen: int
},

Prompt: {
    prompt:       string,
    color:        THC,
    mode:         Mode,
    indent_level: int
}

BGInfo: {
    footer:        string,
    scrollbar_pos: int,
    msg_text:      string,
    msg_color:     TCH,
    msg_hide_tick: int
},

ProgList: {
    user_prog: []string,
    u_p_linen: int
}

ReplData: {
    srepl_folder: string,
    files:        map[string]string
}

// ENUMS

Focus [
    .text_area,
    .prog_list
]

Mode [
    .normal,
    .overwrite
]

```