# To install packages to the user environment, run:
#   nix profile install $HOME/.config/nixpkgs
# Or if you symlinked the flake to ~/.config/nixpkgs, you can run:
#   nix profile install "$(readlink -f $HOME/.config/nixpkgs)"
# To update the environment after changing this file or inputs, run:
#   nix profile upgrade ".*"

{
  description = "Default user environment packages";
  inputs = {
    # nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, nix-darwin }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        defaultPackages = {
          inherit (pkgs)
          # Basic terminal tools
            gnused # gnused on all platforms
            direnv # automatically switch environments in development directories
            git
            # Utilities
            bat # colorized cat
            # Development
            # Nix
            nixfmt-classic # format nix files
            nixpkgs-fmt # format nixpkgs files
          ;
        };
        linuxPackages = with pkgs; { inherit git; };
        darwinPackages = with pkgs; { inherit ; };

        userPackages = defaultPackages
          // (if (pkgs.lib.strings.hasInfix "linux" system) then
            linuxPackages
          else
            { }) // (if (pkgs.lib.strings.hasInfix "darwin" system) then
              darwinPackages
            else
              { });

        packageListString = pkgs.lib.concatMapStringsSep "\n" (x: "${x}")
          (builtins.attrValues userPackages);
      in {
        packages.default = pkgs.buildEnv {
          name = "nick-default-packages";
          paths = builtins.attrValues userPackages;
        };
      })) // {
        # darwin system config here
        darwinConfigurations = {
          "Nicks-MacBook-Air" = nix-darwin.lib.darwinSystem {
            inherit inputs;
            modules = [ ./hosts/mac-default/configuration.nix ];
          };
          "Nicks-Mac-mini-disabled" = nix-darwin.lib.darwinSystem {
            inherit inputs;
            modules = [ ./hosts/mac-default/configuration.nix ];
          };
        };
        # darwinPackages = self.darwinConfigurations = {
        #   "Nicks-MacBook-Air".packages = [ self.packages.default ];
        #   "Nicks-Mac-mini-disabled".packages = [ self.packages.default ];
        # };
        # nixos config here
      };
}
