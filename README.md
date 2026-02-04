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

## Configuration Steps ##
(I couldn't figure out how to handle at runtime via systemd args)

- Add any non-root service accounts to the audio group:
  `usermod -G audio crossover`

- Put the local IPv4 address in a systemd environment file so that systemd can use it to launch camilladsp with a websocket listener:
  `echo "HOST_IP="$(hostname -I | awk "{print \$1}") | tee -a > /opt/crossover/environment`
  
- Enabling the websocket means CamillaGUI needs to be told to talk to CamillaDSP via the main IP, not loopback:
  `sed -i "s/127.0.0.1/$(hostname -I | awk "{print \$1}")/g" /opt/crossover/camillagui_backend/_internal/config/camillagui.yml`


## Running the Software ##

Check the target has been reached:

`sudo systemctl status audio-stack.target`

Check the status of the audio processes:
`sudo systemctl status audio.slice`


When running properly, the Roon Extensions screen will show  "Processing <guid_string> on connection 1"
Anything else like 'disconnected' isn't working.

Edit the Roon Zone / Audio Device Setup to use "CamillaDSP Volume/Mute Control:<Zone>" to control volume. This option is only visible when roon-extension-cdsp is running proper.


