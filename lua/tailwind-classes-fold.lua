local module = require("tailwind-classes-fold.module")
local autocmd = require("tailwind-classes-fold.autocmd")  -- Require new module

local M = {}
M.config = {
  -- default config
  opt = "Hello!",
}

M.setup = function(args)
  -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
  -- you can also put some validation here for those.
  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  autocmd.setup_autocmd()  -- Setup autocmds
end
