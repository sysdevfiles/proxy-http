# HTTP Proxy 101

🚀 **Servidor proxy HTTP inteligente con autenticación VPS y código 101 para bypass de restricciones de red**

Compatible con HTTP Injector, OpenVPN y otras herramientas de túnel. Incluye autenticación PAM contra usuarios del sistema Linux.

## ⚡ Instalación Súper Rápida (Ubuntu VPS)

```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

**¡Eso es todo!** El instalador es completamente inteligente y automático.

## 🧠 Instalador Inteligente

### 🔍 **Validación Automática**
- ✅ **Detecta instalaciones existentes** y evita reinstalaciones innecesarias
- ✅ **Verifica dependencias** antes de instalar (Node.js, npm, paquetes)
- ✅ **Permite cancelación** si ya tienes una instalación funcional
- ✅ **Instalación incremental** - solo instala lo que falta

### 🛠️ **Auto-reparación Avanzada**
- ✅ **Node.js multi-método**: NodeSource (v18.x), Snap, repos Ubuntu
- ✅ **Limpieza automática**: Elimina paquetes conflictivos residuales
- ✅ **Puerto 80 inteligente**: Detecta y libera automáticamente conflictos
- ✅ **Timeouts configurables**: Evita colgarse en instalaciones npm
- ✅ **Detección de servicios**: Para Apache, Nginx, Lighttpd automáticamente

### 📊 **Diagnóstico Completo**
- 🔎 **Estado del sistema**: Node.js, npm, dependencias, servicios
- 🔎 **Información detallada**: Versiones, puertos, usuarios, permisos
- 🔎 **Logs inteligentes**: Seguimiento completo del proceso
- 🔎 **Comandos útiles**: Gestión post-instalación

## ✨ Características del Proxy

- 🔐 **Autenticación PAM**: Valida contra usuarios VPS reales
- 🛡️ **Seguridad avanzada**: Headers, CORS, rate limiting, IP blocking
- 🔄 **Código 101**: Respuestas "Switching Protocols" para bypass
- ⚙️ **Systemd nativo**: Servicio automático con reinicio
- 📝 **Logging completo**: Seguimiento de conexiones y errores
- 🚀 **Alto rendimiento**: Express.js optimizado

## 🎯 Uso en HTTP Injector

Después de la instalación, usa estos datos:

```
Host: TU_IP_VPS
Port: 80
Type: HTTP
Username: tu_usuario_vps
Password: tu_contraseña_vps
```

> 📋 **Nota**: El proxy utiliza autenticación PAM contra los usuarios del sistema VPS. Usa las mismas credenciales que usas para SSH.

## 🔐 Configuración de Autenticación

El proxy incluye autenticación VPS integrada que valida contra los usuarios del sistema Linux:

### Configurar Usuarios Permitidos

Edita el archivo de configuración:
```bash
nano /opt/http-proxy-101/config/config.json
```

Para permitir solo usuarios específicos:
```json
{
  "server": {
    "auth": {
      "enabled": true,
      "allowedUsers": ["usuario1", "usuario2", "admin"]
    }
  }
}
```

Para permitir todos los usuarios del sistema (por defecto):
```json
{
  "server": {
    "auth": {
      "enabled": true,
      "allowedUsers": []
    }
  }
}
```

### Crear Usuario Específico para el Proxy

Si quieres crear un usuario dedicado:
```bash
# Crear usuario para el proxy
sudo useradd -m -s /bin/bash proxyuser

# Establecer contraseña
sudo passwd proxyuser

# Agregar a la configuración
nano /opt/http-proxy-101/config/config.json
```

### Habilitar PAM (Si No Está Disponible)

Si durante la instalación se mostró que PAM no está disponible:

```bash
# Instalar herramientas de compilación y headers PAM
sudo apt-get update
sudo apt-get install build-essential libpam0g-dev python3

# Reinstalar authenticate-pam
cd /opt/http-proxy-101
sudo npm install authenticate-pam --production

# Reiniciar el servicio
systemctl restart http-proxy-101
```

### Desactivar Autenticación (No Recomendado)

```json
{
  "server": {
    "auth": {
      "enabled": false
    }
  }
}
```

Después de cualquier cambio, reinicia el servicio:
```bash
systemctl restart http-proxy-101
```

## 🔧 Comandos Útiles

### 📊 **Gestión del Servicio**
```bash
# Ver estado detallado del servicio
systemctl status http-proxy-101

# Ver logs en tiempo real  
journalctl -u http-proxy-101 -f

# Reiniciar servicio
systemctl restart http-proxy-101

# Parar/iniciar servicio
systemctl stop http-proxy-101
systemctl start http-proxy-101
```

### 🛠️ **Scripts de Utilidad**
```bash
# Script de reinicio con auto-reparación
/opt/http-proxy-101/scripts/restart.sh

# Verificar instalación
/opt/http-proxy-101/scripts/check.sh

