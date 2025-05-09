return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    config = function()
      local dap = require('dap')
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7.exe",
        options = {
          detached = false
        }
      }
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'gdb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = 'C:\\ProgramData\\mingw64\\mingw64\\bin\\gdb.exe',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
        },
      }

      dap.configurations.c = dap.configurations.cpp

      vim.keymap.set("n", "<F5>", function()
        print("Starting debug session...") -- Debug output
        dap.continue()
      end, { desc = "Debug: Start/Continue" })

      vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<Leader>b", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        print("DAP initialized, opening UI...") -- Debug output
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
