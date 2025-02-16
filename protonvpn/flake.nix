{
  description = "Setup a VPN connection using Proton VPN CLI";

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
        devShell = pkgs.mkShell {
          name = "proton-vpn-cli-env";

          buildInputs = [
            pkgs.protonvpn-cli
            pkgs.openvpn
            pkgs.python3
            pkgs.networkmanager
            pkgs.glib-networking
          ];

          shellHook = ''
            echo "Proton VPN CLI environment ready."
            echo "To connect to Proton VPN, use the following command:"
            echo "protonvpn-cli connect"
          '';
        };
      });
}
