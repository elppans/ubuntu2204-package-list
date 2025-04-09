# **Adicionar repositório de terceiros**

- **Anydesk e Team Viewer**
```bash
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
```
```bash
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null
```
```bash
curl -fSsL https://linux.teamviewer.com/pubkey/currentkey.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/teamview.gpg > /dev/null
```
```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/teamview.gpg] http://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list > /dev/null
```
- **Instalar Team Viewer (Se não estiver instalado):**
```bash
sudo apt -y install teamviewer
```
- **Remover o Anydesk versão Flatpak:**
```bash
sudo flatpak remove -y com.anydesk.Anydesk
```
- **Instalar o Anydesk versão nativa:**
```bash
sudo apt -y install anydesk
```
- **Garantir atualização:**
```bash
sudo apt update && sudo apt -y upgrade
```
___
