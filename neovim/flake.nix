{
  description = "Setup Neovim with LazyVim, dependencies, and Bash for Toggleterm";

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
            pkgs.the_silver_searcher        # Alternative to ripgrep
            pkgs.tmux                       # Terminal multiplexer
            pkgs.bash                       # Bash shell for toggleterm support
            pkgs.xterm                      # Terminal emulator for graphical environments
            pkgs.bashCompletion             # Bash completion for interactive shell features
          ];

          shellHook = ''
            # Source bash completion for interactive use
            if [ -f $HOME/.bash_completion ]; then
              source $HOME/.bash_completion
            fi

            echo "Setting up LazyVim from GitHub..."
            if [ ! -d ~/.config/nvim ]; then
              git clone https://github.com/dfosterj/dedlazyvim ~/.config/nvim
            fi
            echo "Neovim and LazyVim are ready to use!"
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

