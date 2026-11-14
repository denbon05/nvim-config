# Cheatsheet

Keys are tapped one after another, except `Ctrl`, `Shift` and `Option`, which are held. Everything is for Normal mode unless it says otherwise. `Space` `?` opens this file, `q` closes it.

Keys marked with * are my own shortcuts from this config. The rest are built into Neovim.

## Open a file

```
Space f *        Find a file by part of its name
Space Shift-f *  The same, including files git ignores (.env, docs/steps)
Space / *        Search for text in every file of the project
Space b *        Pick one of the open files
Space g *        List the files changed since the last commit, with the diff
                 on the right
Space e *        Show or hide the file list on the left
:e path + Tab    Open a file by its path
:e               Read the current file from disk again
:e!              The same, and throw away my unsaved changes
```

Inside a search window: type to narrow the list, `Ctrl-j` / `Ctrl-k` or the arrows move the selection, `Enter` opens, `Esc` closes. The right side is a preview:

```
Shift-Down / Shift-Up                Scroll the preview by a page
Option-Shift-Down / Option-Shift-Up  Scroll the preview by a line
F4                                   Hide or show the preview
```

In the `Space` `g` list only:

```
Left / Right  Stage / unstage the selected file
Ctrl-x        Throw away the file's changes (deletes a new file). It asks
              first
```

`:FzfLua` lists every search it has. `:FzfLua keymaps` searches all shortcuts.

## Review changes

The line numbers of added, changed and deleted lines are colored. A staged change counts as reviewed and is no longer marked.

```
Space o *          Show or hide the changes inside every open file: deleted
                   lines appear above, added lines get a background
Ctrl-n / Ctrl-p *  Jump to the next / previous change in the file and scroll
                   so the whole change is visible
gh gh              Stage the change under the cursor
```

## Move through code

The lines pinned at the top of the window are the class and function the cursor is in, shown when their first line has scrolled away. The bottom right corner shows the cursor's line and column, then where the window is in the file: `Top`, `Bot`, `All` (the whole file fits) or a percentage.

```
gd                  Go to the definition of the name, shown mid-screen
Ctrl-o / Ctrl-i     Jump back / forward through the places I jumped from
[m / ]m             Jump up to the def or class line the cursor is in / down
                    to the next one
grr                 List every place the name is used
Ctrl-j, then Enter  Go down into that list and jump to the selected place
]q / [q             Jump to the next / previous place of the list without
                    entering it
:cclose             Close the list. :copen shows it again
K                   Show the description of the name. Moving the cursor closes
                    it
K K                 Enter the description window to copy from it. q closes it
/text + Enter       Jump to text in this file. n next match, N previous
?text + Enter       The same, searching upwards
*                   Find the word under the cursor
Esc *               Clear the search highlights
} / {               Jump to the next / previous empty line
Ctrl-e / Ctrl-y     Scroll the text one line down / up. The cursor stays on
                    its line. 5 Ctrl-e scrolls five lines
Ctrl-d / Ctrl-u     Scroll half a screen down / up
Ctrl-f / Ctrl-b     Scroll a whole screen down / up
gg / G              Start / end of the file
5j / 5k             Five lines down / up. The left margin shows the number
f + character       Jump to that character on this line
```

## Errors and warnings

```
]d / [d   Next / previous problem in the file
Ctrl-w d  Show the full text of the problem
gra       Offer fixes for the problem
```

## Edit

```
i / A / o       Type before the cursor / at the end of the line / on a new
                line
Esc             Back to Normal mode
ciw / ci"       Replace the word / the text inside quotes
dd / dap        Delete the line / the paragraph
dt + character  Delete up to that character
.               Repeat the last change
u / Ctrl-r      Undo / redo
grn             Rename the name everywhere
gcc             Comment the line out, or back in
Space d *       Add or remove a breakpoint() line (debugger; in JS and TS)
```

Completion in Insert mode: the menu opens by itself, `Ctrl-n` / `Ctrl-p` choose, `Ctrl-y` accepts.

## Copy

```
V / v        Select lines / characters
y            Copy the selection
p            Paste
Space y p *  Copy the full path of the current file
```

Everything copied with `y` or deleted with `dd` and `x` lands in the macOS clipboard.

## Windows

```
Space v *             Split the window side by side
:split                Split the window top and bottom
Ctrl-h / j / k / l *  Move to the window on the left / below / above / on the
                      right
Ctrl-w q              Close the current window. Release Ctrl before q
Ctrl-w o              Keep only the current window
```

## Save and quit

```
Space w * or :w  Save
:wa              Save every file
:wqa             Save every file and quit
:qa              Quit
:qa!             Quit and throw away unsaved changes
:restart         Restart Neovim, to pick up a config change
```

`:wq` and `:q` close only the current window. With several windows open, quit with `:wqa` or `:qa`.

## Debug

Put `breakpoint()` on a line with `Space` `d` and run the program in a terminal. It stops there with a `(Pdb)` prompt:

```
n       Run the next line
s       Step into the function
c       Continue to the next breakpoint
p name  Print a variable
l       Show the code around
q       Quit
```

## Git in the terminal

```
git diff                             Show every change. j / k scroll, n / N
                                     jump between files, q quits
git -c delta.side-by-side=true diff  The same, old and new side by side
git diff path                        Show the changes of one file
git add -p                           Stage piece by piece: y takes a piece, n
                                     skips it
```

## When lost

`Esc`, then `u` if something broke. Completely stuck: `Esc`, `:qa!`, `Enter`, and start Neovim again. What was saved stays on disk.
