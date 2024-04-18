{ pkgs, inputs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
  [ 
    pkgs.btop
  ]; 
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  # programs.zsh.enable = false;  # default shell on catalina
  programs = {
    zsh.enable = true;
    bash.enable = false;
    fish.enable = false;
  };
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";


  # Enable the touch-id authentication for sudo.
  # security.pam.enableSudoTouchIdAuth = true;
  # Enable the touch-id authentication for sudo via tmux reattach and in proper file
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix-Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh 
      auth       sufficient     pam_tid.so
    '';
  };

  # Autohide the dock.
  system.defaults.dock.autohide = true;
}
