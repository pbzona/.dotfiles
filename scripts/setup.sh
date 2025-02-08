#!/usr/bin/env bash

# Install mise to manage packages
#
# see: https://github.com/jdx/mise
#      https://mise.jdx.dev/
#
# Might need to add `mise trust` here due to symlinking
# but need to test 
#
curl "https://mise.run" | sh
command -v mise && \
  mise activate zsh && \
  mise install
