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
      set pids (lsof -t -i:$port_num)

      if test (count $pids) -gt 0
        for pid in $pids
          printf "KILLING PROCESS $pid ON PORT $port_num\n"
          kill "$pid"
          printf "KILLED PROCESS $pid ON PORT $port_num\n\n"
        end
      else
        printf "\n\nNO PROCESS RUNNING ON PORT $port_num\n\n"
      end
    end
    return 0
  end
end
