{
  description = "Setup Godot 4 with Vulkan support for Intel GPUs via NixGL (X11)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, flake-utils, nixgl, lib }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
        mkdir $out
        ln -s ${pkg}/* $out
        rm $out/bin
        mkdir $out/bin
        for bin in ${pkg}/bin/*; do
         wrapped_bin=$out/bin/$(basename $bin)
         echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
         chmod +x $wrapped_bin
        done
        '';
      in {
        devShell = pkgs.mkShell {
          name = "godot4-vulkan-intel-env";

          buildInputs = [
            pkgs.godot_4
            nixgl.nixVulkanIntel
            pkgs.libglvnd
            pkgs.xorg.libX11
			(nixGLWrap pkgs.zenity)
          ];

          shellHook = ''
            # Set Vulkan ICD and Layer paths
            export VK_ICD_FILENAMES=${nixgl.nixVulkanIntel}/etc/vulkan/icd.d/intel_icd.json
            export VK_LAYER_PATH=${nixgl.nixVulkanIntel}/etc/vulkan/explicit_layer.d

            # Force X11 (if Wayland is installed but unused)
            export QT_QPA_PLATFORM="xcb"

            echo "Starting Godot 4 with Vulkan support on X11 for Intel GPUs..."
          '';
        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.godot_4}/bin/godot4";
          args = [ "--vulkan" "--display-driver=x11" ];  # Use Vulkan with X11
        };
      }
    );
}

