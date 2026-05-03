 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#111415', -- Default Background
     base01 = '#1d2021', -- Lighter Background (status bars)
     base02 = '#272a2c', -- Selection Background
     base03 = '#8a9296', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#bfc8cc', -- Dark Foreground (status bars)
     base05 = '#e1e3e4', -- Default Foreground
     base06 = '#e1e3e4', -- Light Foreground
     base07 = '#e1e3e4', -- Lightest Foreground
     -- Accent colors
     base08 = '#ffb4ab', -- Variables, XML Tags, Errors
     base09 = '#c3c3eb', -- Integers, Constants
     base0A = '#b3cad5', -- Classes, Search Background
     base0B = '#5ed4fc', -- Strings, Diff Inserted
     base0C = '#c3c3eb', -- Regex, Escape Chars
     base0D = '#5ed4fc', -- Functions, Methods
     base0E = '#b3cad5', -- Keywords, Storage
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
