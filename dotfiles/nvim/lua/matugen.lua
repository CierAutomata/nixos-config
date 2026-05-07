 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#131316', -- Default Background
     base01 = '#1f1f23', -- Lighter Background (status bars)
     base02 = '#292a2d', -- Selection Background
     base03 = '#8f909a', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#c6c6d0', -- Dark Foreground (status bars)
     base05 = '#e4e1e6', -- Default Foreground
     base06 = '#e4e1e6', -- Light Foreground
     base07 = '#e4e1e6', -- Lightest Foreground
     -- Accent colors
     base08 = '#ffb4ab', -- Variables, XML Tags, Errors
     base09 = '#e3bada', -- Integers, Constants
     base0A = '#c2c5dd', -- Classes, Search Background
     base0B = '#b6c4ff', -- Strings, Diff Inserted
     base0C = '#e3bada', -- Regex, Escape Chars
     base0D = '#b6c4ff', -- Functions, Methods
     base0E = '#c2c5dd', -- Keywords, Storage
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
