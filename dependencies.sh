#!/bin/bash

if ! command -v wget &> /dev/null; then
    echo "Warning: wget not installed."
    exit 6;
fi

#127: Command not found
#6: Dependency error (Defined)