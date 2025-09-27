#!/usr/bin/env bash

htmx_version="1.9.4"
htmx_extensions=("include-vals" "debug" "sse" "json-enc")

mkdir -p htmx/ext
wget -P htmx/ "https://unpkg.com/htmx.org@${htmx_version}/dist/htmx.js"
wget -P htmx/ "https://unpkg.com/htmx.org@${htmx_version}/dist/htmx.min.js"

for ext in "${htmx_extensions[@]}"; do
    wget -P htmx/ext/ "https://unpkg.com/htmx.org@${htmx_version}/dist/ext/${ext}.js"
done;
