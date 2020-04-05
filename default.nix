let
  pkgs = import <nixpkgs> { };
  project = { mkDerivation, base, stdenv, turtle, split, network-uri, text }:
mkDerivation {
  pname = "hs-butler";
  version = "0.0.1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base split turtle text ];
  buildDepends = [ pkgs.zlib ];
  license = stdenv.lib.licenses.bsd3;
};
in
  { butler = pkgs.haskellPackages.callPackage project { };
  }
