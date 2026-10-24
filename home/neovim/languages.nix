# Language-specific plugins: LaTeX (vimtex + zathura), Rust, C/C++, Markdown.

{ pkgs, ... }:

{
  programs.nixvim = {
    # LaTeX: Space ll starts continuous compilation (latexmk), Space lv jumps
    # to the cursor position in the PDF (zathura). Ctrl+click in zathura jumps
    # back to the source line.
    plugins.vimtex = {
      enable = true;
      # Full TeX Live (~5 GB): no hunting for missing .sty files mid-thesis.
      texlivePackage = pkgs.texliveFull;
      settings = {
        view_method = "zathura";
        compiler_method = "latexmk";
        quickfix_mode = 0; # don't pop up the error window while typing
      };
    };

    # Rust: rust-analyzer + cargo integration (`:RustLsp` commands).
    plugins.rustaceanvim = {
      enable = true;
      settings.server.default_settings.rust-analyzer = {
        check.command = "clippy";
      };
    };

    # C/C++: clangd extras (inlay hints, switch header/source with Space ch).
    plugins.clangd-extensions.enable = true;

    # Markdown: rendered headings/tables in the buffer, live preview in the browser.
    plugins.render-markdown.enable = true;
    plugins.markdown-preview.enable = true;

    keymaps = [
      { mode = "n"; key = "<leader>ch"; action = "<cmd>LspClangdSwitchSourceHeader<CR>"; options.desc = "Switch header/source (C++)"; }
      { mode = "n"; key = "<leader>cm"; action = "<cmd>MarkdownPreviewToggle<CR>"; options.desc = "Markdown preview"; }
    ];
  };
}