# Auto-diagnóstico del sistema
cd /opt/http-proxy-101/test
node test-auth.js    # Probar autenticación
node test-proxy.js   # Probar funcionalidad del proxy
```

### 🔍 **Diagnóstico de Sistema**
```bash
# Información del sistema
node --version && npm --version
ls -la /opt/http-proxy-101/
ps aux | grep node
netstat -tlnp | grep :80

# Verificar dependencias
cd /opt/http-proxy-101
npm list --depth=0
ls -la node_modules/ | head -10
```

### 📝 **Logs y Monitoreo**
```bash
# Logs del servicio systemd
journalctl -u http-proxy-101 -n 50

# Logs del instalador
tail -50 /var/log/http-proxy-101-install.log

# Monitoreo en tiempo real
watch -n 2 'systemctl status http-proxy-101'
```

## 🚨 Solución de Problemas Avanzada

### ⚠️ **Instalador se Detiene o Cuelga**

**El nuevo instalador incluye validación inteligente que detecta:**
- ✅ Instalaciones existentes (evita reinstalar)
- ✅ Dependencias ya instaladas
- ✅ Servicios funcionando
- ✅ Node.js disponible

**Si se detiene en "Instalando dependencias":**

1. **El instalador ahora pregunta antes de reinstalar**:
   ```bash
   # Ejecutar de nuevo, mostrará estado actual
   sudo bash proxy-http.sh
   ```

2. **Verificación manual del estado**:
   ```bash
   # Verificar Node.js
   node --version  # Debería mostrar v18.x o superior
   npm --version   # Debería mostrar 8.x o superior
   
   # Verificar proyecto
   ls -la /opt/http-proxy-101/
   ls -la /opt/http-proxy-101/node_modules/ | wc -l
   ```

3. **Instalación manual si necesario**:
   ```bash
   cd /opt/http-proxy-101
   sudo npm install --production --timeout=300000
   ```

### 🆘 **Problemas Específicos y Soluciones**

**🔍 Node.js no detectado:**
```bash
# El instalador busca automáticamente en:
/usr/bin/node, /snap/bin/node, /usr/local/bin/node

# Verificación manual:
which node && node --version
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

**🔍 Puerto 80 ocupado:**
```bash
# El instalador para automáticamente estos servicios:
systemctl stop apache2 nginx httpd lighttpd caddy

# Verificación manual:
sudo netstat -tulpn | grep :80
sudo lsof -i :80
```

**🔍 Dependencias PAM fallan:**
```bash
# El instalador crea fallbacks automáticamente
# Verificar si authenticate-pam se instaló:
ls -la /opt/http-proxy-101/node_modules/authenticate-pam/

# Si falló, el sistema usa autenticación básica como fallback
journalctl -u http-proxy-101 | grep PAM
```

**🔍 Servicio no inicia:**
```bash
# Diagnóstico completo:
systemctl status http-proxy-101 -l
journalctl -u http-proxy-101 -n 20

# Verificar permisos:
ls -la /opt/http-proxy-101/
id proxy
```

### 🔄 **Reinstalación Inteligente**

El nuevo instalador detecta automáticamente:
- ✅ **Instalaciones completas** - pregunta antes de reinstalar
- ✅ **Instalaciones parciales** - completa solo lo faltante
- ✅ **Dependencias existentes** - omite si ya están instaladas
- ✅ **Servicios funcionando** - permite continuar sin reinstalar

```bash
# Ejecutar instalador - mostrará estado y preguntará
sudo bash proxy-http.sh

# Forzar reinstalación completa
sudo systemctl stop http-proxy-101
sudo rm -rf /opt/http-proxy-101
sudo userdel proxy
sudo bash proxy-http.sh
```

## 📋 Requisitos y Compatibilidad

### 🖥️ **Sistema Operativo**
- ✅ Ubuntu 18.04+ (Recomendado: 20.04 LTS, 22.04 LTS)
- ✅ Debian 10+ (Buster, Bullseye, Bookworm)
- ✅ Linux Mint 19+ 
- ✅ Cualquier distribución basada en Ubuntu/Debian

### 🔧 **Requisitos del Sistema**
- ✅ Acceso root (sudo)
- ✅ Conexión a internet estable
- ✅ 512 MB RAM mínimo (1GB recomendado)
- ✅ 100 MB espacio libre
- ✅ Puerto 80 disponible (se libera automáticamente)

### 🌐 **Node.js Soportado**
- ✅ Node.js 16.x, 18.x, 20.x, 22.x (detección automática)
- ✅ Instalación automática vía NodeSource (v18.x por defecto)
- ✅ Soporte para instalaciones Snap
- ✅ Compatible con repos Ubuntu nativos

### 🔐 **Seguridad y Red**
- ✅ Firewall UFW (configuración automática)
- ✅ Autenticación PAM nativa
- ✅ Headers de seguridad (Helmet)
- ✅ Rate limiting configurable
- ✅ Bloqueo de IPs por intentos fallidos

## 🚀 Rendimiento y Escalabilidad

