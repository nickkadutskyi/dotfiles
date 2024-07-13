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

  homebrew = {
    enable = true;
    casks = [
      { name = "swiftdefaultappsprefpane"; }
      { name = "sloth"; }
      { name = "finicky"; }
    ];
  };
}
