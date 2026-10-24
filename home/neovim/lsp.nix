# Language servers, completion, syntax (treesitter) and format-on-save.
# All binaries come from Nix (no Mason). Project toolchains (Python env with
# RDKit, cargo, compilers) come from the project's devShell via direnv: start
# nvim inside the project directory so the servers see them.

{ ... }:

{
  programs.nixvim = {
    # Default server configs (cmd, filetypes, root markers) from nvim-lspconfig.
    plugins.lspconfig.enable = true;

    lsp = {
      inlayHints.enable = true;

      servers = {
        basedpyright.enable = true; # Python: types, completion, go-to-definition
        ruff.enable = true; # Python: lint + quick fixes
        texlab.enable = true; # LaTeX: completion, references, citations
        marksman.enable = true; # Markdown: links, headings
        nixd.enable = true; # Nix (this config!)
        bashls.enable = true; # Bash / SLURM scripts (uses shellcheck)
        clangd.enable = true; # C / C++
        neocmake.enable = true; # CMakeLists.txt
        taplo.enable = true; # TOML (pyproject.toml, Cargo.toml)
        yamlls.enable = true; # YAML (conda envs, CI, Snakemake configs)
        jsonls.enable = true; # JSON
        # Rust: rust-analyzer is started by rustaceanvim (languages.nix).
      };

      keymaps = [
        { key = "gd"; lspBufAction = "definition"; options.desc = "Go to definition"; }
        { key = "gD"; lspBufAction = "declaration"; options.desc = "Go to declaration"; }
        { key = "gi"; lspBufAction = "implementation"; options.desc = "Go to implementation"; }
        { key = "gt"; lspBufAction = "type_definition"; options.desc = "Go to type"; }
        {
          key = "gr";
          action.__raw = "require('telescope.builtin').lsp_references";
          options.desc = "References";
        }
        { key = "K"; lspBufAction = "hover"; options.desc = "Documentation"; }
        { key = "<leader>ca"; lspBufAction = "code_action"; options.desc = "Code action"; }
        { key = "<leader>cr"; lspBufAction = "rename"; options.desc = "Rename symbol"; }
        {
          key = "<leader>cs";
          action.__raw = "require('telescope.builtin').lsp_document_symbols";
          options.desc = "Symbols in file";
        }
        {
          key = "[d";
          action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
          options.desc = "Previous diagnostic";
        }
        {
          key = "]d";
          action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
          options.desc = "Next diagnostic";
        }
        { key = "<leader>cd"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Line diagnostics"; }
      ];
    };

    diagnostic.settings = {
      virtual_text = true;
      severity_sort = true;
      float.border = "rounded";
    };

    # Completion menu: LSP, file paths, words from open buffers, snippets.
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default"; # Ctrl-y accept, Ctrl-n/p next/prev, Ctrl-space open
        signature.enabled = true;
        completion.documentation.auto_show = true;
        sources.default = [ "lsp" "path" "snippets" "buffer" ];
      };
    };
    plugins.friendly-snippets.enable = true;

    # Syntax highlighting / indentation from tree-sitter; all grammars come prebuilt from Nix.
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # vimtex's own LaTeX highlighting is better than tree-sitter's and they
    # conflict. (`highlight.disable` is ignored by this nixvim release, hence
    # the autocmd.)
    autoCmd = [
      {
        event = "FileType";
        pattern = [ "tex" "plaintex" "bib" ];
        callback.__raw = ''
          function(args)
            vim.schedule(function()
              pcall(vim.treesitter.stop, args.buf)
              vim.bo[args.buf].syntax = vim.bo[args.buf].filetype
            end)
          end
        '';
      }
    ];

    # Format on save. `Space uf` toggles it for the current buffer, `Space cf` formats now.
    plugins.conform-nvim = {
      enable = true;
      autoInstall.enable = true; # formatter binaries from Nix
      settings = {
        formatters_by_ft = {
          python = [ "ruff_organize_imports" "ruff_format" ];
          rust = [ "rustfmt" ];
          c = [ "clang_format" ];
          cpp = [ "clang_format" ];
          nix = [ "nixfmt" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          tex = [ "latexindent" ];
          markdown = [ "prettier" ];
          toml = [ "taplo" ];
          yaml = [ "prettier" ];
          json = [ "prettier" ];
        };
        format_on_save.__raw = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end
            return { timeout_ms = 1000, lsp_format = "fallback" }
          end
        '';
      };
    };

    keymaps = [
      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ lsp_format = 'fallback' }) end";
        options.desc = "Format";
      }
      {
        mode = "n";
        key = "<leader>uf";
        action.__raw = ''
          function()
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            vim.notify("Format on save " .. (vim.b.disable_autoformat and "off" or "on") .. " (this buffer)")
          end
        '';
        options.desc = "Toggle format on save";
      }
    ];
  };
}
