local M = {}

local conceal_ns = vim.api.nvim_create_namespace("class_conceal")

M.setup_autocmd = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
    pattern = { "*.tsx" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_clear_namespace(bufnr, conceal_ns, 0, -1)

      local language_tree = vim.treesitter.get_parser(bufnr, "tsx")
      local syntax_tree = language_tree:parse()
      local root = syntax_tree[1]:root()

      local tsx_query = vim.treesitter.query.parse(
        "tsx",
        [[
          ((jsx_attribute
            (property_identifier) @attribute-name
            (string (string_fragment) @attribute-value))
            (#eq? @attribute-name "className")
            (#set! @attribute-value conceal "~"))
        ]]
      )

      for id, node, metadata in tsx_query:iter_matches(root, bufnr) do
        if id == 2 then -- This corresponds to the @attribute-value capture
          local start_row, start_col, end_row, end_col = node:range()
          vim.api.nvim_buf_set_extmark(bufnr, conceal_ns, start_row, start_col, {
            end_line = end_row,
            end_col = end_col,
            conceal = metadata.conceal,
          })
        end
      end
    end,
  })
end

return M
