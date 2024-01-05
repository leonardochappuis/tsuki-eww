if pgrep -i -x "process_name" > /dev/null; then
  echo "Process is running."
else
  LD_PRELOAD=/usr/local/lib/spotify-adblock.so
  spotify &
  sleep 3
fi

qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri $2
eww close spotify