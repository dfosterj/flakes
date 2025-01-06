{
  description = "Setup Neovim with NeoVide, LazyVim and essential dependencies";

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
          name = "neovim-lazyvim-env";

          buildInputs = [
            pkgs.neovim
            pkgs.neovide
            pkgs.python3
            pkgs.python3Packages.pynvim
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.fzf
            pkgs.ctags
            pkgs.nodejs
            pkgs.bat
            pkgs.silver-searcher
            pkgs.tmux
            pkgs.xterm
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

