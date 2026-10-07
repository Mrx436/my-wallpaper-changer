#!/run/current-system/sw/bin/bash
max_open_windows=3
window_count=""
pid_mpv=-1
pid_swaybd=-1
while true; 
do
  window_count=$(swaymsg -t get_tree | jq '[.. | objects | select(.type? == "con" and .app_id? != null or .window? != null)] | length')
  workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
  workspace_is_free=$(swaymsg -t get_tree | jq \
    --arg ws "1" \
    '[.. | objects
      | select(.type? == "workspace" and .name? == $ws)
      | .. | objects
      | select(.type? == "con" and (.app_id? != null or .window? != null))
    ] | length')
echo "workspace: $workspace"
  echo "window count: $window_count"
  if [ $window_count -lt $max_open_windows ] && [ $workspace -eq 1 ] && [ $workspace_is_free -eq 0 ]; then
    if [ $pid_swaybd -gt 0 ] && [[ $(pgrep "swaybg") ]]; then
       kill $pid_swaybd
       pid_swaybd=-1
    elif [ $pid_swaybd -lt 0 ] && [[ $(pgrep "swaybg") ]]; then
      kill "$(pgrep "swaybg")"
      pid_swaybd=-1
    fi
    echo "pid mpv: $pid_mpv"
    echo "real pid: $(pgrep "mpvpaper")"

    if [ $pid_mpv -lt 0 ] && [[ ! $(pgrep "mpvpaper") ]]; then
       mpvpaper -f -v -s -o "no-audio loop" eDP-1 /nix/store/3494wk2ga1mh1qn7a7f657p3dg2k4ap9-my_wallpaperes-v1.0/my_wallpaperes/torii-gate-forest-moewalls-com.mp4
       pid_mpv=$(pgrep "mpvpaper")
    elif [ $pid_mpv -gt 0 ] && [[ ! $(pgrep "mpvpaper") ]]; then
       pid_mpv=-1
    fi

  else
    if [ $pid_mpv -gt 0 ] && [[ $(pgrep "mpvpaper") ]]; then
       kill $pid_mpv
       pid_mpv=-1
    elif [ $pid_mpv -lt 0 ] && [[ $(pgrep "mpvpaper") ]]; then
       kill "$(pgrep "mpvpaper")"
       pid_mpv=-1 
    fi

    if [ $pid_swaybd -lt 0 ] && [[ ! $(pgrep "swaybg") ]]; then
       /nix/store/sc16ai4l1270vjwv9lmm5qd3qjmji15a-swaybg-1.2.2/bin/swaybg -o '*' -i /nix/store/3494wk2ga1mh1qn7a7f657p3dg2k4ap9-my_wallpaperes-v1.0/my_wallpaperes/night-landscape-illustration.jpg &
       pid_swaybg=$(pgrep "swaybg")
    elif [ $pid_swaybd -gt 0 ] && [[ ! $(pgrep "swaybg") ]]; then
       pid_swaybg=-1
    fi

  fi
  echo "Fertig"
  sleep 5
done
