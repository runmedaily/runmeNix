{ config, ... }:
{
  imports = [ ../../modules/shared/neovim ];

  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "25.11";
}
