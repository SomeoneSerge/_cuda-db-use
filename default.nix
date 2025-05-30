let
  npins = import ./npins;
  internalsOld = import (npins."nixpkgs" + "/pkgs/development/cuda-modules/_cuda");
  mkCudb = import (npins."nixpkgs" + "/pkgs/development/cuda-modules/_cuda/db");
  lib = import (npins."nixos-24.11" + "/lib");
  pkgs = import npins."nixos-24.11" {
    overlays = builtins.attrValues overlays;
    config.allowUnfreePredicate = internalsOld.lib.allowUnfreeCudaPredicate;
    config.cudaSupport = true;
  };
  overlays.eradicateOldCuda =
    _final: prev:
    lib.mapAttrs (_: _: null) (lib.filterAttrs (name: _: lib.hasPrefix "cudaPackages" name) prev);
  overlays.newCuda = final: _prev: {
    _cuda = internalsOld.extend (final: prev: {
      dbEvaluation = mkCudb { manifests = [ ]; extraModules = map lib.importJSON [
        ./cudb/blobs.json
        ./cudb/outputs.json
        ./cudb/packages.json
      ]; };
    });
    cudaPackages = final.callPackage (npins."nixpkgs" + "/pkgs/top-level/cuda-packages.nix") {
      pinProducts.cuda = "12.9";
    };
  };
in
pkgs
