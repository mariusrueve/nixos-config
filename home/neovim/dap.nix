# Debugger: Python (debugpy) and Rust/C/C++ (codelldb), with a UI panel that
# opens when a session starts.
# Python: open the script, Space db on a line, Space dc, pick "file".
# Rust/C++: build with debug info (cargo build / -g), Space dc, enter the binary path.

{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.dap.enable = true;
    plugins.dap-ui.enable = true;
    plugins.dap-virtual-text.enable = true; # variable values shown inline

    # The adapter runs from a Nix Python with debugpy. The debugged program uses
    # the project's Python (e.g. from the devShell / .venv), so RDKit etc. work.
    plugins.dap-python.enable = true;

    plugins.dap-lldb = {
      enable = true;
      settings.codelldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}/bin/codelldb";
    };

    keymaps = [
      { mode = "n"; key = "<leader>db"; action = "<cmd>DapToggleBreakpoint<CR>"; options.desc = "Toggle breakpoint"; }
      { mode = "n"; key = "<leader>dc"; action = "<cmd>DapContinue<CR>"; options.desc = "Start / continue"; }
      { mode = "n"; key = "<leader>di"; action = "<cmd>DapStepInto<CR>"; options.desc = "Step into"; }
      { mode = "n"; key = "<leader>do"; action = "<cmd>DapStepOver<CR>"; options.desc = "Step over"; }
      { mode = "n"; key = "<leader>dO"; action = "<cmd>DapStepOut<CR>"; options.desc = "Step out"; }
      { mode = "n"; key = "<leader>dt"; action = "<cmd>DapTerminate<CR>"; options.desc = "Stop"; }
      {
        mode = "n";
        key = "<leader>du";
        action.__raw = "function() require('dapui').toggle() end";
        options.desc = "Toggle debugger UI";
      }
    ];

    # Open/close the debugger panels automatically with each session.
    extraConfigLua = ''
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    '';
  };
}
