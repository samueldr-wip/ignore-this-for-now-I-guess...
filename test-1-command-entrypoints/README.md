# ?

```
[nix-shell:~/.../what-if-nix-cli/test-1-command-entrypoints]$ ./nix eval hello
"Hello world!"

[nix-shell:~/.../what-if-nix-cli/test-1-command-entrypoints]$ ./nix eval --language=french --subject=toi hello
"Bonjour toi!"

[nix-shell:~/.../what-if-nix-cli/test-1-command-entrypoints]$ ./nix eval --help
Usage: nix <command> [...]
Hello world example

The hello world example, used to show how a custom CLI tooling could work.

CUSTOM OPTIONS

        --language=choice            The language of the set of greetings
        --subject=string             The subject the greeting is aimed at

...
```
