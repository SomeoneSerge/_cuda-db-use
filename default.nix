let
  npins = import ./npins;
  _cuda = import (npins."nixpkgs" + "/pkgs/development/cuda-modules/_cuda");
  lib = import (npins."nixos-24.11" + "/lib");
  pkgs = import npins."nixos-24.11" {
    overlays = builtins.attrValues overlays;
    config.allowUnfreePredicate = _cuda.lib.allowUnfreeCudaPredicate;
    config.cudaSupport = true;
  };
  overlays.eradicateOldCuda =
    _final: prev:
    lib.mapAttrs (_: _: null) (lib.filterAttrs (name: _: lib.hasPrefix "cudaPackages" name) prev);
  overlays.newCuda = final: _prev: {
    inherit _cuda;
    cudaPackages = final.callPackage (npins."nixpkgs" + "/pkgs/top-level/cuda-packages.nix") {
      pinProducts.cuda = "12.8";
    };
  };
in
pkgs
