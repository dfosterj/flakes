{
  description = "kernel build env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        devShell = pkgs.mkShell {
          name = "kdev";

          buildInputs = [
            pkgs.gnumake
            pkgs.gcc
            pkgs.binutils
            pkgs.ncurses
            pkgs.zlib
            pkgs.bzip2
            pkgs.elfutils
            pkgs.flex
            pkgs.gawk
            pkgs.patch
            pkgs.git
            pkgs.openssl
          ];

          shellHook = ''
          echo 'ready to run make menuconfig'
          '';
          };
      });
}

