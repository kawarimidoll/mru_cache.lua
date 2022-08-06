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

  -- ensure cache files
  if vim.fn.isdirectory(opts.cache_directory) == 0 then
    vim.fn.mkdir(opts.cache_director, 'p')
  end
  if vim.fn.filewritable(M.cache_path('mru')) == 0 then
    io.popen('echo > ' .. M.cache_path('mru'))
  end
  if vim.fn.filewritable(M.cache_path('mrw')) == 0 then
    io.popen('echo > ' .. M.cache_path('mrw'))
  end

  vim.pretty_print(opts)
end

return M
