{
  description = "DevShell for building Linux Kernel using make menuconfig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          name = "linux-kernel-build-env";

          buildInputs = [
            pkgs.make
            pkgs.gcc
            pkgs.binutils
            pkgs.libncurses
            pkgs.zlib
            pkgs.bzip2
            pkgs.elfutils
            pkgs.flex
            pkgs.gawk
            pkgs.patch
            pkgs.git
          ];

          shellHook = ''
            # Ensure the Linux kernel source is cloned
            if [ ! -d "$HOME/kernel" ]; then
              echo "Cloning Linux kernel repository..."
              git clone https://github.com/torvalds/linux "$HOME/kernel" && echo "Clone successful" || echo "Clone failed"
            else
              echo "Linux kernel repository already exists."
            fi
          '';
        };

        # Optional: Add a default app that runs make menuconfig
        apps.default = {
          type = "app";
          program = "${pkgs.bash}/bin/bash";
          args = [ "-c" "cd $HOME/kernel && make menuconfig" ];
        };
      }
    );
}

