let
  import' =
    builtins.scopedImport (let self = {
      import = import';
      import-mechanism =
        mechanism:
        # Only using the set-pattern to declare the mandatory `source` argument.
        { source, ... }@args:
        let source' = source; in

        { source ? source' }:
        import' ((source' // source)).${mechanism} ( args // { source = args.source // source; } )
      ;

      builtins = builtins // {
        inherit (self)
          import-mechanism
        ;
      };
    }; in self)
  ;
in
  import' ./test.nix
