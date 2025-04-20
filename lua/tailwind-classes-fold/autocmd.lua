local M = {}

local conceal_ns = vim.api.nvim_create_namespace("class_conceal")

M.setup_autocmd = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
    pattern = { "*.tsx", "*.jsx" }, -- Added .jsx support too
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_clear_namespace(bufnr, conceal_ns, 0, -1)

      -- Guard against TreeSitter not being available
      if not pcall(require, "nvim-treesitter") then
        print("TreeSitter not available")
        return
      end

      -- Make sure we can get a parser for the buffer
      local ok, language_tree = pcall(vim.treesitter.get_parser, bufnr, "tsx")
      if not ok or not language_tree then
        print("Unable to get TSX parser")
        return
      end

      -- Safely parse the syntax tree
      local syntax_tree = language_tree:parse()
      if not syntax_tree or #syntax_tree == 0 then
        print("Failed to parse syntax tree")
        return
      end

      local root = syntax_tree[1]:root()
      if not root then
        print("Root node not found")
        return
      end

      -- Fixed query - target the string content directly
      local tsx_query = vim.treesitter.query.parse(
        "tsx",
        [[
          (jsx_attribute
            (property_identifier) @attr_name
            (string (string_fragment) @string_value))
          (#eq? @attr_name "className")
        ]]
      )

      -- Error logging function
      local function log_error(msg, err)
        if err then
          print(string.format("Error in className concealer: %s - %s", msg, err))
        else
          print(string.format("Error in className concealer: %s", msg))
        end
      end

      -- Using pcall to catch any errors during query execution
      local query_ok, err = pcall(function()
        for id, node, metadata in tsx_query:iter_captures(root, bufnr) do
          local capture_name = tsx_query.captures[id]

          -- Only process string_value captures
          if capture_name == "string_value" then
            -- Get node range safely
            local range_ok, range_result = pcall(function()
              local start_row, start_col, end_row, end_col = node:range()
              return { start_row, start_col, end_row, end_col }
            end)

            if range_ok and range_result then
              local start_row, start_col, end_row, end_col = unpack(range_result)

              -- Set extmark for concealment
              vim.api.nvim_buf_set_extmark(bufnr, conceal_ns, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                conceal = "~",
              })
            else
              log_error("Failed to get node range")
            end
          end
        end
      end)

      if not query_ok then
        log_error("Query execution failed", err)
      end
    end,
  })
end

return M
