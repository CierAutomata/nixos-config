 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#13140f', -- Default Background
     base01 = '#1f201b', -- Lighter Background (status bars)
     base02 = '#2a2a25', -- Selection Background
     base03 = '#919283', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#c7c8b8', -- Dark Foreground (status bars)
     base05 = '#e4e2da', -- Default Foreground
     base06 = '#e4e2da', -- Light Foreground
     base07 = '#e4e2da', -- Lightest Foreground
     -- Accent colors
     base08 = '#ffb4ab', -- Variables, XML Tags, Errors
     base09 = '#a1d0c4', -- Integers, Constants
     base0A = '#c5caa8', -- Classes, Search Background
     base0B = '#bad064', -- Strings, Diff Inserted
     base0C = '#a1d0c4', -- Regex, Escape Chars
     base0D = '#bad064', -- Functions, Methods
     base0E = '#c5caa8', -- Keywords, Storage
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
