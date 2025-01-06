# flakes

## Usage

```bash
nix build moduleDir/
nix run moduleDir/
```

## example
```bash
nix run /path/to/flakeDir/neovide file.txt
```

## tips
if errors in build occur like
does not provide attribute 'packages.x86_64-darwin.default' or 'defaultPackage.x86_64-darwin

delete lock file and rm nix cache

```bash
rm flake.lock
nix-collect-garbage -d
```
