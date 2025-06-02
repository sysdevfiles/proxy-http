# 🔧 Solución de Problemas - HTTP Proxy 101

## ❌ Error: "Error en Instalando Node.js"

### 🔍 Diagnóstico Rápido

Ejecuta el diagnóstico automático:
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/diagnostico.sh
chmod +x diagnostico.sh
sudo ./diagnostico.sh
```

### 🚀 Solución Rápida

Usa el instalador manual:
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/manual-install.sh
chmod +x manual-install.sh
sudo ./manual-install.sh
```

### 🔧 Soluciones Específicas

#### 1. **Limpiar e instalar Node.js manualmente**
```bash
# Limpiar instalaciones previas
sudo apt remove -y nodejs npm

# Método 1: NodeSource (recomendado)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
sudo apt install -y nodejs

# Método 2: Snap (alternativo)
sudo apt install -y snapd
sudo snap install node --classic

# Método 3: Repositorio Ubuntu
sudo apt update
sudo apt install -y nodejs npm
```

#### 2. **Puerto 80 ocupado**
```bash
# Ver qué está usando el puerto
sudo netstat -tulpn | grep :80

# Detener servicios comunes
sudo systemctl stop apache2
sudo systemctl stop nginx
sudo pkill -f :80
```

#### 3. **Problemas de conectividad**
```bash
# Verificar internet
ping -c 3 google.com

# Verificar DNS
nslookup github.com

# Reiniciar red
sudo systemctl restart networking
```

#### 4. **Problemas de permisos**
```bash
# Asegurar que se ejecuta como root
sudo bash proxy-http.sh

# Verificar usuario actual
whoami
```

## 🐛 Errores Comunes

### Error: "curl: command not found"
```bash
sudo apt update
sudo apt install -y curl wget
```

### Error: "Unable to locate package nodejs"
```bash
sudo apt update
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
sudo apt install -y nodejs
```

### Error: "Port 80 already in use"
```bash
sudo systemctl stop apache2 nginx
sudo fuser -k 80/tcp
```

### Error: "Permission denied"
```bash
# Ejecutar como root
sudo bash proxy-http.sh

# O cambiar permisos
chmod +x proxy-http.sh
```

## 🔄 Reinstalación Completa

Si todo falla, reinstalación limpia:

```bash
# 1. Limpiar instalación previa
sudo systemctl stop http-proxy-101 2>/dev/null || true
sudo systemctl disable http-proxy-101 2>/dev/null || true
sudo rm -rf /opt/http-proxy-101
sudo userdel proxy 2>/dev/null || true
sudo rm -f /etc/systemd/system/http-proxy-101.service

# 2. Limpiar Node.js
sudo apt remove -y nodejs npm
sudo apt autoremove -y

# 3. Actualizar sistema
sudo apt update && sudo apt upgrade -y

# 4. Reinstalar con instalador manual
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/manual-install.sh
sudo bash manual-install.sh
```

## 📋 Verificación Post-Instalación

```bash
# 1. Verificar servicio
sudo systemctl status http-proxy-101

# 2. Verificar puerto
sudo netstat -tulpn | grep :80

# 3. Probar proxy
curl --proxy http://localhost:80 https://httpbin.org/ip

# 4. Ver logs
sudo journalctl -u http-proxy-101 -f
```

## 🆘 Soporte

Si ninguna solución funciona:

1. **Ejecutar diagnóstico completo:**
   ```bash
   wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/diagnostico.sh
   sudo bash diagnostico.sh > diagnostico.txt
   ```

2. **Información a recopilar:**
   - Versión de Ubuntu: `lsb_release -a`
   - Logs del error: `sudo journalctl -u http-proxy-101 -n 50`
   - Estado del sistema: `sudo systemctl status http-proxy-101`

3. **Alternativas:**
   - Usar Docker: `docker run -p 80:80 http-proxy-101`
   - VPS diferente con Ubuntu 20.04/22.04 LTS
   - Probar en puerto diferente (ej: 8080)

## ✅ Versiones Compatibles

- ✅ Ubuntu 18.04, 20.04, 22.04 LTS
- ✅ Debian 10, 11
- ✅ Node.js 14, 16, 18, 20
- ✅ Arquitecturas: x64, arm64

---

**Instalador automático mejorado:**
```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

**Instalador manual (si falla el automático):**
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/manual-install.sh && sudo bash manual-install.sh
```
