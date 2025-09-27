#!/usr/bin/env bash

head -c "${1:-32}" /dev/urandom | base64
