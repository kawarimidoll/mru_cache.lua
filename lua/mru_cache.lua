M = {}

local opts = {
  cache_directory = '~/.cache/nvim/mru_cache',
  max_size = 20,
  ignore_filetype_list = {},
  ignore_regex_list = {}
}

M.setup = function(user_opts)
  user_opts = user_opts or {}
  for k, _ in pairs(opts) do
    if user_opts[k] then
      opts[k] = user_opts[k]
    end
  end

  vim.pretty_print(opts)
end

return M
