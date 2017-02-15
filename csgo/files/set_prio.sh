for p in $(pgrep srcds_linux); do renice -20 -p $p; done
