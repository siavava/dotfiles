#!/usr/bin/env fish
# -*- encoding: utf-8; -*-

function weather
  # if no argument, print for Hanover, NH.
  if test (count $argv) = 0
    printf "\nNo location specified.\nShowing updates for your current location.\n\n"
    curl -s "http://v2.wttr.in"

  # else print weather for each location entered.
  else
    # for location in "$@"
    for i in (seq (count $argv))
      set location $argv[$i]
      curl -s "http://v2.wttr.in/$location"
    end
  end
end
