#! /bin/zsh

source ./op_helpers.sh

function this_dir() {
  dirname $(readlink -f ${BASH_SOURCE[0]})
}
