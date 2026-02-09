# 🛠️ Script de PÓS Instalação para Ubuntu 22.04  

Este script automatiza a instalação de pacotes essenciais no **Ubuntu 22.04**, utilizando `apt`, `snap` e `flatpak`, além de configurar alguns scripts customizados.  

⚠️ **ATENÇÃO**  
Este script pode modificar o seu sistema. **Use por sua conta e risco!**  
Eu **não me responsabilizo** por quaisquer problemas ou danos que possam ocorrer.  

## 📌 Como usar  

1. **Clone o repositório**

   ```bash
   cd /tmp
   ```
   ```bash
   git clone --branch {repo} https://github.com/elppans/ubuntu2204-package-list.git
   ```
   ```bash
   cd ubuntu2204-package-list
   ```

3. **Edite o script conforme necessário**  
   - O script `install.sh` instala vários pacotes por padrão.  
   - **Comente (`#`) ou descomente** as linhas dos pacotes que deseja instalar.  

4. **Torne o script executável**  
   ```bash
   chmod +x install.sh
   ```

5. **Execute o script**  
   ```bash
   ./install.sh
   ```

## 📜 O que o script faz?  

✔ **Instalação de pacotes via APT**  
✔ **Instalação de pacotes via SNAP**  
✔ **Instalação de pacotes via FLATPAK**  
✔ **Execução de scripts customizados**  
✔ **Atualização e limpeza do sistema**  

## 📜 Lista de Aplicativos

#### Instalação do Flatpak
- Flatpak
- GNOME Software Plugin para Flatpak
- Repositório Flathub

#### Instalação via APT
- openssh-server (Servidor SSH)
- apt-file (Para download de repositórios sources)
- curl (Para transferências de dados)
- git (Sistema de controle de versão)
- make (Ferramenta de compilação)
- jq (Processador JSON de linha de comando)
- wine (Executar aplicativos Windows no Linux)
- winetricks (Instalar bibliotecas adicionais para Wine)
- mystiq (Front-end FFmpeg GUI baseado em Qt5)
- nautilus-admin (Extensão para Nautilus)
- nautilus-image-converter (Extensão para Nautilus)
- python3-nautilus (Extensão para Nautilus)
- Nautilus-Status-Bar-Replacement (Barra de status para Nautilus)
- python3-gi (Bindings Python para GObject)
- procps (Conjunto de utilitários de sistema)
- libjs-jquery (Biblioteca jQuery)
- baobab (Analisador de uso de disco)
- meld (Ferramenta de comparação de arquivos e diretórios)
- xclip (Ferramenta de linha de comando para o clipboard)
- zenity (Ferramenta para criar diálogos gráficos)
- dirmngr (GPG - serviço de gerenciamento de certificados de rede)
- openfortigui (GUI para openfortivpn)
- stylelint (Poderoso e moderno linter CSS)
- teamviewer_amd64 (Software de acesso remoto Team Viewer)
- cisco-secure-client-vpn (Módulo AnyConnect VPN para o Cisco Secure Client)
- vivaldi (Navegador web)
- opera (Navegador web)
- com.google.Chrome (Navegador Chrome)
- com.microsoft.Edge (Navegador Edge)
- Java padrão (OpenJDK Runtime Environment - 11.0.27+)
- dbeaver-ce (Cliente de banco de dados)
- code (Editor de desenvolvimento - Microsoft VSCode)
- codium (Editor de desenvolvimento - VSCodium)
- shfmt (Formatador de scripts Shell)
- com.anydesk.Anydesk (Software de acesso remoto AnyDesk)
- com.rustdesk.RustDesk (Software de acesso remoto RustDesk)

#### Instalação via SNAP
- marktext (Editor de texto Markdown)
- gtkhash (Ferramenta de hash)  
- node (executável runtime)  
- shellcheck (Ferramenta de análise de scripts Shell)
- prettier (Formatador de código)

#### Instalação via FLATPAK

- org.kde.kate (Editor de texto Kate)
- com.rtosta.zapzap (Cliente de WhatsApp)

#### Instalação via Scripts Customizados
- Action Script (Conversão de imagens)
- Modelos de arquivos
- Bitvise {Aplicativo Wine}-(Transferência de arquivos, terminal e tunelamento).  (**Desabilitado**)
Descomente as linhas se quiser instalar 
- Makedeb (Compilador de codigo fonte baseado no makepkg (Archlinux) - AVANÇADO).  


## 🚨 Aviso Legal  

Este script foi criado para **uso pessoal**, e pode não ser adequado para todos os usuários.  
Antes de rodá-lo, revise o código e ajuste conforme necessário.  

❗ **USE POR SUA CONTA E RISCO!**  

---  

Feito para facilitar a instalação de pacotes no Ubuntu, pós instalação.  
___
