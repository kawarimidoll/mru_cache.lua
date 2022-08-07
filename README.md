# mru_cache.lua

A small MRU (most resent used) / MRW (most resent written) cache system for Neovim

## Requirements

GNU `sed`

## Installation

Install `kawarimidoll/mru_cache.lua` by your favorite plugin manager.

## Usage

Call `setup()` to enable autocmd to cache.

```
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
```
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
