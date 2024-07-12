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
          go # Probably for gcloud

          # PHP Develpoment
          php83 # PHP 8.3 (currently latest) to run symfony console completion
          php83Packages.composer # package manager for PHP (to init PHP projects)
          symfony-cli # for Symfony dev

          # JavaScript Development
          pnpm # package manager for JavaScript
          # dart # disabled due to conflict with composer

          # Lua Development
          lua54Packages.lua # For lua development and neovim configs
          stylua # lua formatter

          # Tools
          awscli2 # AWS CLI
          google-cloud-sdk # Google Cloud SDK
          ffmpeg # for video conversion
          dos2unix # convert text files with different line breaks
          imagemagick # for image conversion

          # Nix
          nixfmt-classic # format nix files
          nixpkgs-fmt # format nixpkgs files
          pandoc # for markdown conversion
          nil # nix lsp server

          # Misc
          exercism # for coding exercises

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
          ++ (if true then [ ./hosts/mac-default/services/dnsmasq.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/services/snippety.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
          ++ [ ];
        };
        "Nicks-Mac-mini" = nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules = [ ./hosts/mac-default/configuration.nix ]
          ++ (if true then [ ./hosts/mac-default/services/dnsmasq.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/services/snippety.nix ] else [ ])
          ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
          ++ [ ];
        };
      };
      # nixos system config here
    };
}
