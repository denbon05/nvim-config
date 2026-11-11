# Cheatsheet

Keys are tapped one after another, except `Ctrl`, `Shift` and `Option`, which are held. Everything is for Normal mode unless it says otherwise. `Space` `?` opens this file.

Keys marked with * are my own shortcuts from this config. The rest are built into Neovim.

## Open a file

| Keys | Action |
|---|---|
| `Space` `f` * | Find a file by part of its name |
| `Space` `/` * | Search for text in every file of the project |
| `Space` `b` * | Pick one of the open files |
| `Space` `g` * | List the files changed since the last commit, with their diff |
| `Space` `e` * | Show or hide the file list on the left |
| `:e path` + `Tab` | Open a file by its path |
| `:e` | Read the current file from disk again |
| `:e!` | The same, and throw away my unsaved changes |

Inside a search window: type to narrow the list, `Ctrl-j` / `Ctrl-k` or the arrows move the selection, `Enter` opens, `Esc` closes. The right side is a preview:

| Keys | Action |
|---|---|
| `Shift-Down` / `Shift-Up` | Scroll the preview by a page |
| `Option-Shift-Down` / `Option-Shift-Up` | Scroll the preview by a line |
| `F4` | Hide or show the preview |

`:FzfLua` lists every search it has. `:FzfLua keymaps` searches all shortcuts.

## Move through code

| Keys | Action |
|---|---|
| `gd` | Go to the definition of the name under the cursor |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward through the places I jumped from |
| `grr` | List every place the name is used |
| `K` | Show the description of the name. Moving the cursor closes it |
| `K` `K` | Enter the description window to copy from it. `q` closes it |
| `/text` + `Enter` | Jump to text in this file. `n` next match, `N` previous |
| `?text` + `Enter` | The same, searching upwards |
| `*` | Find the word under the cursor |
| `Esc` * | Clear the search highlights |
| `}` / `{` | Jump to the next / previous empty line |
| `gg` / `G` | Start / end of the file |
| `5j` / `5k` | Five lines down / up. The left margin shows the number |
| `f` + character | Jump to that character on this line |

## Errors and warnings

| Keys | Action |
|---|---|
| `]d` / `[d` | Next / previous problem in the file |
| `Ctrl-w` `d` | Show the full text of the problem |
| `gra` | Offer fixes for the problem |

## Edit

| Keys | Action |
|---|---|
| `i` / `A` / `o` | Type before the cursor / at the end of the line / on a new line |
| `Esc` | Back to Normal mode |
| `ciw` / `ci"` | Replace the word / the text inside quotes |
| `dd` / `dap` | Delete the line / the paragraph |
| `dt` + character | Delete up to that character |
| `.` | Repeat the last change |
| `u` / `Ctrl-r` | Undo / redo |
| `grn` | Rename the name everywhere |
| `gcc` | Comment the line out, or back in |
| `Space` `d` * | Add or remove a `breakpoint()` line (`debugger;` in JS and TS) |

Completion in Insert mode: the menu opens by itself, `Ctrl-n` / `Ctrl-p` choose, `Ctrl-y` accepts.

## Copy

| Keys | Action |
|---|---|
| `V` / `v` | Select lines / characters |
| `y` | Copy the selection |
| `p` | Paste |
| `Space` `y` `p` * | Copy the full path of the current file |

Everything copied with `y` or deleted with `dd` and `x` lands in the macOS clipboard.

## Windows

| Keys | Action |
|---|---|
| `Space` `v` * | Split the window side by side |
| `:split` | Split the window top and bottom |
| `Ctrl-h` / `j` / `k` / `l` * | Move to the window on the left / below / above / on the right |
| `Ctrl-w` `q` | Close the current window |
| `Ctrl-w` `o` | Keep only the current window |

## Save and quit

| Keys | Action |
|---|---|
| `Space` `w` * or `:w` | Save |
| `:wa` | Save every file |
| `:wqa` | Save every file and quit |
| `:qa` | Quit |
| `:qa!` | Quit and throw away unsaved changes |
| `:restart` | Restart Neovim, to pick up a config change |

`:wq` and `:q` close only the current window. With several windows open, quit with `:wqa` or `:qa`.

## Debug

Put `breakpoint()` on a line with `Space` `d` and run the program in a terminal. It stops there with a `(Pdb)` prompt:

| Command | Action |
|---|---|
| `n` | Run the next line |
| `s` | Step into the function |
| `c` | Continue to the next breakpoint |
| `p name` | Print a variable |
| `l` | Show the code around |
| `q` | Quit |

## Git in the terminal

| Command | Action |
|---|---|
| `git diff` | Show every change. `j` / `k` scroll, `n` / `N` jump between files, `q` quits |
| `git diff path` | Show the changes of one file |
| `git add -p` | Stage piece by piece: `y` takes a piece, `n` skips it |

## When lost

`Esc`, then `u` if something broke. Completely stuck: `Esc`, `:qa!`, `Enter`, and start Neovim again. What was saved stays on disk.
