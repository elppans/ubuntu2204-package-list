# Instalação de navegador

- Microsoft Edge
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
```
```bash
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
```
```bash
echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge-dev.list > /dev/null
```
