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

local is_ignored = function(path)
  if vim.fn.filereadable(path) == 0 then
    return true
  end

  if vim.tbl_contains(opts.ignore_filetype_list, vim.bo.filetype) then
    return true
  end

  for _, regex in ipairs(opts.ignore_regex_list) do
    if string.match(path, regex) then
      return true
    end
  end

  return false
end

--- Appends given path to the cache file.
---@param path string file path to cache
---@param type string `mru` or `mrw`
M.append = function(path, type)
  if is_ignored(path) then
    return
  end

  local cache_path = M.cache_path(type)
  local limit = opts.max_size - 1
  local cmd = "sed -i '\\|^" .. path .. "$|d' " .. cache_path
      .. " && sed -i '" .. limit .. ",$d' " .. cache_path
      .. " && sed -i '1i" .. path .. "' " .. cache_path
  io.popen(cmd)
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

  local augroup = 'mru_cache'
  vim.api.nvim_create_augroup(augroup, {})
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = augroup, pattern = '*',
    callback = function(args)
      M.append(args.match, 'mru')
    end
  })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = augroup, pattern = '*',
    callback = function(args)
      M.append(args.match, 'mrw')
    end
  })
end

return M
