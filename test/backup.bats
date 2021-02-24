#!/usr/bin/env bats

export PATH="$(dirname "${BATS_TEST_DIRNAME}"):${PATH}"

setup() {
  export TODO_ROOT=$(mktemp -d -t bash-todo_XXXXXXXX)
  export TODO_BASE=$(mktemp -d -t bash-todo_XXXXXXXX)

  cd $TODO_BASE
}

teardown() {
  rm -rf "${TODO_ROOT}"
  rm -rf "${TODO_BASE}"
}


@test "backup --export ../relative" {
  run todo foo

  mkdir subdir
  cd subdir

  run todo bar

  cd ..

  run todo backup --export "test_export.tar.gz"

  [ "${status}" -eq 0 ]
  [ -f "test_export.tar.gz" ]

  raw=$(basename "$(todo list --raw | head -1)")
  contents=$(tar -tvf "test_export.tar.gz")

  [[ "${contents}" == *"${raw}"* ]]
}

@test "backup --export /absolute" {
  run todo foo

  mkdir subdir
  cd subdir

  run todo bar

  cd ..

  run todo backup --export "$(pwd)/test_export.tar.gz"

  [ "${status}" -eq 0 ]
  [ -f "test_export.tar.gz" ]

  raw=$(basename "$(todo list --raw | head -1)")
  contents=$(tar -tvf "test_export.tar.gz")

  [[ "${contents}" == *"${raw}"* ]]
}
