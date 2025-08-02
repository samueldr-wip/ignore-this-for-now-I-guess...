{ pkgs ? null
, nixpkgs_path ? null
}@args:

let
  pkgs =
    if args ? pkgs && args ? nixpkgs_path then
      builtins.throw "Only pkgs or nixpkgs_path can be given."
    else if args ? pkgs then
      args.pkgs
    else if args ? nixpkgs_path then
      import nixpkgs_path {}
    else
      import <nixpkgs> {}
  ;
in

pkgs.appendOverlays [(
  final: super:
  let
    inherit (final)
      callPackage
    ;
  in
  {
    hijack-bin = callPackage ./hijack-bin {};
    weirdStdenv = callPackage (
      { overrideCC
      , stdenv
      , hijack-bin
      }:
      let
        newCC =
          hijack-bin {
            package = stdenv.cc;
          }
        ;
      in
      overrideCC stdenv newCC
    ) {};
    hello = final.hijack-bin {
      package = super.hello;
    };
    weirder-hello = super.hello.override {
      stdenv = final.weirdStdenv;
    };
  }
)]
