{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      # editor
      neovim

      # lsp with many languages
      pyright
      lua-language-server
      typescript-language-server
      yaml-language-server
      gopls
      terraform-ls
      markdown-oxide

      # formatters and Treesitter parser compiler
      alejandra
      black
      go
      prettier
      stylua
      terraform
      tree-sitter

      # markdown support
      mdterm
      zk

      # diff file changes with git local or PR
      unstable.hunk
    ];
  };
}
