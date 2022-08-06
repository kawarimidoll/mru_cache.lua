M = {}

local opts = {
  cache_directory = '~/.cache/nvim/mru_cache',
  max_size = 20,
  ignore_filetype_list = {},
  ignore_regex_list = {}
}

--- Returns the path to cache.
---@param type string `mru` or `mrw`
M.cache_path = function(type)
  if type == 'mru' or type == 'mrw' then
    return string.gsub(opts.cache_directory, '/$', '') .. '/' .. type
  end
  error("type must be 'mru' or 'mrw'")
end

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
