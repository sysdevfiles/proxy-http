# HTTP Proxy 101

🚀 **Servidor proxy HTTP que responde con código 101 para bypass de restricciones de red**

Compatible con HTTP Injector, OpenVPN y otras herramientas de túnel.

## ⚡ Instalación Rápida (Ubuntu VPS)

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

### Comando Alternativo
```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

## ✨ Características

- ✅ **Puerto 80**: Servidor HTTP principal
- ✅ **Código 101**: Respuestas "Switching Protocols" para bypass
- ✅ **CONNECT**: Soporte completo para túneles HTTPS
- ✅ **Systemd**: Servicio automático en Linux
- ✅ **Node.js 20 LTS**: Tecnología moderna y estable
- ✅ **Firewall**: Configuración UFW automática
- ✅ **Logs**: Monitoreo con journalctl

## 🎯 Uso

### Configuración en Apps

**HTTP Injector:**
```
Proxy Host: TU_VPS_IP
Proxy Port: 80  
Proxy Type: HTTP
```

**OpenVPN:**
```
http-proxy TU_VPS_IP 80
```

**Curl (para probar):**
```bash
curl -I --proxy TU_VPS_IP:80 https://google.com
```

## 📋 Requisitos

### Sistema
- **SO**: Ubuntu 18.04+ (recomendado 20.04/22.04)
- **RAM**: Mínimo 512MB
- **CPU**: 1 vCPU
- **Red**: Puerto 80 disponible

### Software (se instala automáticamente)
- **Node.js**: 20 LTS
- **npm**: Última versión
- **systemd**: Para gestión del servicio

## 🔧 Gestión del Servicio

```bash
# Ver estado
sudo systemctl status http-proxy-101

# Ver logs en tiempo real
sudo journalctl -u http-proxy-101 -f

# Reiniciar servicio
sudo systemctl restart http-proxy-101

# Detener servicio
sudo systemctl stop http-proxy-101

# Iniciar servicio
sudo systemctl start http-proxy-101
```

## 🧪 Probar el Proxy

```bash
# Desde el servidor
node test/test-proxy.js localhost 80

# Desde otro equipo
node test/test-proxy.js TU_VPS_IP 80

# Prueba rápida con curl
curl -I --proxy TU_VPS_IP:80 http://httpbin.org/ip
```

## 🚀 Desarrollo Local

```bash
# Clonar proyecto
git clone https://github.com/sysdevfiles/proxy-http.git
cd proxy-http

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev

# Ejecutar pruebas
npm test
```

El servidor se ejecutará en `localhost:8080` en modo desarrollo.

## 🆘 Solución de Problemas

### Error de Instalación
```bash
# Limpiar instalación previa
sudo systemctl stop http-proxy-101 2>/dev/null || true
sudo systemctl disable http-proxy-101 2>/dev/null || true
sudo rm -rf /opt/http-proxy-101
sudo userdel proxy 2>/dev/null || true

# Reinstalar
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

### Verificar Conectividad
```bash
# Ping al servidor
ping TU_VPS_IP

# Verificar puerto abierto
telnet TU_VPS_IP 80

# Ver puertos en uso
sudo netstat -tulpn | grep :80
```

### Logs de Instalación
```bash
# Ver log de instalación
sudo cat /var/log/http-proxy-101-install.log

# Ver logs del servicio
sudo journalctl -u http-proxy-101 --no-pager
```

## 📦 Estructura del Proyecto

```
proxy-http/
├── README.md           # Este archivo
├── package.json        # Dependencias Node.js
├── proxy-http.sh       # Script de instalación
├── src/
│   └── server.js       # Servidor principal
├── config/
│   └── config.json     # Configuración
├── test/
│   └── test-proxy.js   # Pruebas automáticas
├── examples/
│   └── usage.js        # Ejemplos de uso
└── scripts/
    └── test-wget.sh    # Test de instalación
```

## 🔧 Dependencias Node.js

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## 📝 Scripts Disponibles

```bash
npm start          # Ejecutar en producción
npm run dev        # Ejecutar en desarrollo con nodemon
npm test           # Ejecutar pruebas
npm run examples   # Ver ejemplos de uso
```

## ⚙️ Configuración Avanzada

Edita `/opt/http-proxy-101/config/config.json`:

```json
{
  "server": {
    "host": "0.0.0.0",
    "port": 80,
    "timeout": 30000
  },
  "proxy": {
    "responseCode": 101,
    "responseMessage": "Switching Protocols",
    "headers": {
      "X-Proxy-Server": "HTTP-Proxy-101",
      "X-Bypass-Mode": "active"
    }
  }
}
```

Después de cambios: `sudo systemctl restart http-proxy-101`

## 🌐 URLs del Proyecto

- **GitHub**: `https://github.com/sysdevfiles/proxy-http`
- **Script**: `https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh`

## 📄 Licencia

MIT License - Ver archivo LICENSE para detalles.

---

**¿Problemas?** Abre un issue en GitHub o revisa los logs del servicio.
