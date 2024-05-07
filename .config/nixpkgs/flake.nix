# To install packages to the user environment, run:
#   nix profile install $HOME/.config/nixpkgs
# Or if you symlinked the flake to ~/.config/nixpkgs, you can run:
#   nix profile install "$(readlink -f $HOME/.config/nixpkgs)"
# To update the environment after changing this file or inputs, run:
#   nix profile upgrade ".*"
# To build nix-darwin system configurations first time, run:
#   nix run nix-darwin -- switch --flake "$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake . 

{
  description = "Default user environment packages";
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, nix-darwin }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        defaultPackages = with pkgs; [
          # Development
          devenv # development environment
          go
          # lua # For lua development and neovim configs
          lua54Packages.lua
          dart

          # Tools
          awscli2 # AWS CLI
          ffmpeg # for video conversion
          dos2unix # convert text files with different line breaks
          exercism
          imagemagick
          stylua

          # Nix
          nixfmt-classic # format nix files
          nixpkgs-fmt # format nixpkgs files
          pandoc # for markdown conversion

          # Coming from Homebrew but do not know why I need them
          # automake
          # db # berkeley-db in brew
          # bfg-repo-cleaner # bfg in brew 
          # cmake # probably needed this for nvim
          # python312Packages.cryptography # cryptography in brew
          # python312Packages.cffi # cffi in brew
          # cmocka
          # fpc # Free Pascal Compiler
          # guile
          # mkcert
          # git-filter-repo
        ];
        linuxPackages = with pkgs; [
          git # provide git on Linux 
        ];
        darwinPackages = with pkgs; [
          # Tools
          blueutil # control bluetooth (probably use in some script)
          duti # set default applications for document types and URL schemes
          fswatch # monitor a directory for changes (required by snippety-helper)
          coreutils-prefixed # GNU coreutils with prefix g (gtimeout is required by snippety-helper)

          # Development
          perl # updating built-in perl 
        ];

        userPackages = defaultPackages
        ++ (
          if (pkgs.lib.strings.hasInfix "linux" system) then
            linuxPackages
          else
            [ ]
        )
        ++ (
          if (pkgs.lib.strings.hasInfix "darwin" system) then
            darwinPackages
          else
            [ ]
        );
      in
      {
        packages.default = pkgs.buildEnv {
          name = "nick-default-packages";
          paths = userPackages;
        };
      })) // {
      # darwin system config here
      darwinConfigurations = {
        "Nicks-MacBook-Air" = nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules = [ ./hosts/mac-default/configuration.nix ]
          ++ (if true then [ ./hosts/mac-default/dnsmasq.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
          ++ [ ];
        };
        "Nicks-Mac-mini" = nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules = [ ./hosts/mac-default/configuration.nix ]
          ++ (if true then [ ./hosts/mac-default/dnsmasq.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
          ++ [ ];
        };
      };
      # nixos system config here
    };
}
