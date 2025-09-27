#!/usr/bin/env bash

# Cheap roku TV's like mine can't play aac 5.1 (surround sound audio).
# This script converts to aac 2 (dual channel)

main() {
    mkdir -p roku
    for file in "${@}"; do
        # some-video.mkv -> some-video.roku.mkv
        local suffix="${file##*.}"
        local copy_file="roku/${file%.*}.roku.${suffix}"
        # echo "${copy_file} ${suffix}"
        ffmpeg -i "${file}" -map 0 -c copy -c:a aac -ac 2 "${copy_file}"
    done
}

main "${@}"
