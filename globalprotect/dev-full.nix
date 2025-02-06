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

        # Helper function to create a prefix setup for environment variables
        prefixSetup = pkgs.writeShellScriptBin "prefix-setup" ''
          export GI_TYPELIB_PATH=${pkgs.lib.makeSearchPath "lib/girepository-1.0" [
            pkgs.gtk3
            pkgs.gobject-introspection
            pkgs.webkitgtk
          ]}
          export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
            pkgs.libglvnd
            pkgs.mesa
            pkgs.gtk3
          ]}
        '';
      in {
        devShell = pkgs.mkShell {
          name = "vpn-gp-saml-gui-env";

          buildInputs = [
            (pkgs.python311.withPackages (ps: [
              ps.pygobject3 # PyGObject bindings
              ps.requests   # requests package
            ]))
            pkgs.gobject-introspection # GObject Introspection
            pkgs.glib-networking       # GLib networking stack
            pkgs.gtk3                  # GTK3 library
            pkgs.webkitgtk             # WebKitGTK for WebKit2
            pkgs.libglvnd              # OpenGL library
            pkgs.mesa                  # Mesa graphics library
            pkgs.openconnect           # OpenConnect VPN client
            prefixSetup                # Prefix setup script
          ];

          # Run the prefix setup before the shell hook
          shellHook = ''
            ${prefixSetup}/bin/prefix-setup
            echo "Initializing GlobalProtect VPN..."
            echo "Enter VPN URL:"
            read input
            echo "Connecting to $input ..."
            ${pkgs.python311}/bin/python3.11 ${self}/new-gp-saml-gui.py $input
          '';
        };
      });
}
