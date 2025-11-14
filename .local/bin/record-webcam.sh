#!/usr/bin/env bash

# Records an H264 encoded mp4 from the webcam
# Optional argument to specify the camera to record from. Defaults to /dev/video0

cam="${1:-/dev/video0}"
# gst-launch-1.0 v4l2src device=${cam} \
#     ! video/x-raw,width=640,height=480,framerate=30/1 \
#     ! clockoverlay \
#     ! videoconvert \
#     ! queue \
#     ! x264enc speed-preset=4 \
#     ! mp4mux \
#     ! filesink location="$HOME/Videos/webcam.mp4" -e
#
gst-launch-1.0 v4l2src device=${cam} \
    ! video/x-raw,width=640,height=480,framerate=30/1 \
    ! videoconvert \
    ! autovideosink