### 📊 **Métricas Típicas**
- 🔥 **Conexiones simultáneas**: 1000+ (depende del VPS)
- 🔥 **Latencia**: < 10ms (red local)
- 🔥 **Throughput**: 100+ Mbps (depende del ancho de banda)
- 🔥 **Memoria**: 50-100 MB uso típico

### ⚙️ **Optimizaciones Incluidas**
- ✅ Compresión gzip automática
- ✅ Keep-alive connections
- ✅ Timeout configurables
- ✅ Headers optimizados
- ✅ Express.js con middleware optimizado

## 🎯 Ejemplos de Uso

### 📱 **HTTP Injector (Android)**
```
Server Type: HTTP
Server Host: TU_IP_VPS
Server Port: 80
Username: tu_usuario_vps
Password: tu_contraseña_vps
```

### 💻 **OpenVPN/Tunneling**
```
http-proxy TU_IP_VPS 80
http-proxy-user-pass credentials.txt
```

### 🌐 **Browser/Curl Testing**
```bash
# Test básico con autenticación
curl -v -x tu_usuario:tu_contraseña@TU_IP_VPS:80 http://example.com

# Test de conectividad
curl -I http://TU_IP_VPS/health

# Test con proxy explícito
curl -v -x TU_IP_VPS:80 --proxy-user tu_usuario:tu_contraseña http://httpbin.org/ip
```

## 📈 Monitoreo y Logs

### 📊 **Dashboard de Estado**
```bash
# Ver dashboard en tiempo real
watch -n 1 'echo "=== HTTP Proxy 101 Status ===" && systemctl status http-proxy-101 --no-pager -l && echo && echo "=== Active Connections ===" && netstat -an | grep :80 && echo && echo "=== Memory Usage ===" && ps aux | grep node | head -5'
```

### 📝 **Análisis de Logs**
```bash
# Conexiones exitosas
journalctl -u http-proxy-101 | grep "CONNECT"

# Intentos de autenticación
journalctl -u http-proxy-101 | grep "auth"

# Errores de conexión
journalctl -u http-proxy-101 | grep "ERROR"

# Estadísticas de uso
journalctl -u http-proxy-101 --since "1 hour ago" | grep -c "CONNECT"
```

## 🔮 Características Avanzadas

### 🛡️ **Sistema de Seguridad Multi-Capa**
- 🔐 **Autenticación PAM**: Integración directa con usuarios Linux
- 🚫 **Rate Limiting**: Protección contra ataques de fuerza bruta  
- 🔒 **IP Blocking**: Bloqueo automático de IPs sospechosas
- 🛡️ **Security Headers**: Helmet.js para headers HTTP seguros
- 📊 **Audit Logging**: Registro completo de conexiones y eventos

### ⚡ **Instalador Inteligente de Nueva Generación**
- 🧠 **Detección de Estado**: Analiza instalaciones existentes automáticamente
- 🔄 **Instalación Incremental**: Solo instala lo que realmente falta
- ⏱️ **Timeouts Inteligentes**: Evita colgarse en instalaciones npm
- 🛠️ **Auto-reparación**: Corrige automáticamente problemas comunes
- 📋 **Validación Exhaustiva**: Verifica cada paso antes de continuar

### 🚀 **Optimización de Rendimiento**
- ⚡ **Express.js Optimizado**: Middleware configurado para máximo rendimiento
- 🗜️ **Compresión Inteligente**: Gzip/deflate automático según el contenido
- 🔗 **Connection Pooling**: Reutilización eficiente de conexiones
- 📊 **Memory Management**: Gestión optimizada de memoria y recursos
- 🎯 **Load Balancing Ready**: Preparado para balanceadores de carga

## 🤝 Contribuir

Contribuciones son bienvenidas! Para contribuir:

1. **Fork** el proyecto
2. **Crea** una rama feature (`git checkout -b feature/nueva-caracteristica`)
3. **Commit** tus cambios (`git commit -am 'Agrega nueva característica'`)
4. **Push** a la rama (`git push origin feature/nueva-caracteristica`)
5. **Abre** un Pull Request

### 🐛 **Reportar Bugs**
- Usa el sistema de Issues de GitHub
- Incluye información del sistema (Ubuntu version, Node.js version)
- Proporciona logs relevantes (`journalctl -u http-proxy-101`)

### 💡 **Sugerir Características**
- Abre un Issue con el tag "enhancement"
- Describe el caso de uso y beneficios
- Considera la compatibilidad y seguridad

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT** - ver el archivo [LICENSE](LICENSE) para detalles.

---

<div align="center">

**🚀 HTTP Proxy 101 - Developed with ❤️ for the bypass community**

[![GitHub stars](https://img.shields.io/github/stars/sysdevfiles/proxy-http?style=social)](https://github.com/sysdevfiles/proxy-http)
[![GitHub forks](https://img.shields.io/github/forks/sysdevfiles/proxy-http?style=social)](https://github.com/sysdevfiles/proxy-http)
[![GitHub issues](https://img.shields.io/github/issues/sysdevfiles/proxy-http)](https://github.com/sysdevfiles/proxy-http/issues)

</div>
