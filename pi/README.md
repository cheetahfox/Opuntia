# Pi Setup

In-container setup

Install Pi

```bash
curl -fsSL https://pi.dev/install.sh | sh
```

export the path and get the models setup

```bash
export PATH="/home/ubuntu/.local/share/pi-node/node-v22.23.0-linux-x64/bin:$PATH"
cp pi/models.json /home/ubuntu/.pi/agent/models.json
cp pi/settings.json /home/ubuntu/.pi/agent/settings.json
```

