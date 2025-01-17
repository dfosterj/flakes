{
  description = "Setup a VPN connection using GPAUTH";

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
          name = "vpn-gpauth-env";

          buildInputs = [
            pkgs.networkmanager
            pkgs.gpauth
          ];

          shellHook = ''
            echo "Setting up VPN connection..."

            # Ensure NetworkManager is running
            if ! systemctl is-active --quiet NetworkManager; then
              echo "Starting NetworkManager..."
              sudo systemctl start NetworkManager || echo "Failed to start NetworkManager"
            fi

            # Check if the first argument is provided
            if [ -z "$1" ]; then
              echo "No VPN address provided. Please provide a VPN address."
              return 1
            fi

            VPN_ADDRESS="$1"
            echo "Connecting to VPN: $VPN_ADDRESS"

            # Configure VPN using gpauth
            gpauth --init
            gpauth add "$VPN_ADDRESS" --vpn
            gpauth connect "$VPN_ADDRESS" || echo "VPN connection to $VPN_ADDRESS failed"
            echo "VPN connection to $VPN_ADDRESS established!"
          '';
        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.gpauth}/bin/gpauth";
          args = [ "connect" ];
        };
      }
    );
}

