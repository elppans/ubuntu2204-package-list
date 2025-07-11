#!/bin/bash
# shellcheck disable=SC1091,SC2002,SC2103,SC2164,SC2162,SC2181

if [ "$(id -u)" -eq 0 ]; then
    echo "Erro: Este script não deve ser executado como root ou sudo."
    exit 1
fi

source /etc/lsb-release

# ___ Configurações do sistema
sudo echo
echo "Configurações do sistema em andamento. Por favor, aguarde enquanto aplicamos as atualizações e ajustes necessários..."
echo "Após as configurações, o computador será reiniciado!"

# Atualiza a lista de pacotes em modo silencioso
sudo apt update -qq

# apt-transport-https: permite que o gerenciador de pacotes APT acesse repositórios via protocolo HTTPS. Sem ele, o APT só consegue usar HTTP, que não é seguro.
# dirmngr: é um componente necessário para gerenciar e baixar certificados e chaves públicas (normalmente para repositórios APT que usam assinaturas GPG).
# software-properties-common: fornece ferramentas como o add-apt-repository, que facilita adicionar repositórios PPA e outras fontes de software.
# ca-certificates: contém certificados digitais de autoridades certificadoras confiáveis, o que permite conexões seguras com servidores HTTPS.

sudo apt -y install curl apt-transport-https ca-certificates software-properties-common 

