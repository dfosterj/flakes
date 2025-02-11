{
  description = "Setup a VPN connection using gp-saml-gui with TLS/SSL support and openconnect integration";

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
        # packages = import ./pkgs/top-level.nix {
        #   callPackage = pkgs.callPackage;
        #   lib = pkgs.lib;
        #   pkgs = pkgs;
        # };
        devShell = pkgs.mkShell {
          name = "vpn-gp-saml-gui-env";

          buildInputs = [
            pkgs.networkmanager
            pkgs.gp-saml-gui
            # pkgs.glib.networking
            pkgs.gtk3
            pkgs.libglvnd
            pkgs.mesa
            pkgs.openconnect
            pkgs.glib-networking
          ];

          shellHook = ''
          echo "initializing globalprotect vpn..."
          echo "Enter VPN url:"
          read input
          '';
          };
      });
}

