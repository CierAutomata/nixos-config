 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#111416', -- Default Background
     base01 = '#1e2022', -- Lighter Background (status bars)
     base02 = '#282a2d', -- Selection Background
     base03 = '#8c9198', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#c2c7ce', -- Dark Foreground (status bars)
     base05 = '#e2e2e5', -- Default Foreground
     base06 = '#e2e2e5', -- Light Foreground
     base07 = '#e2e2e5', -- Lightest Foreground
     -- Accent colors
     base08 = '#ffb4ab', -- Variables, XML Tags, Errors
     base09 = '#d1bfe7', -- Integers, Constants
     base0A = '#b8c8da', -- Classes, Search Background
     base0B = '#92ccff', -- Strings, Diff Inserted
     base0C = '#d1bfe7', -- Regex, Escape Chars
     base0D = '#92ccff', -- Functions, Methods
     base0E = '#b8c8da', -- Keywords, Storage
     base0F = '#93000a', -- Deprecated, Embedded Tags
   }
 end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
