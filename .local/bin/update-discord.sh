#!/usr/bin/env bash
# Will extract newest version of discord

tar -xzf $(ls -t ~/Downloads | grep discord | head -n 1) -C ~/opt/
