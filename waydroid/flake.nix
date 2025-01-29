{
  description = "Waydroid - A container-based approach to run Android on GNU/Linux systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        packages.waydroid = pkgs.waydroid;

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.waydroid
            pkgs.git
            pkgs.nixfmt
            pkgs.gdb
            pkgs.ripgrep
            pkgs.nixUnstable
          ];
        };
      });
}

