local M = {}
local autocmd = require("tailwind-classes-fold.autocmd")

M.setup = function()
  autocmd.setup_autocmd()
end

M.toggle_conceal = function()
  local currConcealLevel = vim.wo.conceallevel
  vim.wo.conceallevel = (currConcealLevel > 0) and 0 or 2
end

return M
