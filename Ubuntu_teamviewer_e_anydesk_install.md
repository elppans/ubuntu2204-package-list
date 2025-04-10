# Ubuntu, Instalar/Atualizar Team Viewer e Anydesk

Para obter atualização automática dos aplicativos Team Viewer e Anydesk, deve adicionar o repositório deles no sistema.  

- **Adicionar repositório de terceiros**

A seguir, comandos para adicionar Chaves GPG (Identificação do repositório oficial) e o repositório de cada um.  

## Anydesk

- **Adicionando chave GPG do Anydesk:**
```bash
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
```
- **Adicionando repositório do Anydesk:**
```bash
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null
```
- **Remover o Anydesk versão Flatpak:**

De acordo com meus testes, notei que esta versão do container Flatpak após um tempo dá umas travadas. Então a versão nativa ainda é a melhor versão para uso.  

```bash
sudo flatpak remove -y com.anydesk.Anydesk
```
- **Instalar o Anydesk versão nativa:**

A seguir, instale o Anydesk versão nativa

```bash
sudo apt -y install anydesk
```
___

## Team Viewer

- **Adicionando chave GPG do Team Viewer:**
```bash
curl -fSsL https://linux.teamviewer.com/pubkey/currentkey.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/teamview.gpg > /dev/null
```
- **Adicionando repositório do Team Viewer:**
```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/teamview.gpg] http://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list > /dev/null
```
- **Instalar Team Viewer (Se não estiver instalado):**
```bash
sudo apt -y install teamviewer
```
___

## Garantir atualização

O proprio sistema já atualiza de forma gráfica e fácil, mas se quiser atualizar manualmente via Terminal, é só fazer os comandos a seguir

- **Atualizar informações de repositórios**
```bash
sudo apt update
```
- **Atualizar aplicativos do sistema**
```bash
sudo apt -y upgrade
```
___
