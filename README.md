# mru_cache.lua

A small MRU (most resent used) / MRW (most resent written) cache system for Neovim

## Requirements

GNU `sed`

## Installation

Install `kawarimidoll/mru_cache.lua` by your favorite plugin manager.

## Usage

Call `setup()` to enable autocmd to cache.

```lua
require('mru_cache').setup()
```

### Options

mru_cache can be configured by options that are passed to `setup()`.

- `cache_directory`
  - Directory path to save cache files.
  - type: string
  - default: `'~/.cache/nvim/mru_cache'`
- `max_size`
  - Max size of cache files.
  - type: number
  - default: 100
- `ignore_filetype_list`
  - List of ignored filetypes to cache.
  - type: table of string
  - default: `{}`
- `ignore_regex_list`
  - List of ignored regex to cache.
  - type: table of string
  - default: `{}`

example:
```lua
require('mru_cache').setup({
  max_size = 1000,
  ignore_filetype_list = { "help" },
  ignore_regex_list = { "%.git/" }
})
```

## API

- `setup`
  - Initializes plugin and enable autocmd to cache.
  - parameters:
    - `user_opts`(optional): user options that explained above.
- `cache_path`
  - Returns the path to cache.
  - parameters:
    - `type`(required): 'mru' or 'mrw'.
- `append`
  - Appends given path to the cache file.
  - parameters:
    - `path`(required): file path to cache.
    - `type`(required): 'mru' or 'mrw'.

## Integration

This is example to select and edit MRU by [fzf-lua](https://github.com/ibhagwan/fzf-lua).

```lua
local fzf_lua = require('fzf-lua')
local mru_cache = require('mru_cache')

local gen_mru_cmd = function(type)
  -- remove current file and cwd
  return "sed -e '\\|^" .. vim.api.nvim_buf_get_name(0) .. "$|d' -e 's|^"
      .. vim.fn.getcwd() .. "/||' " .. mru_cache.cache_path(type)
end
local gen_mru_opts = function(args)
  local opts = {
    previewer = "builtin",
    actions = fzf_lua.defaults.actions.files,
    file_icons = true,
    color_icons = true
  }
  for k, v in pairs(args) do
    opts[k] = v
  end

  opts.fn_transform = function(x)
    return fzf_lua.make_entry.file(x, opts)
  end
  return opts
end

fzf_lua.mru = function(args)
  args.prompt = 'MRU> '
  local cmd = gen_mru_cmd('mru')
  local opts = gen_mru_opts(args)
  fzf_lua.fzf_exec(cmd, opts)
end

fzf_lua.mrw = function(args)
  args.prompt = 'MRW> '
  local cmd = gen_mru_cmd('mrw')
  local opts = gen_mru_opts(args)
  fzf_lua.fzf_exec(cmd, opts)
end
```
