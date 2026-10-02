#!/run/current-system/sw/bin/bash
max_open_windows=5
window_count=""
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
    #pkill swaybg 2>/dev/null
    pidof mpvpaper>/dev/null || mpvpaper -vs -o "no-audio" eDP-1 /nix/store/3494wk2ga1mh1qn7a7f657p3dg2k4ap9-my_wallpaperes-v1.0/my_wallpaperes/torii-gate-forest-moewalls-com.mp4
  else
    pkill mpvpaper 2>/dev/null
    pidof /nix/store/sc16ai4l1270vjwv9lmm5qd3qjmji15a-swaybg-1.2.2/bin/swaybg>/dev/null || /nix/store/sc16ai4l1270vjwv9lmm5qd3qjmji15a-swaybg-1.2.2/bin/swaybg -o '*' -i /nix/store/3494wk2ga1mh1qn7a7f657p3dg2k4ap9-my_wallpaperes-v1.0/my_wallpaperes/night-landscape-illustration.jpg -m fill &
    echo "Fertig"
  fi
  sleep 5
done
