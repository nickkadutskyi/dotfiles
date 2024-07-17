{ pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # Activity Monitors
    btop
    htop

    # Development
    dnsmasq # For wildecard *.test for local development
    neovim # Lightweight editor
    git # Updated git instead of apple's git
    wp-cli # Wordpress CLI defined system wide because of the conflict with php

    # Tools
    gnutar # gnu tar for consistent tar across systems
    gnused # gnu sed for consistent sed across systems
    gnugrep # gnu grep for consistent grep across systems
    coreutils-prefixed # gnu coreutils (gtimeout is required by snippety-helper)
    fswatch # monitor a directory for changes (required by snippety-helper)
    pdfgrep # for searching pdf files
    ripgrep # for searching files
    tmux # for multiplexing
    tree # for directory structure
    bat # for syntax highlighting
    wget # for downloading
    speedtest-cli # for checking internet speed
    jq # for parsing json
    wrk # for benchmarking http requests
    dust # for disk usage
    tcping-go # for checking tcp connection "tcping google.com 80"
    fd # faster alternative to find
    fzf # fuzzy finder

    # Misc
    zsh-powerlevel10k
    zsh-autosuggestions
  ];
  # environment.shellAliases = {
  #   vi = "nvim";
  # };
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;
  services.activate-system.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    zsh = {
      enable = true;
      promptInit = "
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      ";
    };
    bash.enable = false;
    fish.enable = false;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";


  # Enable the touch-id authentication for sudo via tmux reattach and in proper file
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix-Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh 
    auth       sufficient     pam_tid.so
  '';

  # Autohide the dock.
  system.defaults.dock.autohide = true;

  # Enables direnv to automatically switch environments in project directories.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.silent = true;
  programs.direnv.loadInNixShell = true;
  # to make it silent since .silent option doesn't work in IntelliJ Terminal
  programs.direnv.direnvrcExtra = ''
    export DIRENV_LOG_FORMAT=
  '';

  environment.variables.HOMEBREW_NO_ANALYTICS = "1";
  homebrew = {
    enable = true;
    masApps = {
      "#blockit: Block distractions" = 1492879257;
      "1Blocker - Ad Blocker" = 1365531024;
      "1Password for Safari" = 1569813296;
      "Amazon Kindle" = 302584613;
      "Apple Developer" = 640199958;
      "BetterJSON for Safari" = 1511935951;
      "BetterML for Safari" = 1556487002;
      "Blackmagic Disk Speed Test" = 425264550;
      "DjVu Viewer + DjVu to PDF" = 755261884;
      "Easy CSV Editor" = 1171346381;
      "Evernote" = 406056744;
      "Fonts Ninja" = 1480227114;
      "iA Writer" = 775737590;
      "Keynote" = 409183694;
      "Microsoft Remote Desktop" = 1295203466;
      "Numbers" = 409203825;
      "OmniGraffle 7" = 1142578753;
      "Pages" = 409201541;
      "Parcel - Delivery Tracking" = 639968404;
      "Paste - Endless Clipboard" = 967805235;
      "PayPal Honey for Safari" = 1472777122;
      "Redirect Web for Safari" = 1571283503;
      "Reeder 5." = 1529448980;
      "Slack for Desktop" = 803453959;
      "Snippety - Snippets Manager" = 1530751461;
      "Telegram" = 747648890;
      "The Unarchiver" = 425424353;
      "The Archive Browser" = 510232205;
      "WhatsApp Messenger" = 310633997;
      "Wayback Machine" = 1472432422;
      "Xcode" = 497799835;
    };
    casks = [
      "1password"
      "adobe-creative-cloud"
      "amazon-chime"
      "anydesk"
      "appcleaner"
      "balenaetcher"
      "betterzip"
      "bettertouchtool"
      "bibdesk"
      "calibre"
      # "chromium 66" # not present in any package manager so handle it directly
      "cleanshot"
      "clickup"
      "core-tunnel"
      "daisydisk"
      "dash"
      "discord"
      "docker"
      "dropbox"
      "element"
      "finicky"
      "firefox"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hhkb"
      "hazel"
      "iina"
      "iterm2@beta"
      "itermai"
      "jetbrains-toolbox" 
      "jiggler"
      "karabiner-elements"
      "lastpass"
      "launchcontrol"
      "little-snitch"
      "logi-options-plus"
      # "mamp" # switch al lprojects to devenv.sh and nix flakes and get rid of mamp
      "microsoft-edge"
      "microsoft-teams"
      "obsidian"
      "openoffice"
      "protonvpn"
      "rapidapi"
      "raycast"
      "shortcutdetective"
      "sf-symbols"
      "sketch"
      "sloth" # for monitoring network and disk usage
      "splashtop-business"
      "spotify"
      "swiftdefaultappsprefpane"
      "teamviewer"
      "timing"
      "tor-browser"
      "transmission"
      "transmit"
      "tresorit"
      "typeface"
      # "upwork" # missing from any package managers so handling it directly
      "veracrypt"
      "viber"
      "virtualbox@beta"
      "vlc"
      "webex"
      "wireshark"
      "xquartz"
      "zoom"
    ];
    brews = [];
    onActivation = {
      cleanup = "zap"; # Removes unlisted casks and brews.
      autoUpdate = true; # Updates Homebrew and all installed packages.
      upgrade = true; # Upgrades outdated packages.
    };
  };
}
