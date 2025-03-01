#!/bin/bash

# ___ Configurações do sistema

# Ativa a opção para mostrar a criação de links e exclusão permanente no Nautilus
dconf write /org/gnome/nautilus/preferences/show-create-link true
dconf write /org/gnome/nautilus/preferences/show-delete-permanently true

# Configurar a opção "Notificar-me de uma nova versão do Ubuntu" como "Nunca"
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Desativar a verificação de atualizações de segurança do Ubuntu Pro
sudo sed -i 's/^/#/' /var/lib/ubuntu-advantage/apt-esm/etc/apt/sources.list.d/*esm*.sources

# Comenta a linha que faz referência ao CD-ROM no arquivo de fontes de pacotes
sudo sed -i.bak '/^deb cdrom:/s/^/#/' /etc/apt/sources.list

# Atualização da lista de repositórios
sudo apt update

# ___ Instalação do Flatpak

# Infraestrutura de distribuição de aplicações para apps de desktop Flatpak
sudo apt -y install flatpak

# Flatpak support for GNOME Software
sudo apt -y install gnome-software-plugin-flatpak

# Repositório do Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ___ Instalação de pacotes via APT

# Remoção de jogos inúteis
sudo apt -y remove gnome-sudoku gnome-mahjongg gnome-mines aisleriot

# Servidor SSH (Opcional)
sudo apt -y install openssh-server

# Pacotes para download de repositórios sources
sudo apt -y install apt-file curl git make
sudo apt-file update

# Pacotes para aplicativos Windows
sudo apt -y install wine winetricks

# Front-end FFmpeg GUI baseado em Qt5 e escrito em C++
sudo apt -y install mystiq

# Extensões para o Nautilus
sudo apt -y install nautilus-admin nautilus-image-converter python3-nautilus

# Nautilus-Status-Bar-Replacement
sudo mkdir -p /usr/share/nautilus-python/extensions
sudo curl -JLk -o /usr/share/nautilus-python/extensions/DiskUsageLocationWidget.py "https://raw.githubusercontent.com/elppans/Nautilus-Status-Bar-Replacement/refs/heads/master/DiskUsageLocationWidget.py"

# Actions for Nautilus
mkdir -p ~/build
cd ~/build
sudo apt -y install python3-nautilus python3-gi procps libjs-jquery baobab xclip zenity

git clone https://github.com/elppans/actions-for-nautilus.git
cd actions-for-nautilus
sudo make install_global
mkdir -p $HOME/.local/share/actions-for-nautilus
cp /usr/share/actions-for-nautilus-configurator/sample-config.json $HOME/.local/share/actions-for-nautilus/config.json
nautilus -q

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
install_snap vivaldi
install_snap opera
install_snap gtkhash
install_snap shellcheck
install_snap shfmt
install_snap prettier
install_snap dbeaver-ce

# ___ Instalação de pacotes via FLATPAK

sudo flatpak install -y flathub com.google.Chrome
sudo flatpak install -y flathub com.microsoft.Edge
sudo flatpak install -y flathub org.kde.kate
sudo flatpak install -y flathub com.anydesk.Anydesk
sudo flatpak install -y flathub com.rustdesk.RustDesk
sudo flatpak install -y flathub com.rtosta.zapzap

# ___ Instalação usando Scripts customizados

# Action Script, conversão de imagens
cd /tmp
git clone https://github.com/elppans/el-images.git
cd el-images
./install.sh
cd -

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

# Atualização do sistema

sudo apt -y upgrade
sudo snap refresh

# Limpeza do sistema
sudo apt clean
sudo apt autoclean
sudo apt -y autoremove

echo -e '\n\nReinicie o computador para aplicar as configurações!\n\n'
