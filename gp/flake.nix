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
            pkgs.gp-saml-gui             # Replacing gpauth with gp-saml-gui
            pkgs.glib.networking         # Ensure TLS/SSL support
            pkgs.gtk3                    # GTK3 libraries for the authentication window
            pkgs.libglvnd                # OpenGL libraries for rendering
            pkgs.mesa                    # Mesa drivers for OpenGL support
            pkgs.openconnect             # OpenConnect package for VPN connection
          ];
          shellHook = ''
            echo "Setting up VPN connection..."
            # Ensure NetworkManager is running
            if ! systemctl is-active --quiet NetworkManager; then
              echo "Starting NetworkManager..."
              sudo systemctl start NetworkManager || echo "Failed to start NetworkManager"
            fi
            # Check if the required arguments are provided
            if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
              echo "Missing arguments. Please provide HOST, USER, COOKIE, and OS."
              return 1
            fi
            HOST="$1"
            USER="$2"
            COOKIE="$3"
            OS="$4"
            echo "Connecting to VPN: $HOST with user $USER..."
            # Use gp-saml-gui to authenticate and retrieve the necessary info
            gp-saml-gui --vpn "$HOST" || { echo "VPN connection to $HOST failed"; return 1; }
            echo "gp-saml-gui authentication complete!"
            # Export the values to the environment
            export HOST USER COOKIE OS
            # Run OpenConnect with the provided variables
            echo "$COOKIE" | openconnect --protocol=gp -u "$USER" --os="$OS" --passwd-on-stdin "$HOST" || { echo "OpenConnect connection failed"; return 1; }
            echo "OpenConnect VPN connection established!"
          '';
        };
        # # Define a default app for nix run
        # apps.default = {
        #   type = "app";
        #   program = "${pkgs.gp-saml-gui}/bin/gp-saml-gui";
        #   args = [ "--connect" ];
        # };
      }
    );
}
# flake.nix
{
  description = "Setup a VPN connection using gp-saml-gui with TLS/SSL support and openconnect integration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = with pkgs; mkShell {
          packages = with pkgs; [
            networkmanager
            gp-saml-gui             # Replacing gpauth with gp-saml-gui
            glib.networking         # Ensure TLS/SSL support
            gtk3                    # GTK3 libraries for the authentication window
            libglvnd                # OpenGL libraries for rendering
            mesa                    # Mesa drivers for OpenGL support
            openconnect             # OpenConnect package for VPN connection
            gcc
            xorg.libX11
            bash
            # additional custom scritps to be added to the path:
            (writeShellScriptBin "connect_global_protect_vpn" ''
              echo "Setting up VPN connection..."
              
              # Ensure NetworkManager is running
              if ! systemctl is-active --quiet NetworkManager; then
                echo "Starting NetworkManager..."
                sudo systemctl start NetworkManager || echo "Failed to start NetworkManager"
              fi
              
              # Check if the required arguments are provided
              if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
                echo "Missing arguments. Please provide HOST, USER, COOKIE, and OS."
                return 1
              fi
              
              HOST="$1"
              USER="$2"
              COOKIE="$3"
              OS="$4"
              
              echo "Connecting to VPN: $HOST with user $USER..."
              
              # Use gp-saml-gui to authenticate and retrieve the necessary info
              gp-saml-gui --vpn "$HOST" || { echo "VPN connection to $HOST failed"; return 1; }
              echo "gp-saml-gui authentication complete!"
              
              # Export the values to the environment
              export HOST USER COOKIE OS
              
              # Run OpenConnect with the provided variables
              echo "$COOKIE" | openconnect --protocol=gp -u "$USER" --os="$OS" --passwd-on-stdin "$HOST" || { echo "OpenConnect connection failed"; return 1; }
              echo "OpenConnect VPN connection established!"
            '')
          ];
          shellHook = ''
            echo "Entering gp flake"
            exec bash
          '';
        };
      }
    );
}
