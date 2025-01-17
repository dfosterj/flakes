{
  description = "Setup a VPN connection using gp-saml-gui with TLS/SSL support and openconnect integration";

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
          name = "vpn-gp-saml-gui-env";

          buildInputs = [
            pkgs.networkmanager
            pkgs.gp-saml-gui
            pkgs.glib.networking
            pkgs.gtk3
            pkgs.libglvnd
            pkgs.mesa
            pkgs.openconnect
          ];

          shellHook = ''
            echo "Setting up VPN connection..."

            if ! systemctl is-active --quiet NetworkManager; then
              echo "Starting NetworkManager..."
              sudo systemctl start NetworkManager || echo "Failed to start NetworkManager"
            fi

            if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
              echo "Missing arguments. Please provide HOST, USER, COOKIE, and OS."
              return 1
            fi

            HOST="$1"
            USER="$2"
            COOKIE="$3"
            OS="$4"

            echo "Starting authentication with gp-saml-gui..."

            gp-saml-gui --vpn "$HOST" || { echo "gp-saml-gui authentication failed"; return 1; }
            echo "gp-saml-gui authentication complete!"

            export HOST USER COOKIE OS

            echo "$COOKIE" | openconnect --protocol=gp -u "$USER" --os="$OS" --passwd-on-stdin "$HOST" || { echo "OpenConnect connection failed"; return 1; }
            echo "OpenConnect VPN connection established!"
          '';
        };

        apps.x86_64-linux.default = {
          type = "app";
          program = "${self.devShell}/bin/bash";
          args = ["-c" "echo 'Use the shell for interactive VPN setup'"];
        };
      }
    );
}

