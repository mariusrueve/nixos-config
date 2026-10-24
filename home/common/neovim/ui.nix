# Neovim UI: key hints, file tree, fuzzy finder, git, status/buffer lines.

{ ... }:

{
  programs.nixvim = {
    plugins = {
      web-devicons.enable = true;

      # Press Space (or any prefix) and wait: shows the available keys.
      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>b"; group = "buffer"; }
          { __unkeyed-1 = "<leader>c"; group = "code"; }
          { __unkeyed-1 = "<leader>d"; group = "debug"; }
          { __unkeyed-1 = "<leader>f"; group = "find"; }
          { __unkeyed-1 = "<leader>g"; group = "git"; }
          { __unkeyed-1 = "<leader>l"; group = "latex"; }
          { __unkeyed-1 = "<leader>u"; group = "toggle"; }
        ];
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem = {
            follow_current_file.enabled = true;
            use_libuv_file_watcher = true;
          };
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = { action = "find_files"; options.desc = "Find file"; };
          "<leader>fg" = { action = "live_grep"; options.desc = "Grep in project"; };
          "<leader>fb" = { action = "buffers"; options.desc = "Open buffers"; };
          "<leader>fr" = { action = "oldfiles"; options.desc = "Recent files"; };
          "<leader>fh" = { action = "help_tags"; options.desc = "Help"; };
          "<leader>fd" = { action = "diagnostics"; options.desc = "Diagnostics"; };
          "<leader>fk" = { action = "keymaps"; options.desc = "Keymaps"; };
        };
      };

      gitsigns.enable = true;
      lazygit.enable = true;

      lualine = {
        enable = true;
        settings.options.globalstatus = true;
      };
      bufferline.enable = true;
      indent-blankline.enable = true;
      todo-comments.enable = true;

      # Nicer command line, messages and LSP progress.
      noice = {
        enable = true;
        settings.presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };
      notify.enable = true;

      nvim-autopairs.enable = true;
      comment.enable = true; # gcc / gc
      mini = {
        enable = true;
        modules.surround = { }; # sa / sd / sr: add / delete / replace surroundings
      };

      alpha = {
        enable = true;
        theme = "dashboard";
      };
    };

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options.desc = "File tree"; }
      { mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<CR>"; options.desc = "LazyGit"; }
      { mode = "n"; key = "<leader>gb"; action = "<cmd>Gitsigns blame_line<CR>"; options.desc = "Blame line"; }
      { mode = "n"; key = "<leader>gp"; action = "<cmd>Gitsigns preview_hunk<CR>"; options.desc = "Preview change"; }
    ];
  };
}
