fd -t f \
    -e mp4 \
    -e wmv \
    -e m4a \
    -e flac \
    -e mkv \
    -e webm \
    | fzf -m \
    | xargs -d '\n' mpv
