#!/usr/bin/env bash

# -- Diretório sources.list.d --
#!/bin/bash

DIR="/etc/apt/sources.list.d"
BACKUP_DIR="/etc/apt/sources.list.d-backup-$(date +%Y%m%d%H%M%S)"

# Verifica se o diretório existe e tem conteúdo
if [ -d "$DIR" ] && [ "$(ls -A $DIR)" ]; then
    echo "Fazendo backup do diretório \"$DIR\"..."
    
    # Cria o diretório de backup
    mkdir -p "$BACKUP_DIR"
    
    # Move os arquivos para o backup
    mv "$DIR"/* "$BACKUP_DIR"/
    
    echo "Backup concluído em $BACKUP_DIR."
    echo "Diretório $DIR foi esvaziado."
fi


# -- Arquivo sources.list --
sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup_"$(date +%Y%m%d%H%M)"

sudo tee /etc/apt/sources.list <<'EOF'
deb http://br.archive.ubuntu.com/ubuntu/ jammy main universe restricted
deb http://br.archive.ubuntu.com/ubuntu/ jammy-updates main universe restricted
deb http://br.archive.ubuntu.com/ubuntu/ jammy-security main universe restricted
EOF

# -- Pacotes do sistema --
sudo apt update
sudo apt --fix-broken install
sudo apt install --reinstall ubuntu-desktop gdm3 -y
sudo dpkg-reconfigure gdm3
sudo systemctl set-default graphical.target
sudo apt install -f
# sudo systemctl start gdm3
sudo apt upgrade -y
sudo apt clean
sudo apt autoclean
sudo apt autoremove

sleep 15
sudo systemctl reboot -i
