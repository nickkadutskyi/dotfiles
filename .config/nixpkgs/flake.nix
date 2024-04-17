# To install packages to the user environment, run:
#   nix profile install $HOME/.config/nixpkgs
# Or if you symlinked the flake to ~/.config/nixpkgs, you can run:
#   nix profile install "$(readlink -f $HOME/.config/nixpkgs)"
# To update the environment after changing this file or inputs, run:
#   nix profile upgrade ".*"

{
  description = "Default user environment packages";
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        defaultPackages = {
          inherit (pkgs)
          # Basic terminal tools
            gnused # gnused on all platforms
            direnv # automatically switch environments in development directories
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
        systemPackages = defaultPackages
          // (if (pkgs.lib.strings.hasInfix "linux" system) then
            linuxPackages
          else
            { }) // (if (pkgs.lib.strings.hasInfix "darwin" system) then
              darwinPackages
            else
              { });
        packageListString = pkgs.lib.concatMapStringsSep "\n" (x: "${x}")
          (builtins.attrValues systemPackages);
      in {
        packages.default = pkgs.buildEnv {
          name = "nick-default-packages";
          paths = builtins.attrValues systemPackages;
        };
      })) // {
        # nixos config here
      };
}
