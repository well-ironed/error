{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  erlang = beam.interpreters.erlangR22;
  elixir = beam.packages.erlangR22.elixir_1_13;
in

mkShell {
  buildInputs = [ erlang elixir ];
}
