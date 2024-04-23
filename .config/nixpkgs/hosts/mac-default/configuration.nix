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

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";


  # Enables the touch-id authentication for sudo.
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

  # DNS resolver for *.test domain to point to 127.0.0.1 to avoid changing /etc/hosts.
  services.dnsmasq.enable = true;
  services.dnsmasq.addresses = { test = "127.0.0.1"; };

  environment.variables.TEST_VAR = "test";

  # Enables direnv to automatically switch environments in project directories.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.silent = true;

  # Configure built-in Apache server.
  system.activationScripts.postActivation.text = 
    let
      sed = "${pkgs.gnused}/bin/sed";
      file = "/etc/apache2/httpd.conf";
      option = "custom.enableBuiltInHttpd";
      httpdEnabled = true;
    in  
      ''
      echo "Setting up Apache server..."
      declare -a apacheModules=(
                "LoadModule proxy_module libexec/apache2/mod_proxy.so"
                "LoadModule proxy_fcgi_module libexec/apache2/mod_proxy_fcgi.so"
                )
      ${if httpdEnabled then ''
        # Enable modules
        for i in "''${apacheModules[@]}"
        do
          if [[ $(${sed} -n '/${option}/{:start \@'"$i"'@!{N;b start};\,${option}\n'"$i"',p}' ${file}) ]]; then
            echo "Module $i already enabled"
          else
            echo "Enabling module $i"
            ${sed} -i '\,#'"$i"',a\
        # nix-darwin: ${option}\
        '"$i"'
            ' ${file}
          fi
        done
        sudo apachectl restart
      '' else ''
        # Disable modules
        if grep '${option}' ${file} > /dev/null; then
          echo "Disabling modules..."
          ${sed} -i '/${option}/,+1d' ${file}
          sudo apachectl stop
        fi
      ''}
      '';
}
