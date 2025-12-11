#!/usr/bin/env fish
# -*- coding: utf-8; -*-

# Kill process running on a specific port.
# Expected Args: the port number !!
function undo
  if test (count $argv) = 0
    printf "\nExpected at least one port number, got 0\n\n"
    return 1
  else
    for i in (seq (count $argv))
      set port_num $argv[$i]
      set pid $(lsof -t -i:$port_num)

      # if pid is not empty, kill it
      if test $pid
        printf "KILLING PROCESS $pid ON PORT $port_num\n"
        kill "$pid"
        printf "KILLED PROCESS $pid ON PORT $port_num\n\n"
      else
        printf "\n\nNO PROCESS RUNNING ON PORT $port_num\n\n"
      end
    end
    return 0
  end
end
