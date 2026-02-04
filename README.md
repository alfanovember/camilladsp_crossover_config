# camilladsp_crossover_config #

Configurations to run CamillaDSP v3 as a crossover with GUI and Volume control through Roon via websocket extension. 
Hardware is Armbian v25.11.2 for Odroid C4 running Armbian Linux 6.12.58-current-meson64.  Packages: Ubuntu stable (noble)

All services are installed under `/opt`

Several services run under the service account "crossover", which has the home directory `/opt/crossover`

All services run in an 'audio.slice' cgroup and with proper startup sequencing.  Notably:
 - camilladsp needs to include the `-address $HOST_IP` arg, or it will not open a listening websocket.
 - roon-extension-cdsp requires the camilladsp process to have opened a websocket on the main IPv4 interface.

## Requires: ##
Packages:
```
apt install -y vim bzip2 nodejs npm shairport-sync libsoxr-dev yq
```
websocat so roon-extension-cdsp can validate camilladsp websocket is up & running:
```
curl -L https://github.com/vi/websocat/releases/latest/download/websocat.aarch64-unknown-linux-musl -o websocat
chmod +x websocat 
sudo mv websocat /usr/local/bin/ 
websocat --version
```
Service Account:
```
useradd -d /opt/crossover/ -G audio crossover
```

## Install Software ##

- Roonbridge
- Camilladsp
- Camillagui
- Roon-extension-cdsp

## Configuration Steps ##
(I.E. Things I couldn't figure out how to handle at runtime via systemd args)


- Put the local IPv4 address in a systemd environment file so that systemd can use it to launch camilladsp with a websocket listener:
  ```
  echo "HOST_IP="$(hostname -I | awk "{print \$1}") | tee -a > /opt/crossover/environment
  ```
  
- Enabling the websocket means CamillaGUI needs to be told to talk to CamillaDSP via the main IP, not loopback:
  ```
  cp /opt/crossover/camillagui_backend/_internal/config/camillagui.yml /opt/crossover/camillagui_backend/_internal/config/camillagui.orig
  sed -i "s/127.0.0.1/$(hostname -I | awk "{print \$1}")/g" /opt/crossover/camillagui_backend/_internal/config/camillagui.yml
  ```

- Alternate technique - Use yq to assign the IP value to the camilla_host key:
  ```
  IP=$(ip -4 route get 1.1.1.1 | awk '{print $7; exit}')
  yq -y -i ".camilla_host = \"${IP}\"" /opt/crossover/camillagui_backend/_internal/config/camillagui.yml
  ```
(yq is the "better way" to manipulate YAML files safely, but it's kinda heavy)

- The CamillaGUI config file uses "~" relative path indicators, which is the home directory for the UID the service is running as.  I don't love this; it adds a layer of confusion to troubleshooting and silently changes when you're trying to debug by running as root or whathaveyou.

  ```
  sed -i 's|~/|/opt/crossover/|g' /opt/crossover/camillagui_backend/_internal/config/camillagui.yml
  ```

## Running the Software ##

Check the target has been reached:

`sudo systemctl status audio-stack.target`

Check the status of the audio processes:
`sudo systemctl status audio.slice`


When running properly, the Roon Extensions screen will show  "Processing <guid_string> on connection 1"
Anything else like 'disconnected' isn't working.

Edit the Roon Zone / Audio Device Setup to use "CamillaDSP Volume/Mute Control:<Zone>" to control volume. This option is only visible when roon-extension-cdsp is running proper.

## Troubleshooting ##

- Check that the service account is a member of the 'audio' group
- Try moving the statefile.yml  aside, or at least check the config_path is correct
- Check the ip address is correct in the roon-extension config.json file
- Check the ip in camillagui.yml
- CamillaDSP needs to access the audio devices and open a websocket, easiest to run as root.
- CamillaGUI can run as non-root
- roon-extension-cdsp runs as root (haven't tried alternate)

