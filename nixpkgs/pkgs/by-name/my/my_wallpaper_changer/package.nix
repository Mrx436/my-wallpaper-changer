{ stdenv, config, pkgs, lib,... }:

let
  #pkgs = import nixpkgs { system = "x86_64-linux"; };
  wallpaper_path = "/nix/store/6a09imb0zs13bz5av7wpjrx1vdy06p0r-my_wallpaperes-v1.1/my_wallpaperes/";
  wallpaper_live = "azure-horizon.1920x1080.mp4";
  wallpaper_pic = "night-landscape-illustration.jpg";
  swaybg_bin = "${pkgs.swaybg}/bin/swaybg";
  mpvpaper_bin = "${pkgs.mpvpaper}/bin/mpvpaper"; 
in
stdenv.mkDerivation rec {
   pname = "my_wallpaper_changer";
   version = "v0.1";
   src = pkgs.writeShellScriptBin "my_wallpaper_changer" ''
max_open_windows=5
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
       ${mpvpaper_bin} -f -v -s -o "no-audio loop" eDP-1 ${wallpaper_path}${wallpaper_live} 
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
       ${swaybg_bin} -o '*' -i "${wallpaper_path}${wallpaper_pic}" &
       pid_swaybg=$(pgrep "swaybg")
    elif [ $pid_swaybd -gt 0 ] && [[ ! $(pgrep "swaybg") ]]; then
       pid_swaybg=-1
    fi

  fi
  echo "Fertig"
  sleep 5
done
   '';

  installPhase = ''
    mkdir -p $out/bin/
    cp -r . $out/
  '';

  meta = with lib; {
    description = "My Wallpaperes";
    homepage = "https://github.com/Mrx436/My_Wallpaperes";
    #license = licenses.mit;
    #platforms = platforms.unix;
  };
}
