{
  outputs =
    { self, ... }:
    {
      packages.x86_64-linux.hello =
        (import (import ./npins).nixpkgs { system = "x86_64-linux"; }).hello
      ;
      checks.x86_64-linux.hello = self.packages.x86_64-linux.hello;
    }
  ;
}
