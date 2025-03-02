{ source, output }:

{
  inherit source;
  output = output source;
}
