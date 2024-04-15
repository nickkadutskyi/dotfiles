{
  description = "Nick's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
    packages."aarch64-darwin".default = 
      let
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      in
        pkgs.buildEnv {
        name = "global-packages";
        paths = with pkgs; [
          # general tools
          git
          # ... add your tools here
      ];
    };
  };
}
