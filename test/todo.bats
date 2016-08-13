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


@test "no parameters displays help" {
  run todo

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: todo <command>" ]
}

@test "help command displays help" {
  run todo help

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: todo <command>" ]
}


@test "empty directory counts zero" {
  run todo count

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "0" ]
}

@test "empty directory displays empty list" {
  run todo list

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" = "0" ]
}


@test "clearing" {
  run todo foo
  run sleep 1
  run todo bar

  run todo count

  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "2" ]

  run todo clear
  run todo count

  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "0" ]
}

@test "recursive clearing" {
  run todo foo

  mkdir subtest
  cd subtest

  run todo bar

  cd ..

  run todo list --recursive --raw

  [ "${status}" -eq 0 ]
  [ "${#lines[@]}" = "2" ]

  run todo clear --recursive
  run todo list --recursive --raw

  [ "${status}" -eq 0 ]
  [ "${#lines[@]}" = "0" ]
}


@test "raw listing" {
  run todo foo
  run sleep 1
  run todo bar
  run todo list --raw

  [ "${status}" -eq 0 ]
  [ "${#lines[@]}" = "2" ]
  [ "${lines[0]}" != "foo" ]
}


@test "recursive listing" {
  run todo foo

  mkdir subtest
  cd subtest

  run todo bar

  cd ..

  run todo list --recursive

  [ "${status}" -eq 0 ]
  [[ "${lines[1]}" == *"foo" ]]
  [[ "${lines[3]}" == *"bar" ]]
}


@test "recursive listing (raw)" {
  run todo foo

  mkdir subtest
  cd subtest

  run todo bar

  cd ..

  run todo list --recursive --raw

  [ "${status}" -eq 0 ]
  [ "${#lines[@]}" = "2" ]
}


@test "removal of a single todo" {
  run todo first
  run sleep 1
  run todo second
  run sleep 1
  run todo third

  run todo list

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" = "3" ]

  run todo rm 2
  run todo list

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"first" ]]
  [[ "${lines[1]}" == *"third" ]]
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


@test "handling of directories with spaces" {
  mkdir "subtest with space"
  cd "subtest with space"

  todo working

  run todo count

  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "1" ]

  cd ..

  run todo list --recursive

  [ "${status}" -eq 0 ]
  [[ "${lines[0]}" == *"subtest with space"* ]]
  [[ "${lines[1]}" == *"working" ]]
}