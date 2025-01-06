{
  description = "Standalone flake providing a development shell for Rust projects with necessary dependencies";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        buildInputs = with pkgs; [
          vulkan-loader
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          alsa-lib
          udev
          pkgconfig
        ];
        nativeBuildInputs = with pkgs; [
          (rust-bin.selectLatestNightlyWith
            (toolchain: toolchain.default.override {
              extensions = [ "rust-src" "clippy" ];
            }))
        ];
        allDeps = buildInputs ++ nativeBuildInputs ++ with pkgs; [
          cargo-flamegraph
          cargo-expand
          nixpkgs-fmt
          cmake
        ];
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = allDeps;
          shellHook = ''
            export CARGO_MANIFEST_DIR=$(pwd)
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath allDeps}"
          '';
        };
      }
    );
}

