{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig =
      builtins.readFile ./lua/options.lua
      + builtins.readFile ./lua/keymaps.lua
      + builtins.readFile ./lua/appearance.lua
      + builtins.readFile ./lua/telescope.lua
      + builtins.readFile ./lua/oil-config.lua;

    plugins = with pkgs.vimPlugins; [
      # Colorscheme
      rose-pine

      # Syntax highlighting
      nvim-treesitter.withAllGrammars

      # Statusline
      mini-nvim

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim
      plenary-nvim

      # File explorer
      oil-nvim
      mini-icons
    ];

    extraPackages = with pkgs; [
      # LSP servers and tools — added as we go
      ripgrep
      fd
    ];
  };
}
