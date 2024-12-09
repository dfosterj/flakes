{
  description = "Setup Neovim with LazyVim and essential dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Use nixos-unstable for up-to-date packages
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          name = "neovim-lazyvim-env";

          buildInputs = [
            pkgs.neovim                     # Neovim
            pkgs.python3                   # Python 3
            pkgs.python3Packages.pynvim     # Python package for Neovim
            pkgs.git                         # Git for cloning repositories
            pkgs.ripgrep                    # Fast search tool
            pkgs.fd                         # Fast file search
            pkgs.fzf                        # Fuzzy file search
            pkgs.ctags                      # Code tags for navigation
            pkgs.nodejs                     # Node.js for Neovim plugins
            pkgs.bat                        # Syntax highlighting for cat
            pkgs.silver-searcher            # Alternative to ripgrep
            pkgs.tmux                       # Terminal multiplexer
            pkgs.xterm                      # Terminal emulator for graphical environments
          ];

          shellHook = ''
            # Ensure that the repository for LazyVim is cloned
            if [ ! -d "$HOME/.config/nvim" ]; then
              echo "Cloning LazyVim repository..."
              git clone https://github.com/dfosterj/dedlazyvim "$HOME/.config/nvim" && echo "Clone successful" || echo "Clone failed"
            else
              echo "LazyVim repository already exists."
            fi
          '';
        };

        # Define a default app for nix run
        apps.default = {
          type = "app";
          program = "${pkgs.neovim}/bin/nvim";
          args = [ "--headless" "+Lazy! sync" ]; # Run LazyVim plugin sync when executed
        };
      }
    );
}

