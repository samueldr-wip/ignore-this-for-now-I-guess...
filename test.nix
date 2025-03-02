{
  unfun = import ./consumer.nix { };
  funny = import ./consumer.nix { source = { hello = ./other.txt; }; };
  funniest = import ./consumer.nix { source = { hello = ./other.txt; selknirps = ./selknirps-but-evil.nix; }; };
}
