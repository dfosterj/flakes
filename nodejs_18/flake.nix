{
  description = "Setup Node.js 18 with latest npm, pnpm, and a dev environment";

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
          name = "nodejs-18-env";

          buildInputs = [
            pkgs.nodejs-18_x
            pkgs.git
            pkgs.curl
          ];

          shellHook = ''
            echo "Setting up Node.js environment..."

            # Update npm to the latest version
            echo "Updating npm..."
            npm install -g npm@latest && echo "npm updated to $(npm --version)" || echo "npm update failed"

            # Install and configure pnpm
            echo "Installing pnpm..."
            npm install -g pnpm && echo "pnpm installed successfully"

            echo "Running pnpm setup..."
            pnpm setup && echo "pnpm setup completed"

            echo "Adding pnpm globally..."
            pnpm add -g pnpm && echo "pnpm is now globally available"

            echo "Node.js environment setup complete!"
          '';
        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.nodejs-18_x}/bin/node";
        };
      }
    );
}


