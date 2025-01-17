{
  description = "Setup Godot 4 with Vulkan support for Intel GPUs via Nix";

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
          name = "godot4-vulkan-intel-env";

          buildInputs = [
            pkgs.godot_4
            pkgs.nixVulkanIntel
          ];

          shellHook = ''
            # Ensure Vulkan is properly configured
            if [ -z "$VK_ICD_FILENAMES" ]; then
              export VK_ICD_FILENAMES="/etc/vulkan/icd.d/intel_icd.json"
            fi

            echo "Starting Godot 4 with Vulkan support for Intel GPUs..."
          '';
        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.godot_4}/bin/godot";
          args = [ "--vulkan" ];  # Force Vulkan mode in Godot 4
        };
      }
    );
}

