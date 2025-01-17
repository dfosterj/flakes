{
  description = "Setup Godot 4 with Vulkan support for Intel GPUs via NixGL (X11) and nixGLWrap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, flake-utils, nixgl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        # Wrapper function for executables using nixGL
        nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
        ┆ mkdir $out
        ┆ ln -s ${pkg}/* $out
        ┆ rm $out/bin
        ┆ mkdir $out/bin
        ┆ for bin in ${pkg}/bin/*; do
        ┆ ┆wrapped_bin=$out/bin/$(basename $bin)
        ┆ ┆echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
        ┆ ┆chmod +x $wrapped_bin
        ┆ done
        '';
        nixVulkanIntelWrap = pkg: pkgs.runCommand "${pkg.name}-nixvulkanintel-wrapper" {} ''
        ┆ mkdir $out
        ┆ ln -s ${pkg}/* $out
        ┆ rm $out/bin
        ┆ mkdir $out/bin
        ┆ for bin in ${pkg}/bin/*; do
        ┆ ┆wrapped_bin=$out/bin/$(basename $bin)
        ┆ ┆echo "exec ${lib.getExe nixgl.nixVulkanIntel} $bin \$@" > $wrapped_bin
        ┆ ┆chmod +x $wrapped_bin
        ┆ done
        '';

      in {
        devShell = pkgs.mkShell {
          name = "godot4-vulkan-intel-env";

          buildInputs = [
            nixgl.auto.nixGLDefault
            nixgl.nixVulkanIntel
            pkgs.godot_4
            pkgs.libglvnd
            pkgs.libglvnd
            pkgs.wl-clipboard
            pkgs.xwayland
            pkgs.xorg.libX11
            (nixVulkanIntelWrap pkgs.godot_4)
            (nixGLWrap pkgs.zenity)
          ];

        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.godot_4}/bin/godot4";
          args = [ "--headless --export-release 'Linux/X11'" ];
        };
      }
    );
}

{
  description = "Setup Neovim with NeoVide, LazyVim and essential dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = pkgs.lib;
        pkgs = import nixpkgs { inherit system; };
        nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
        ┆ mkdir $out
        ┆ ln -s ${pkg}/* $out
        ┆ rm $out/bin
        ┆ mkdir $out/bin
        ┆ for bin in ${pkg}/bin/*; do
        ┆ ┆wrapped_bin=$out/bin/$(basename $bin)
        ┆ ┆echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
        ┆ ┆chmod +x $wrapped_bin
        ┆ done
        '';
        nixVulkanIntelWrap = pkg: pkgs.runCommand "${pkg.name}-nixvulkanintel-wrapper" {} ''
        ┆ mkdir $out
        ┆ ln -s ${pkg}/* $out
        ┆ rm $out/bin
        ┆ mkdir $out/bin
        ┆ for bin in ${pkg}/bin/*; do
        ┆ ┆wrapped_bin=$out/bin/$(basename $bin)
        ┆ ┆echo "exec ${lib.getExe nixgl.nixVulkanIntel} $bin \$@" > $wrapped_bin
        ┆ ┆chmod +x $wrapped_bin
        ┆ done
        '';
      in {
        devShell = pkgs.mkShell {
          name = "godot4-vulkan-intel-env";

          buildInputs = [
            nixgl.auto.nixGLDefault
            nixgl.nixVulkanIntel
            pkgs.godot_4
            pkgs.libglvnd
            pkgs.libglvnd
            pkgs.wl-clipboard
            pkgs.xwayland
            pkgs.xorg.libX11
            (nixVulkanIntelWrap pkgs.godot_4)
            (nixGLWrap pkgs.zenity)
          ];

        };

        apps.default = {
          type = "app";
          program = "${pkgs.godot_4}/bin/godot4";
          args = [ "--headless" "--export-release 'Linux/X11'" ];
        };
      }
    );
}

