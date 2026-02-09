#!/bin/bash
# Script de Pós-Instalação Ubuntu 22.04 - Organizado
# shellcheck disable=SC1091,SC2002,SC2103,SC2164,SC2162,SC2181

# [ETAPA 1] - Validações Iniciais e Dependências Base
# ------------------------------------------------------------------------------
# Impedir execução como Root
if [ "$(id -u)" -eq 0 ]; then
    echo "Erro: Não execute este script com sudo direto. O script pedirá senha quando necessário."
    exit 1
fi

# Lock file - Evita execução duplicada
LOCKFILE="/tmp/pos_install.lock"
if [ -e "$LOCKFILE" ]; then
    echo "O script já está em execução ou foi interrompido incorretamente."
    exit 1
fi
touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT # Garante que o arquivo suma ao sair

# Verificação de Conexão com a Internet
echo "Verificando conexão com a internet..."
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "Sem conexão com a internet. Verifique sua rede e tente novamente."
    exit 1
fi
if ! ping -c 1 google.com &>/dev/null; then
    echo "Não pôde resolver nomes. Verifique sua rede e tente novamente."
    exit 1
fi

source /etc/lsb-release
sudo apt update -qq

echo "Iniciando configurações de base e segurança..."

# Pacotes essenciais para gerenciar repositórios e conexões seguras
# - apt-transport-https/ca-certificates: Suporte a download seguro
# - software-properties-common: Gerenciamento de PPAs
# - dirmngr/gnupg: Gerenciamento de chaves de segurança
sudo apt -y install curl apt-transport-https ca-certificates software-properties-common dirmngr

# Configuração do GPG Agent
sudo mkdir -m 700 -p /root/.gnupg
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Ajustes de sistema: Desativar avisos de upgrade e limpar referências de CD-ROM
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
sudo sed -i.bak '/^deb cdrom:/s/^/#/' /etc/apt/sources.list


# [ETAPA 2] - Adicionando Repositórios Externos (Chaves GPG e Listas)
# ------------------------------------------------------------------------------
echo "Adicionando repositórios externos (Browsers, Dev Tools, Remote Desktop)..."

# Função simples para adicionar chaves e repositórios (Reduz repetição no script)
# AnyDesk
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Google Chrome
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

# Microsoft Edge & VSCode
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/packages.microsoft.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# VSCodium (Telemetria-free VSCode)
curl -fSsL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/vscodium.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main" | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null

# NodeJS (Nodesource 22.x)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Atualiza após adicionar novos repositórios
sudo apt update


# [ETAPA 3] - Instalação de Aplicativos via APT
# ------------------------------------------------------------------------------
echo "Instalando pacotes nativos..."

# Desenvolvimento & Terminal
# - git/make: Compilação e controle de versão
# - jq/shfmt/shellcheck: Ferramentas para manipulação de JSON e scripts
sudo apt -y install git make jq shfmt shellcheck curl openssh-server sshpass

# Linguagens e Runtimes (NodeJS, Java)
sudo apt -y install nodejs default-jdk

# Navegadores e Ferramentas de Acesso Remoto
sudo apt -y install chromium-browser anydesk rustdesk
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y teamviewer -o Dpkg::Options::="--force-confold"

# Utilitários de Interface e Nautilus
# - dconf-editor: Configurações avançadas de GNOME
# - nautilus-admin: Abrir pastas como root pelo gerenciador de arquivos
sudo apt -y install dconf-editor nautilus-admin nautilus-image-converter python3-nautilus gtkhash

# Instalação VSCode e restauração de backup de extensões
sudo apt -y install code
mkdir -p "$HOME/.config/Code/User"
#curl -JLk -o /tmp/vscode_backup.tar.gz "https://github.com/elppans/vscodeum/raw/refs/heads/main/vscode_backup/vscode_backup_20250226_170128.tar.gz"
#tar -xzf /tmp/vscode_backup.tar.gz -C "$HOME"/.config/Code/User/
# Instala extensões listadas no backup
#xargs -L 1 code --install-extension < "$HOME/.config/Code/User/extensions_list.txt"

# Editor de texto kate
sudo apt -y install kate

# [ETAPA 4] - Flatpak e Snap
# ------------------------------------------------------------------------------
echo "Configurando Flatpak e Snap..."

# Flatpak e Repositório Flathub
sudo apt -y install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.rtosta.zapzap

# Snap (Apps clássicos e editores)
sudo snap install marktext
sudo snap install prettier --beta
# sudo snap install kate --classic


# [ETAPA 5] - Customizações (Templates e Nautilus Actions)
# ------------------------------------------------------------------------------
echo "Aplicando customizações de usuário..."

# Modelos de arquivos (Templates para o menu 'Novo Documento')
git clone https://github.com/elppans/ubuntu_file_templates.git /tmp/ubuntu_file_templates
cp -a /tmp/ubuntu_file_templates/* "$(xdg-user-dir TEMPLATES)"

# Actions for Nautilus (Menu de contexto personalizado)
cd /tmp && git clone https://github.com/elppans/actions-for-nautilus.git
cd actions-for-nautilus && sudo make install_global
mkdir -p "$HOME"/.local/share/actions-for-nautilus "$HOME"/.local/share/applications
cp -rf /usr/share/actions-for-nautilus-configurator/sample-config.json "$HOME"/.local/share/actions-for-nautilus/config.json
cp -rf /usr/share/applications/actions-for-nautilus-configurator.desktop "$HOME"/.local/share/applications
echo "NoDisplay=true" >> ~/.local/share/applications/actions-for-nautilus-configurator.desktop
nautilus -q


# [ETAPA 6] - Finalização do Sistema
# ------------------------------------------------------------------------------
echo "Limpando o sistema e atualizando pacotes finais..."

# Remove jogos inúteis instalados por padrão
sudo apt -y remove gnome-sudoku gnome-mahjongg gnome-mines aisleriot

# Atualização geral
sudo apt -y upgrade
sudo snap refresh

# Limpeza de cache
sudo apt -y autoremove
sudo apt clean

echo -e '\n\nConcluído! O sistema será reiniciado em 5 segundos...\n'
sleep 5
sudo reboot
