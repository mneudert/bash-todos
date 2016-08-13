#!/usr/bin/env bats

export PATH="$(dirname "${BATS_TEST_DIRNAME}"):${PATH}"

setup() {
  export TODO_ROOT=$(mktemp --directory --tmpdir bash-todo_XXXXXXXX)
  export TODO_BASE=$(mktemp --directory --tmpdir bash-todo_XXXXXXXX)

  cd $TODO_BASE
}

teardown() {
  rm -rf "${TODO_ROOT}"
  rm -rf "${TODO_BASE}"
}


@test "modification of existing todo" {
  run todo first
  run sleep 1
  run todo second
  run sleep 1
  run todo third

  run todo list

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" = "3" ]
  [[ "${lines[1]}" == *"second" ]]

  run todo modify 2 dnoces
  run todo list

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" = "3" ]
  [[ "${lines[1]}" == *"dnoces" ]]
}
