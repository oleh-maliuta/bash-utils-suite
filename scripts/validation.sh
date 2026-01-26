#!/bin/bash

# Checks if the parameter is a positive integer
is_positive_integer() {
  if [[
    -n "$1" &&
    "$1" =~ ^[0-9]+$
  ]]; then
    return 0
  fi

  return 1
}
