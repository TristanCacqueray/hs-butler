# A cli butler as an haskell toy project

Build using

```
$(nix-build)/bin/butler --version
```

Run with

```
nix-shell --run 'cabal new-run exe:butler -- --help'
```

Dev with

```
nix-shell --run ghcid
```
