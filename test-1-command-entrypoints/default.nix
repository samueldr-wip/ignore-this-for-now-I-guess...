# nix-instantiate --eval --strict ./default.nix  --attr hello
{ language ? "english"
, subject ? "world"
}:

let greetings = import ./greetings.nix; in

(greetings { inherit subject; }).${language}
