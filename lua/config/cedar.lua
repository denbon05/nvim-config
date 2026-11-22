-- Cedar files. Cedar is a language for access rules ("who may do what").
-- Neovim already knows .cedar files; Dogwood policies (.dw) and Cedar schemas
-- (.cedarschema) use the same syntax, so they get the same file type. Then
-- syntax/cedar.lua colors all three, and gc comments lines out with //.
vim.filetype.add({
  extension = {
    dw = "cedar",
    cedarschema = "cedar",
  },
})
