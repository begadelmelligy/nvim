return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      local is_windows = vim.fn.has 'win32' == 1
      local is_linux = vim.fn.has 'unix' == 1 and not is_windows
      local shell
      if is_windows then
        shell = 'PowerShell'
      elseif is_linux then
        shell = 'zsh'
      end

      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 10
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]], -- Change this shortcut as needed
        shade_terminals = true,
        shading_factor = 2,
        direction = 'float', -- This makes it a floating terminal
        float_opts = {
          width = 80,
          height = 30,
        },
        close_on_exit = true,
        persist_mode = true, -- Keeps session open
        shell = shell,
      }
    end,
  },
}
