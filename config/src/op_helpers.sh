function set_op_token() {
  OP_TOKEN_FILE="$HOME/.op_token"

  if [ ! -f $OP_TOKEN_FILE ]; then
    # Make the Op Service Account Token available
    export OP_SERVICE_ACCOUNT_TOKEN=$(cat $OP_TOKEN_FILE)
  fi
}
