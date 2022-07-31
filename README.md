# Sarctiann V REPL

---

### The objective of this project is to create a new REPL for Vlang that meets the following features:

* [Colored Code Highlighting](#Colored-Code-Highlighting)
* [Overwrite Mode](#Overwrite-Mode)
* [Flexible Declarations](#Flexible-Declarations)
* [Suggestions](#Suggestions)
* [Edit Accumulated Code](#Edit-Accumulated-Code)
* [Save Resulting Module](#Save-Resulting-Module)

To achieve this, I rely on the current vrepl. Or at least its base. On the other hand, I rely on my python experience and its various REPL. More specifically BPython, it would be a really wonderfull if I can achive something similiar.
But in fact the idea can be grow. And I accept all the suggestions and help to achive a very powerfull and usefull tool.
Actually I belive it is possible to achieve a tool that is easy and entertaining to use. that at the same time can have a very good performance.

---

### Colored Code Highlighting

There is not much to say. Colors help, especially when starting a new language. But it's also useful for identifying typos or keywords among other things...
Also I intend to delegate some UI information to colors. for example the color of the prompt depending on the repl's mode (normal or overwrite).

### Overwrite Mode

This is one of the most important goals of this repl. As you know vlang have an especial operator for variable assignment ( `:=` ). And this variables are immutable by default. For that reason this is very inconvinient in some case when we want to make some tests. So in overwrite mode srepl should be capable to rewrite the variable assignment in its respective place.

### Flexible Declarations

This may sound similar to the above, but really this point is about providing the ability to declare constants, structures, etc. anywhere in the REPL session. the goal is to decrease the need to use :reset and start over. Sometimes these quick tests are not so simple to just redo.

### Suggestions

Of course we need help finding the right function inside a module. or that strange name we gave to the method of our struct. At this point I have no idea how I should approach this challenge, but I know what I hope to achieve ( bpython 😉 ).

### Edit Accumulated Code

well, the idea here is to open the current backlog in some installed text editor (vi, vim, nano, mcedit... why not vscode) anyway, after closing it, we should be in our REPL like before we left. But of course, keeping the changes we made.

### Save Resulting Module

Finally, ...for now, we will be able to save this accumulated program, you may want to continue later.

---

## Intended Lib Stack:

* `os`
* `os.cmdline`
* `readline`
* `term`
* `term.ui`

---

## TODO:

😦 all ...help me 😅
