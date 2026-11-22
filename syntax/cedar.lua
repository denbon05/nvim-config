-- Colors for Cedar files: policies (.cedar), Dogwood policies (.dw, Cedar
-- plus rules about earlier requests) and Cedar schemas (.cedarschema).
-- lua/config/cedar.lua gives all three the file type "cedar", and Neovim then
-- runs this file by itself for each such file.
--
-- There is no tree-sitter parser that knows Dogwood, so this file uses the
-- older way: each rule says "text that looks like this gets this color group".
-- The groups at the bottom (Keyword, String, Comment...) are the ones every
-- language uses, so the color scheme paints them the same way as in Python.

-- Neovim may run a syntax file twice for one file. Stop if it already ran.
if vim.b.current_syntax then
  return
end

-- Cedar tells upper and lower case apart: "Permit" is not a keyword.
vim.cmd("syntax case match")

-- Words that start a policy, and the conditions after it.
vim.cmd("syntax keyword cedarEffect permit forbid")
vim.cmd("syntax keyword cedarCondition when unless if then else")

-- The four things every request carries: who asks, for what action, on
-- which resource, and the extra facts (context).
vim.cmd("syntax keyword cedarScope principal action resource context")

-- Operators written as words: "context has x", "a in b", "s like \"*x\"".
vim.cmd("syntax keyword cedarWordOperator has in is like")
vim.cmd("syntax keyword cedarBoolean true false")

-- Dogwood's words for the past: "formerly within 1h <request>" means "a
-- request like this one happened in the last hour". "request" and "response"
-- name the kind of event in the session's history.
vim.cmd("syntax keyword cedarTemporal temporal formerly previous since within exists")
vim.cmd("syntax keyword cedarEventKind request response")

-- Words of a schema: they declare the namespace, the types and the actions.
vim.cmd("syntax keyword cedarDeclaration namespace type entity appliesTo")
vim.cmd("syntax keyword cedarType String Long Bool Boolean Set Record Entity")

-- A name that starts with a capital letter is a type or a namespace in
-- Cedar: OAuthUser, WriteInput, Tel.
vim.cmd([[syntax match cedarPath "\<\u\w*\>"]])

-- A name in front of "::", such as Tel and Action in Tel::Action::"Prepare".
vim.cmd([[syntax match cedarPath "\<\h\w*\ze::"]])

-- A name in front of "(", such as contains in .contains("x") or Dogwood's
-- count_within(...). Keywords win over this rule, so "permit (" stays a
-- keyword.
vim.cmd([[syntax match cedarFunction "\<\h\w*\ze\s*("]])

-- A name in front of a single ":", such as a field of a schema record
-- (pending_id: String) or of a Dogwood request pattern.
vim.cmd([[syntax match cedarField "\<\h\w*\ze\s*:\%(:\)\@!"]])

-- Whole numbers, and Dogwood's durations: 30s, 15m, 1h, 24h, 7d.
vim.cmd([[syntax match cedarNumber "\<\d\+\%(ms\|[smhd]\)\=\>"]])

-- Text in double quotes. A \" inside does not end it.
vim.cmd([[syntax region cedarString start=+"+ skip=+\\"+ end=+"+]])

-- Symbols: && || ! == != < <= > >= + - *.
vim.cmd([[syntax match cedarOperator "&&\|||\|!=\=\|==\|[<>]=\=\|[-+*]"]])

-- A comment runs from // to the end of the line. A "//" inside a string is
-- not a comment, because the string starts first.
vim.cmd([[syntax match cedarComment "//.*$" contains=@Spell]])

-- Give each group above the color of a group the color scheme knows.
-- "default" lets a color scheme set its own colors for these groups instead.
vim.cmd("highlight default link cedarEffect Keyword")
vim.cmd("highlight default link cedarCondition Conditional")
vim.cmd("highlight default link cedarScope Identifier")
vim.cmd("highlight default link cedarWordOperator Keyword")
vim.cmd("highlight default link cedarBoolean Boolean")
vim.cmd("highlight default link cedarTemporal Keyword")
vim.cmd("highlight default link cedarEventKind Special")
vim.cmd("highlight default link cedarDeclaration Keyword")
vim.cmd("highlight default link cedarType Type")
vim.cmd("highlight default link cedarPath Type")
vim.cmd("highlight default link cedarFunction Function")
vim.cmd("highlight default link cedarField Identifier")
vim.cmd("highlight default link cedarNumber Number")
vim.cmd("highlight default link cedarString String")
vim.cmd("highlight default link cedarOperator Operator")
vim.cmd("highlight default link cedarComment Comment")

-- Tell Neovim this file ran, for the check at the top.
vim.b.current_syntax = "cedar"
