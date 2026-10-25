# Neovim, configured entirely in Nix with nixvim (https://nix-community.github.io/nixvim/).
# Change anything here, then `sudo nixos-rebuild switch --flake .` and restart nvim.
#
# Cheat sheet (leader = Space; press Space and wait, which-key shows everything):
#   Space e        file tree (neo-tree)          Space ff / fg   find file / grep in project
#   Space fb / fr  open buffers / recent files   Space gg        lazygit
#   gd / gr / K    definition / references / docs   Space ca / cr   code action / rename
#   [d / ]d        previous / next diagnostic    Space cf        format now (Space uf: toggle format-on-save)
#   Space db / dc  breakpoint / start-continue   Space du        debugger UI
#   Space ll / lv  LaTeX: compile (continuous) / view PDF in zathura
#   gcc / gc       comment line / selection      Ctrl-h/j/k/l    move between splits
#   Shift-h / l    previous / next buffer (tab)  Space bd        close buffer
# New to Vim motions? Run `:Tutor` inside nvim (30 minutes, worth it).

{ ... }:

{
  imports = [
    ./ui.nix
    ./lsp.nix
    ./languages.nix
    ./dap.nix
  ];

  programs.nixvim = {
    enable = true;
    # Use the system's nixpkgs (same packages, overlays and allowUnfree as
    # everything else) instead of a separate instance.
    nixpkgs.useGlobalPackages = true;
    # $EDITOR / $VISUAL (git commits, sudoedit, ...), and `vi`/`vim` open nvim.
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        integrations = {
          blink_cmp = true;
          gitsigns = true;
          neotree = true;
          noice = true;
          notify = true;
          telescope.enabled = true;
          which_key = true;
          dap = true;
          dap_ui = true;
          render_markdown = true;
        };
      };
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # System clipboard via wl-clipboard: y/p work with other apps.
    clipboard.register = "unnamedplus";

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      signcolumn = "yes";
      scrolloff = 8;
      wrap = false;
      # Line-length guide at 88 (ruff/black default). Rust gets 100 below, rustfmt's limit.
      colorcolumn = "88";

      # 4-space indentation by default; filetype plugins / editorconfig override per language.
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
      smartindent = true;

      ignorecase = true;
      smartcase = true;

      splitright = true;
      splitbelow = true;

      undofile = true; # undo history survives closing the file
      updatetime = 250;
      timeoutlen = 400; # how fast which-key pops up
      termguicolors = true;
      mouse = "a";
    };

    keymaps = [
      # Leave insert mode with `jk` (easier than reaching for Escape).
      { mode = "i"; key = "jk"; action = "<Esc>"; }
      # Clear search highlight.
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      # Move between splits.
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Window left"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Window down"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Window up"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Window right"; }
      # Buffers (shown as tabs by bufferline).
      { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Close buffer"; }
      # Keep the selection when indenting in visual mode.
      { mode = "v"; key = "<"; action = "<gv"; }
      { mode = "v"; key = ">"; action = ">gv"; }
      # Save with Ctrl-s in any mode.
      { mode = [ "n" "i" "v" ]; key = "<C-s>"; action = "<cmd>w<CR><Esc>"; options.desc = "Save file"; }
    ];

    # Briefly highlight yanked text.
    autoCmd = [
      {
        event = "TextYankPost";
        callback.__raw = "function() vim.hl.on_yank() end";
      }
      # Match the guide to rustfmt's max_width.
      {
        event = "FileType";
        pattern = "rust";
        command = "setlocal colorcolumn=100";
      }
    ];
  };
}
