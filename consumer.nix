import-mechanism "selknirps"

{
  source = {
    selknirps = /* builtins.fetchTarball ... */ ./selknirps;
    hello = ./hello.txt;
  };
  output = (self: {
    hello = builtins.readFile self.hello;
  });
}
