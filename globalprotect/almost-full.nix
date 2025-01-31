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
            # (pkgs.python311.withPackages (ps: [
            #   ps.pygobject3 # pygobject package
            #   ps.requests   # requests package
            # ]))
		  	pkgs.python311
            # pkgs.glib-networking
            pkgs.gtk3
            pkgs.libglvnd
            pkgs.mesa
            pkgs.openconnect
            pkgs.gp-saml-gui
          ];

          shellHook = ''
		  # export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/
          echo "initializing globalprotect vpn..."
          echo "Enter VPN url:"
          read input
          echo "connecting to $input ..."
          gp-saml-gui $input
          # ${pkgs.python311}/bin/python3.11 ${self}/new-gp-saml-gui.py $input
          '';
          };
      });
}

