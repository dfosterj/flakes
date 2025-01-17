# flake.nix
{
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
            # list packages you want to be in the path here ...
            gcc
            xorg.libX11
            zsh
            # additional custom scritps to be added to the path:
            (writeShellScriptBin "say-hello" ''
                echo "hello world!"
            '')
          ];
          shellHook = ''
            echo "Entering dev shell"
            exec zsh
          '';
        };
      }
    );
}
