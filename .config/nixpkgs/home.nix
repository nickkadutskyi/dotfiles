{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = "nick";
  # home.homeDirectory = "/home/nick";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Development
    devenv # development environment
    go # Probably for gcloud
    dart-sass # for sass to css conversion

    # PHP Develpoment
    php83 # PHP 8.3 (currently latest) to run symfony console completion
    php83Packages.composer # package manager for PHP (to init PHP projects)
    symfony-cli # for Symfony dev

    # JavaScript Development
    pnpm # package manager for JavaScript
    nodePackages_latest.nodejs
    # dart # disabled due to conflict with composer

    # Lua Development
    lua54Packages.lua # For lua development and neovim configs
    lua54Packages.luarocks # lua package manager
    stylua # lua formatter

    # Tools
    awscli2 # AWS CLI
    google-cloud-sdk # Google Cloud SDK
    ffmpeg # for video conversion
    dos2unix # convert text files with different line breaks
    imagemagick # for image conversion
    pandoc # for markdown conversion

    # Nix
    nixfmt-classic # format nix files
    nixpkgs-fmt # format nixpkgs files
    nil # nix lsp server

    # Misc
    exercism # for coding exercises
    zsh-completions
  ] ++ (
    if (pkgs.lib.strings.hasInfix "linux" system) then
      [
        git
      ]
    else
      [ ]
  ) ++ (
    if (pkgs.lib.strings.hasInfix "darwin" system) then
      [
        # Tools
        blueutil # control bluetooth (probably use in some script)
        duti # set default applications for document types and URL schemes

        # Development
        perl # updating built-in perl 
      ]
    else
      [ ]
  );

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  targets.darwin.defaults = {
    "com.apple.dock".autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    # Currently doesn't work
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
    "com.apple.Safari".IncludeDevelopMenu = true;
    "com.apple.finder".ShowPathBar = true;
    "com.apple.finder".ShowStatusBar = true;
    NSGlobalDomain.AppleLanguages = [
      "en-US"
      "ru-US"
      "uk-US"
    ];
    NSGlobalDomain.AppleLocale = "en_US";
  };
}
