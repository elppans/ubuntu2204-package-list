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

# Team Viewer
curl -fSsL https://linux.teamviewer.com/pubkey/currentkey.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/teamview.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/teamview.gpg] http://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list > /dev/null

# Vivaldi
curl -fSsL https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi.gpg
echo -e 'deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main' | sudo tee /etc/apt/sources.list.d/vivaldi.list > /dev/null

# Opera
curl -fsSL https://deb.opera.com/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/opera.gpg
echo -e 'deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free' | sudo tee /etc/apt/sources.list.d/opera.list > /dev/null

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

# DBeaver
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg
echo "deb [arch=amd64] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null

# OpenFortiGUI App
# https://hadler.me/linux/openfortigui/ https://apt.iteas.at/
# sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 23CAE45582EB0928
gpg -k && sudo -S gpg --no-default-keyring --keyring /usr/share/keyrings/iteas-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 23CAE45582EB0928
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/iteas-keyring.gpg] https://apt.iteas.at/iteas ""$DISTRIB_CODENAME"" main" | sudo tee /etc/apt/sources.list.d/iteas.list >> /dev/null

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

# Dependências para outros pacotes
sudo apt -y install mtools freerdp2-x11

# Compactadores
sudo apt -y install p7zip-full p7zip-rar rar unrar

# Navegadores e Ferramentas de Acesso Remoto
sudo apt -y install chromium-browser anydesk rustdesk
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y teamviewer -o Dpkg::Options::="--force-confold"

# Utilitários de Interface e Nautilus
# - dconf-editor: Configurações avançadas de GNOME
# - meld: ferramenta gr�fica para diff e merge de arquivos
# - nautilus-admin: Abrir pastas como root pelo gerenciador de arquivos
sudo apt -y install dconf-editor nautilus-admin nautilus-image-converter python3-nautilus gtkhash meld

# Instalação VSCode e restauração de backup de extensões
sudo apt -y install code
# mkdir -p "$HOME/.config/Code/User"
#curl -JLk -o /tmp/vscode_backup.tar.gz "https://github.com/elppans/vscodeum/raw/refs/heads/main/vscode_backup/vscode_backup_20250226_170128.tar.gz"
#tar -xzf /tmp/vscode_backup.tar.gz -C "$HOME"/.config/Code/User/
# Instala extensões listadas no backup
#xargs -L 1 code --install-extension < "$HOME/.config/Code/User/extensions_list.txt"
curl -JLk -o /usr/local/bin/vscodeum-extensions "https://raw.githubusercontent.com/elppans/vscodeum/refs/heads/main/usr/local/bin/vscodeum-extensions"
sudo chmod +x /usr/local/bin/vscodeum-extensions

# Gerenciador de banco de dados
# sudo apt -y install dbeaver-ce # Movido para sessão Flatpak

# VPN openFortiGUI
sudo apt -y install openfortigui

# Editor de texto kate
# sudo apt -y install kate # Movido para sessão Flatpak

# [ETAPA 4] - Flatpak e Snap
# ------------------------------------------------------------------------------
echo "Configurando Flatpak e Snap..."

# Flatpak e Repositório Flathub
sudo apt -y install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.rtosta.zapzap
sudo flatpak install -y flathub com.github.marktext.marktext
sudo flatpak install -y flathub org.kde.kate
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

# --- INSTALAÇÃO DO WINE VIA FLATPAK ---

# RECOMENDADO: Versão 11.0 com tecnologia WOW64. 
# Permite rodar apps de 32 bits em sistema 64 bits sem instalar bibliotecas i386 extras no Ubuntu.
sudo flatpak install flathub org.winehq.Wine//wow64-25.08 -y

# ALTERNATIVO: Versão 11.0 Estável Tradicional. 
# Exige que o sistema tenha bibliotecas de 32 bits instaladas para rodar programas Windows de 32 bits.
# flatpak install flathub org.winehq.Wine//stable-25.08 -y

echo -e '#!/bin/bash\n/usr/bin/flatpak run org.winehq.Wine $@\n' | sudo tee /usr/local/bin/wine
echo -e '#!/bin/bash\n/usr/bin/flatpak run --command=winetricks org.winehq.Wine $@\n' | sudo tee /usr/local/bin/winetricks
sudo chmod +x /usr/local/bin/wine /usr/local/bin/winetricks

# Snap (Apps clássicos e editores)
# sudo snap install marktext # Movido para sessão Flatpak
sudo snap install prettier --beta
# sudo snap install kate --classic


# [ETAPA 5] - Customizações (Templates e Nautilus Actions)
# ------------------------------------------------------------------------------
echo "Aplicando customizações de usuário..."

# Modelos de arquivos (Templates para o menu 'Novo Documento')
git clone https://github.com/elppans/ubuntu_file_templates.git /tmp/ubuntu_file_templates
cp -a /tmp/ubuntu_file_templates/* "$(xdg-user-dir TEMPLATES)"

# Action Scripts para conversão de imagens
git clone https://github.com/elppans/el-images.git /tmp/imagens
cd /tmp/imagens
./install.sh

# Actions for Nautilus (Menu de contexto personalizado)
cd /tmp && git clone https://github.com/elppans/actions-for-nautilus.git
cd actions-for-nautilus && sudo make install_global
mkdir -p "$HOME"/.local/share/actions-for-nautilus "$HOME"/.local/share/applications
cp -rf /usr/share/actions-for-nautilus-configurator/sample-config.json "$HOME"/.local/share/actions-for-nautilus/config.json
cp -rf /usr/share/applications/actions-for-nautilus-configurator.desktop "$HOME"/.local/share/applications
echo "NoDisplay=true" >> ~/.local/share/applications/actions-for-nautilus-configurator.desktop
nautilus -q

# Ajustes de configurações via dconf

# Configurações do Nautilus
# Ativa a opção para mostrar a criação de links e exclusão permanente no Nautilus
dconf write /org/gnome/nautilus/preferences/show-create-link true
# dconf write /org/gnome/nautilus/preferences/show-delete-permanently true

# Ajustes de configurações via gsettings

# Configurações gerais do Gnome
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.shell.weather automatic-location true

# Ajustes de configurações de terceiros

# Desativando aviso de update do DBeaver, apt/snap/flatpak
mkdir -p "$HOME"/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/
mkdir -p "$HOME"/.var/app/io.dbeaver.DBeaverCommunity/data/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/
mkdir -p "$HOME"/snap/dbeaver-ce/current/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/
# sed -i 's/ui.auto.update.check=true/ui.auto.update.check=false/g' "$HOME"/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
# sed -i 's/ui.auto.update.check=true/ui.auto.update.check=false/g' "$HOME"/.var/app/io.dbeaver.DBeaverCommunity/data/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
# sed -i 's/ui.auto.update.check=true/ui.auto.update.check=false/g' "$HOME"/snap/dbeaver-ce/current/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
echo "ui.auto.update.check=false" | tee -a "$HOME"/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
echo "ui.auto.update.check=false" | tee -a "$HOME"/.var/app/io.dbeaver.DBeaverCommunity/data/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
echo "ui.auto.update.check=false" | tee -a "$HOME"/snap/dbeaver-ce/current/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs

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

echo -e '\n\n'
for i in `seq 5 -1 1` ; do echo -ne "Concluído! O sistema será reiniciado em $i Segundos.\r" ; sleep 1 ; done
echo
sudo reboot
