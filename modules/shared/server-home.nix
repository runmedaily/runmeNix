{ config, ... }:
{
  imports = [ ./neovim ];
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "25.11";
}
