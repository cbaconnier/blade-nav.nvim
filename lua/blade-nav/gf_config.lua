local utils = require("blade-nav.utils")

local M = {}

local function goto_keys(keys)
  local root, lang = utils.get_root_and_lang()
  if not root then
    return
  end

  local ts = vim.treesitter
  local query_template = [[
    (array_element_initializer
      (string (string_content) @s (#eq? @s "%s"))
    )
  ]]
  local key_name = table.remove(keys, 1)
  local query_string = string.format(query_template, key_name)
  local query = ts.query.parse(lang, query_string)

  for _, matches, _ in query:iter_matches(root, 0) do
    for _, node in pairs(matches) do
      local start_row, start_col, _ = node:start()
      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      return
    end
  end
end

M.gf = function(config_name)
  local parts = {}
  for part in string.gmatch(config_name, "[^%.]+") do
    table.insert(parts, part)
  end

  if #parts == 0 then
    return
  end

  local file = "./config/" .. table.remove(parts, 1) .. ".php"
  vim.cmd("edit " .. file)
  goto_keys(parts)
end

return M
