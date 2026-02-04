# camilladsp_crossover_config #

Configurations to run CamillaDSP v3 as a crossover with GUI and Volume control through Roon via websocket extension

All services are installed under `/opt`

Several services run under the service account "crossover", which has the home directory `/opt/crossover`

All services run in an 'audio.slice' cgroup and with proper startup sequencing.  Notably:
 - camilladsp needs to include the `-address $HOST_IP` arg, or it will not open a listening websocket.
 - roon-extension-cdsp requires the camilladsp process to have opened a websocket on the main IPv4 interface.

requires:

`apt install vim bzip2 nodejs npm shairport-sync libsoxr-dev yq`

`curl -L https://github.com/vi/websocat/releases/latest/download/websocat.aarch64-unknown-linux-musl -o websocat
chmod +x websocat ;
sudo mv websocat /usr/local/bin/ ;
websocat --version`

`useradd -d /opt/crossover/ crossover`

## Configuration Steps ##
(I couldn't figure out how to handle at runtime via systemd args)

- Add any non-root service accounts to the audio group:
  `usermod -G audio crossover`

- Put the local IPv4 address in a systemd environment file so that systemd can use it to launch camilladsp with a websocket listener:
  `echo "HOST_IP="$(hostname -I | awk "{print \$1}") | tee -a > /opt/crossover/environment`
  
- Enabling the websocket means CamillaGUI needs to be told to talk to CamillaDSP via the main IP, not loopback:
  `sed -i "s/127.0.0.1/$(hostname -I | awk "{print \$1}")/g" /opt/crossover/camillagui_backend/_internal/config/camillagui.yml`

- Or use yq to assign the IP value to the camilla_host key:

 `IP=$(ip -4 route get 1.1.1.1 | awk '{print $7; exit}')`
 `yq -y -i ".camilla_host = \"${IP}\"" /opt/crossover/camillagui_backend/_internal/config/camillagui.yml`


## Running the Software ##

Check the target has been reached:

`sudo systemctl status audio-stack.target`

Check the status of the audio processes:
`sudo systemctl status audio.slice`


When running properly, the Roon Extensions screen will show  "Processing <guid_string> on connection 1"
Anything else like 'disconnected' isn't working.

Edit the Roon Zone / Audio Device Setup to use "CamillaDSP Volume/Mute Control:<Zone>" to control volume. This option is only visible when roon-extension-cdsp is running proper.

## Troubleshooting ##

- Try moving the statefile.yml  aside, or at least check the config_path is correct
- Check the ip address is correct in the roon-extension config.json file
- Check the ip in camillagui.yml
- CamillaDSP needs to access the audio devices and open a websocket, easiest to run as root.
- CamillaGUI can run as non-root
- roon-extension-cdsp runs as root (haven't tried alternate)

