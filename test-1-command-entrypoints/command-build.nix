builtins.customCli
{
  shortDescription = "Hello world example";
  description = ''
    The hello world example, used to show how a custom CLI tooling could work.
  '';

  # Options are always `--long`,
  # When a value must be given, it can be given with either:
  #   - `--long value`
  #   - `--long=value`
  options = {
    "subject" = {
      type = "string";
      # XXX can / should we sniff this out from the set-pattern function?
      # required = false;
      # default = "world";
      shortDescription = "The subject the greeting is aimed at";
      description = ''
        The name of the subject will be used in the templated greeting messages.
      '';
    };
    "language" = {
      type = "choice";
      # XXX should it be disallowed to evaluate a bit more Nix code?
      #values = [ "english" ];
      values =
        builtins.attrNames (import ./greetings.nix { subject = ""; })
      ;
      shortDescription = "The language of the set of greetings";
      description = ''
        Greetings are commonly available, and not expensive, in different languages.

        This option allows you to pick an alternative language to greet with.
      '';
    };
  };

  # XXX non-option arguments
  #arguments = {
  #  # Ordered?
  #  # XXX how would unordered be handled?
  #  positional = true;
  #  # XXX mobile-nixos example
  #  required = 1;
  #  argumentNames = [ "device" "configuration-name" ]
  #};
}

#
# A custom CLI consumes a function, and assumes it is a set-pattern function.
#

( import ./default.nix )
