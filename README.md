# camilladsp_crossover_config #

Configurations to run CamillaDSP v3 as a crossover with GUI and Volume control through Roon via websocket extension

All services run in an 'audio.slice' cgroup and with proper startup sequencing.  Notably:
 - camilladsp needs to include the `-address $HOST_IP` arg, or it will not open a listening websocket.
 - roon-extension-cdsp requires the camilladsp process to have opened a websocket on the main IPv4 interface.

requires:

`apt install vim bzip2 nodejs npm shairport-sync libsoxr-dev`

`curl -L https://github.com/vi/websocat/releases/latest/download/websocat.aarch64-unknown-linux-musl -o websocat
chmod +x websocat ;
sudo mv websocat /usr/local/bin/ ;
websocat --version`

Check the target has been reached:

`sudo systemctl status audio-stack.target`

Check the status of the audio processes:
`sudo systemctl status audio.slice`


When running properly, the Roon Extensions screen will show  "Processing <guid_string> on connection 1"
Anything else like 'disconnected' isn't working.

Edit the Roon Zone / Audio Device Setup to use "CamillaDSP Volume/Mute Control:<Zone>" to control volume. This option is only visible when roon-extension-cdsp is running proper.


