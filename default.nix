let
  pkgs = import <nixpkgs> { };
  project = { mkDerivation, base, stdenv, turtle }:
mkDerivation {
  pname = "hs-butler";
  version = "0.0.1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base turtle ];
  buildDepends = [ pkgs.zlib ];
  license = stdenv.lib.licenses.bsd3;
};
in
  { butler = pkgs.haskellPackages.callPackage project { };
  }
