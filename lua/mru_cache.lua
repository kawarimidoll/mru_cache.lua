M = {}

local opts = {
  cache_directory = '~/.cache/nvim/mru_cache',
  max_size = 100,
  ignore_filetype_list = {},
  ignore_regex_list = {}
}
local opt_types = {
  cache_directory = 'string',
  max_size = 'number',
  ignore_filetype_list = 'table',
  ignore_regex_list = 'table'
}

local expand = function(expr)
  ---@diagnostic disable-next-line: missing-parameter
  return vim.fn.expand(expr) or ''
end

--- Returns the path to cache.
---@param type string `mru` or `mrw`
M.cache_path = function(type)
  if type == 'mru' or type == 'mrw' then
    return string.gsub(opts.cache_directory, '/$', '') .. '/' .. type
  end
  error("type must be 'mru' or 'mrw'")
end

local is_called_from_autocmd = function()
  return vim.fn.bufnr() == tonumber(expand('<abuf>'))
end

local is_ignored = function(path)
  if vim.fn.filereadable(path) == 0 then
    return true
  end

  if is_called_from_autocmd() and
      vim.tbl_contains(opts.ignore_filetype_list, vim.bo.filetype) then
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
  path = expand(path)
  if string.sub(path, 1, 1) ~= '/' then
    path = vim.fn.getcwd() .. '/' .. path
  end

  if is_ignored(path) then
    return
  end

  local cache_path = M.cache_path(type)
  local cmd = "sed -i -e '\\|^" .. path .. "$|d' "
      .. "-e '" .. opts.max_size .. ",$d' "
      .. "-e '1i" .. path .. "' " .. cache_path
  io.popen(cmd)
end

local ensure_cache_files = function()
  opts.cache_directory = expand(opts.cache_directory)

  if vim.fn.isdirectory(opts.cache_directory) == 0 then
    if vim.fn.mkdir(opts.cache_directory, 'p') == 0 then
      error('Failed to make cache_directory: ' .. opts.cache_directory)
    end
  end

  local mru_file = M.cache_path('mru')
  if vim.fn.filewritable(mru_file) == 0 then
    if vim.fn.writefile({ '' }, mru_file, '') ~= 0 then
      error('Failed to make mru file: ' .. mru_file)
    end
  end

  local mrw_file = M.cache_path('mrw')
  if vim.fn.filewritable(mrw_file) == 0 then
    if vim.fn.writefile({ '' }, mrw_file, '') ~= 0 then
      error('Failed to make mrw file: ' .. mrw_file)
    end
  end
end

--- Setups mru_cache.
---
--- Default options:
--- {
---   cache_directory = '~/.cache/nvim/mru_cache',
---   max_size = 100,
---   ignore_filetype_list = {},
---   ignore_regex_list = {}
--- }
---@param user_opts? table user options
M.setup = function(user_opts)
  user_opts = user_opts or {}
  for k, _ in pairs(opts) do
    if user_opts[k] then
      if type(user_opts[k]) ~= opt_types[k] then
        error('Option ' .. k .. ' must be ' .. opt_types[k])
      end
      opts[k] = user_opts[k]
    end
  end
  if opts.max_size < 1 then
    error('Option max_size must be positive number')
  end

  ensure_cache_files()

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

  -- append current file to mru
  M.append(vim.api.nvim_buf_get_name(0), 'mru')
end

return M
