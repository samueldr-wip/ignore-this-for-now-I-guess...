{ lib
, runCommand
, symlinkJoin
, runtimeShell
, ruby
, time
}:

let
  inherit (lib)
    setPrio
    concatMapStringsSep
    attrValues
  ;
  overridePrio = lib.setPrio (-100);
in

{ package }:

symlinkJoin {
  inherit (package)
    name
  ;
  paths = [
    (runCommand "${package.name}.hijacked-bins" {} ''
      for dir in bin sbin libexec; do
        mkdir -v -p "$out/$dir"
        for bin in "${package}/$dir"/*; do
          exec="$out/$dir/$(basename "$bin")"
      cat <<EOF > "$exec"
      #!${runtimeShell}
      TIME=" → hello raito\n → exit status: %x\n → user: %U, system: %S, elapsed: %E\n → cpu: %P, max mem: %M (KiB), avg mem: %t (KiB), unshared: %D (KiB)\n → I/O: <I:%I O:%O>, sock: <r:%r s:%s>"
      mkdir -p "\$out"
      exec ${time}/bin/time --format="\$TIME" --append --output "\$out/test.txt" "$bin" "\$@"
      EOF
          chmod +x "$exec"
        done
      done
    '')
    package
  ];
}
