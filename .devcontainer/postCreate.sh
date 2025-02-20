#!/bin/bash
echo "Setting up environment..."

# Initialize opam
opam init -y
opam switch create 4.14.0
eval $(opam env)

# create a new dune project
dune init proj etl_pipeline
