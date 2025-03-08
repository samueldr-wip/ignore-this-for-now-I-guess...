#
# `builtins.customCli` handler.
#
let
  self = {
    inherit import;
    builtins = builtins // {
      inherit (self) import;
      inherit customCli;
    };
  };
  import = builtins.scopedImport self;
  # This handler gives the configuration side of the customCli args pair.
  customCli =
    configuration: _next:
    configuration
  ;
in
  { path }:
  import path