# GNU privacy guard - serviço de gerenciamento de certificados de rede
sudo apt -y install dirmngr
sudo mkdir -m 700 -p /root/.gnupg
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Configurar a opção "Notificar-me de uma nova versão do Ubuntu" como "Nunca"
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Desativar a verificação de atualizações de segurança do Ubuntu Pro
# Comenta as linhas do arquivo após ele ter sido criado e preenchido pelo apt update
sudo sed -i 's/^/#/' /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/*esm*.sources

# Comenta a linha que faz referência ao CD-ROM no arquivo de fontes de pacotes
sudo sed -i.bak '/^deb cdrom:/s/^/#/' /etc/apt/sources.list

# Adicionar repositório de terceiros

# Anydesk
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Team Viewer
curl -fSsL https://linux.teamviewer.com/pubkey/currentkey.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/teamview.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/teamview.gpg] http://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list > /dev/null

# Google Chrome
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo -e 'deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

# Vivaldi
curl -fSsL https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi.gpg
echo -e 'deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main' | sudo tee /etc/apt/sources.list.d/vivaldi.list > /dev/null

# Opera
curl -fsSL https://deb.opera.com/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/opera.gpg
echo -e 'deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free' | sudo tee /etc/apt/sources.list.d/opera.list > /dev/null

# Microsoft Edge
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/packages.microsoft.gpg
echo -e 'deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

# VSCode
echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# VSCodium
curl -fSsL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/vscodium.gpg
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null

# DBeaver
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg
echo "deb [arch=amd64] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null

# OpenFortiGUI App
# https://hadler.me/linux/openfortigui/ https://apt.iteas.at/
# sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 23CAE45582EB0928
gpg -k && sudo -S gpg --no-default-keyring --keyring /usr/share/keyrings/iteas-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 23CAE45582EB0928
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/iteas-keyring.gpg] https://apt.iteas.at/iteas ""$DISTRIB_CODENAME"" main" | sudo tee /etc/apt/sources.list.d/iteas.list >> /dev/null

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

# Atualização da lista de repositórios
sudo apt update

# ___ Instalação de aplicativos

echo "Instalação dos aplicativos em andamento. Por favor, aguarde enquanto concluímos a configuração do sistema..."
sleep 3

# ___ Instalação do Flatpak

# Infraestrutura de distribuição de aplicações para apps de desktop Flatpak
sudo apt -y install flatpak

# Flatpak support for GNOME Software
# sudo apt -y install gnome-software-plugin-flatpak
sudo apt -y remove gnome-software

# Repositório do Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ___ Instalação de pacotes via APT

# Remoção de jogos inúteis
sudo apt -y remove gnome-sudoku gnome-mahjongg gnome-mines aisleriot

# Editor DConf
sudo apt -y install dconf-editor

# Servidor SSH (Opcional)
sudo apt -y install openssh-server

# Pacotes para download de repositórios sources
sudo apt -y install apt-file curl git make
sudo apt-file update

# processador JSON de linha de comando, leve e flexível
sudo apt -y install jq

# formatador, analisador e interpretador de shell
sudo apt -y install shfmt

# Pacotes para aplicativos Windows
sudo apt -y install wine winetricks

# Front-end FFmpeg GUI baseado em Qt5 e escrito em C++
sudo apt -y install mystiq

# Unetbootin, criação de pendrive bootável
curl -JLk -o /tmp/unetbootin_github-install.sh https://raw.githubusercontent.com/elppans/customshell/refs/heads/master/unetbootin_github-install.sh
bash /tmp/unetbootin_github-install.sh

# Extensões para o Nautilus
sudo apt -y install nautilus-admin nautilus-image-converter python3-nautilus

# Nautilus-Status-Bar-Replacement
sudo mkdir -p /usr/share/nautilus-python/extensions
sudo curl -JLk -o /usr/share/nautilus-python/extensions/DiskUsageLocationWidget.py "https://raw.githubusercontent.com/elppans/Nautilus-Status-Bar-Replacement/refs/heads/master/DiskUsageLocationWidget.py"

# Actions for Nautilus
# mkdir -p ~/build
cd /tmp
sudo apt -y install python3-nautilus python3-gi procps libjs-jquery baobab meld xclip zenity

git clone https://github.com/elppans/actions-for-nautilus.git
cd actions-for-nautilus
sudo make install_global
mkdir -p "$HOME"/.local/share/actions-for-nautilus
cp /usr/share/actions-for-nautilus-configurator/sample-config.json "$HOME"/.local/share/actions-for-nautilus/config.json
nautilus -q

# Stylelint
sudo curl -JLk -o /var/cache/apt/archives/stylelint.deb "https://github.com/elppans/stylelint_makedeb/raw/refs/heads/main/deb/stylelint_16.10.0-1_amd64.deb"
sudo apt -y install /var/cache/apt/archives/stylelint.deb
echo -e '#!/usr/bin/env bash

PATH=/snap/bin:$PATH
/usr/bin/stylelint "$@"
' | sudo tee /usr/local/bin/stylelint &>>/dev/null
sudo chmod +x /usr/local/bin/stylelint

# https://www.teamviewer.com/pt-br/download/linux/
# sudo curl -JLk -o /var/cache/apt/archives/teamviewer_amd64.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
# sudo apt -y install /var/cache/apt/archives/teamviewer_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y teamviewer -o Dpkg::Options::="--force-confold"

# Anydesk
https://anydesk.com/pt/downloads/linux
sudo apt -y install anydesk

# Rustdesk
sudo apt -y install rustdesk

# Navegadores
sudo apt -y install microsoft-edge-stable
sudo apt -y install google-chrome-stable
sudo apt -y install vivaldi-stable

echo "opera-stable opera-stable/add-debian-repo boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y opera-stable

# VSCode/VSCodium
sleep 5
# clear
echo
echo "Instalação de editor de código-fonte."
echo
echo "Escolha uma opção para instalar:"
echo "1 - Visual Studio Code"
echo "2 - VSCodium"
read -p "Digite o número da opção desejada (pressione ENTER para Nenhum): " opcao
case $opcao in
  1)
    echo "Instalando Visual Studio Code..."
    sudo apt -y install code && export VSCODE="1" || echo "VSCode não pôde ser instalado"
    ;;
  2)
    echo "Instalando VSCodium..."
    sudo apt -y install codium && export VSCODIUM="1" || echo "VSCodium não pôde ser instalado"
    ;;
  *)
      echo "Não será instalado nenhuma das opções!"
      echo "Prosseguindo com a instalação de aplicativos..."
      sleep 5
    ;;
esac

# DBeaver
sudo apt -y install dbeaver-ce

# Java padrão (OpenJDK Runtime Environment - 11.0.27+)
sudo apt -y install default-jdk

# OpenFortiGUI App
sudo apt -y install openfortigui

# Download Cisco Secure Client, Version 5.1.6.103
# Site: https://ftp.uni-weimar.de/
# Cisco Secure Client für Linux 64bit (RPM installer)
# https://ftp.uni-weimar.de/cisco-secure-client-linux64-5.1.6.103-predeploy-k9.tar.gz
# Cisco Secure Client für Linux 64bit (DEB installer)
# https://ftp.uni-weimar.de/cisco-secure-client-linux64-5.1.6.103-predeploy-deb-k9.tar.gz
# Alternativa (https://helpdesk.ugent.be/vpn/, https://www.aim.aoyama.ac.jp/network/vpn/)
# https://www.aim.aoyama.ac.jp/files/vpn/cisco-secure-client-linux64-5.1.6.103-predeploy-k9.tar.gz
curl -JLk -o /tmp/cisco-secure-client-linux64.tr.gz "https://ftp.uni-weimar.de/cisco-secure-client-linux64-5.1.6.103-predeploy-deb-k9.tar.gz"
sudo tar -zxf /tmp/cisco-secure-client-linux64.tr.gz -C /var/cache/apt/archives/
sudo rm -rf /var/cache/apt/archives/CiscoSystemsInc.pgp
sudo apt install /var/cache/apt/archives/cisco-secure-client-vpn_5.1.6.103_amd64.deb 
sudo systemctl enable --now vpnagentd
# systemctl status vpnagentd

# Utilitários X11
sudo apt -y install x11-utils

# ___ Instalação de pacotes via SNAP

# Função para instalar pacotes via snap
install_snap() {
    local package=$1
    local failed_apps_file="/tmp/failed_snap_installations.txt"

# Verifica se o aplicativo requer a flag --classic
if snap info "$package" | grep -q "classic"; then
    sudo snap install "$package" --classic
    export SNAPBETA="0"
    export SNAPSTABLE="0"
else
	export SNAPBETA="1"
	export SNAPSTABLE="0"
fi

if [ "$SNAPBETA" -eq 1 ]; then
    # Verifica se o aplicativo pode ser instalado a partir do canal beta
    if snap info "$package" | grep -q "beta"; then
        sudo snap install "$package" --beta
		export SNAPSTABLE="0"
	else
	export SNAPSTABLE="1"
    fi
fi

if [ "$SNAPSTABLE" -eq 1 ]; then
	# Tenta instalar no modo padrão
    sudo snap install "$package"
    if [[ $? -ne 0 ]]; then
        echo "$package" >> "$failed_apps_file"
        echo "Não foi possível instalar o pacote $package"
    fi
fi
}

# Remove o arquivo de aplicativos que falharam anteriormente
rm -f "/tmp/failed_snap_installations.txt"

# Lista de aplicativos para instalar via snap
# apps=("aplicativo1" "aplicativo2" "aplicativo3")

# for app in "${apps[@]}"; do
#     install_snap "$app"
# done

install_snap marktext
# install_snap vivaldi # Movido para instalação via apt
# install_snap opera # Movido para instalação via apt
install_snap gtkhash
install_snap node
install_snap shellcheck
# install_snap shfmt # Esta versão tem falha, a nativa está tudo OK
install_snap prettier
# install_snap dbeaver-ce # Movido para instalação via apt

# Editor de desenvolvimento
# O Visual Studio Code (VSCode) é a versão oficial da Microsoft,
# O VSCodium é uma versão 'liberada' do VSCode sem os componentes de telemetria da Microsoft.
# Veja mais em: https://github.com/elppans/vscodeum

# install_snap code && export VSCODE="1" # "Instalando VSCode..."
# install_snap codium && export VSCODIUM="1" # "Instalando VSCodium..." # Movido para a instalação via apt

# Configuração do VSCode
if [ "$VSCODE" -eq 1 ]; then
    echo "VSCode selecionado! Executando configuração..."
	cd
    mkdir -p "$HOME/.config/Code/User"
	# Removido o Download do pacote de backup do VSCode
	# tar -xzf /tmp/vscodium_backup.tar.gz -C "$HOME/.config/Code/User/
	#cat "$HOME/.config/Code/User/extensions_list.txt | xargs -L 1 codium --install-extension
fi

# Configuração do VSCodium
if [ "$VSCODIUM" -eq 1 ]; then
    echo "VSCodium selecionado! Executando configuração..."
	cd
	mkdir -p "$HOME/.config/VSCodium/User"
	curl -JLk -o /tmp/vscodium_backup.tar.gz "https://github.com/elppans/vscodeum/raw/refs/heads/main/vscodium_backup/vscodium_backup_20250226_170128.tar.gz"
	tar -xzf /tmp/vscodium_backup.tar.gz -C "$HOME"/.config/VSCodium/User/
	cat "$HOME"/.config/VSCodium/User/extensions_list.txt | xargs -L 1 codium --install-extension
fi

# ___ Instalação de pacotes via FLATPAK

# sudo flatpak install -y flathub com.google.Chrome # Movido para instalação via apt
# sudo flatpak install -y flathub com.microsoft.Edge # Movido para instalação via apt
sudo flatpak install -y flathub org.kde.kate
# sudo flatpak install -y flathub com.anydesk.Anydesk # A versão nativa não trava
# sudo flatpak install -y flathub com.rustdesk.RustDesk # Movido para instalação via apt
sudo flatpak install -y flathub com.rtosta.zapzap

# ___ Instalação usando Scripts customizados

# Action Script, conversão de imagens
git clone https://github.com/elppans/el-images.git /tmp/el-images
cd /tmp/el-images
./install.sh
cd - || exit 1

# Actions Scripts
git clone https://github.com/elppans/factions-shell.git /tmp/factions-shell
cd /tmp/factions-shell
./install.sh
cd - || exit 1

# Bitvise (OPCIONAL). Free SSH file transfer, terminal e tunelamento
# cd /tmp
# wget -c https://raw.githubusercontent.com/elppans/customshell/master/wbvsshclient_arch-inst.sh  && \
# chmod +x wbvsshclient_arch-inst.sh && \
# ./wbvsshclient_arch-inst.sh

# Compilador de codigo fonte baseado no makepkg (Archlinux), makedeb - AVANÇADO
# cd /tmp
# export MAKEDEB_RELEASE='makedeb-alpha'
# bash -c "$(wget -qO - 'https://shlink.makedeb.org/install')"

# Modelos de arquivos
git clone https://github.com/elppans/ubuntu_file_templates.git /tmp/ubuntu_file_templates
cp -a /tmp/ubuntu_file_templates/* "$(xdg-user-dir TEMPLATES)"
rm -rf /tmp/ubuntu_file_templates

# ___ Extenções Gnome

# Extenção Unite v72 para Ubuntu 22.04, Gnome 42.9
# Unite faz o GNOME Shell parecer com o Ubuntu Unity Shell
# https://github.com/hardpixel/unite-shell
# https://extensions.gnome.org/extension/1287/unite/
# https://aur.archlinux.org/packages/gnome-shell-extension-unite
# Exportar a configuração da extenção
# dconf dump /org/gnome/shell/extensions/unite/ > unite-extensions-settings.conf
# Importar a configuração da extenção em outro sistema
# dconf load /org/gnome/shell/extensions/unite/ < unite-settings.conf

# Dependência: x11-utils

# Download da extenção
wget -P /tmp -c https://github.com/hardpixel/unite-shell/releases/download/v72/unite-shell-v72.zip

# Instalação para um usuário
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
unzip -o /tmp/unite-shell-v72.zip -d "$HOME/.local/share/gnome-shell/extensions"

# Instalação no sistema, para todos os usuários
# unzip -o /tmp/unite-shell-v72.zip -d /usr/share/gnome-shell/extensions

# Ativação da extenção, sem deslogar e logar (para um usuário)
# Se a extenção não for ativada e aparecer na lista, deve deslogar e logar
gnome-extensions install "$HOME/.local/share/gnome-shell/extensions/unite@hardpixel.eu"

# Importar as configurações (salvo no github)
curl -JLk -o /tmp/unite-settings.conf "https://raw.githubusercontent.com/elppans/ubuntu2204-package-list/refs/heads/main/unite-extensions-settings.conf"
dconf load /org/gnome/shell/extensions/unite/ < /tmp/unite-settings.conf

# Ativar a extenção
gnome-extensions enable "unite@hardpixel.eu"

# ___

# Atualização do sistema

sudo apt -y upgrade
sudo snap refresh

# Limpeza do sistema
sudo apt clean
sudo apt autoclean
sudo apt -y autoremove

echo -e '\n\nConfigurações finalizadas, reiniciando o computador em alguns segundos...\n\n'
sleep 5
sudo reboot
