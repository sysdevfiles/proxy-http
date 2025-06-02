# HTTP Proxy 101

🚀 **Servidor proxy HTTP que responde con código 101 para bypass de restricciones de red**

Compatible con HTTP Injector, OpenVPN y otras herramientas de túnel.

## ⚡ Instalación Rápida (Ubuntu VPS)

```bash
curl -fsSL https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

**¡Eso es todo!** El instalador detecta y corrige automáticamente cualquier problema con Node.js y puertos.

## ✨ Características

- ✅ **Auto-detección**: Encuentra y configura Node.js automáticamente
- ✅ **Auto-reparación**: Corrige problemas de instalación sin intervención
- ✅ **Puerto 80 libre**: Detecta y libera automáticamente conflictos en puerto 80
- ✅ **Detección de servicios**: Para automáticamente Apache, Nginx, Lighttpd, etc.
- ✅ **Código 101**: Respuestas "Switching Protocols" para bypass
- ✅ **Systemd**: Servicio automático con reinicio automático
- ✅ **Multi-método**: Instala Node.js via NodeSource, Snap o repos Ubuntu
- ✅ **Diagnóstico avanzado**: Muestra información detallada en caso de problemas

## 🎯 Uso en HTTP Injector

Después de la instalación, usa estos datos:

```
Host: TU_IP_VPS
Port: 80
Type: HTTP
```

## 🔧 Comandos Útiles

```bash
# Ver estado del servicio
systemctl status http-proxy-101

# Ver logs en tiempo real  
journalctl -u http-proxy-101 -f

# Reiniciar servicio
systemctl restart http-proxy-101

# Script de reinicio con auto-reparación
/opt/http-proxy-101/scripts/restart.sh
```

## 🛠️ Auto-reparación

El instalador incluye detección automática de problemas:
- ✅ **Node.js**: Detecta Node.js en `/snap/bin/`, `/usr/bin/`, `/usr/local/bin/`
- ✅ **Enlaces**: Crea enlaces simbólicos automáticamente
- ✅ **Puerto 80**: Detecta y para servicios conflictivos (Apache, Nginx, etc.)
- ✅ **Procesos**: Termina automáticamente procesos que bloquean puerto 80
- ✅ **Instalación**: Múltiples métodos (NodeSource → Snap → Ubuntu repos)
- ✅ **Diagnóstico**: Auto-diagnóstico detallado en caso de errores

## 📋 Requisitos

- Ubuntu 18.04+ (también funciona en Debian)
- Acceso root (`sudo`)
- Conexión a internet

## ⚠️ Solución de Problemas

El instalador detecta y soluciona automáticamente la mayoría de problemas. Si algo falla, muestra un auto-diagnóstico detallado.

### Comandos manuales de verificación:

```bash
# Verificar estado del servicio
systemctl status http-proxy-101

# Ver logs detallados
journalctl -u http-proxy-101 -n 20

# Verificar Node.js
ls -la /usr/bin/node
which node

# Verificar puerto 80
sudo netstat -tulpn | grep :80
sudo lsof -i :80

# Reinicio con auto-reparación completa
/opt/http-proxy-101/scripts/restart.sh
```

### Problemas comunes resueltos automáticamente:

- ❌ **Node.js no encontrado** → ✅ Auto-detecta e instala
- ❌ **Puerto 80 ocupado** → ✅ Para Apache/Nginx automáticamente  
- ❌ **Enlace simbólico faltante** → ✅ Crea enlaces automáticamente
- ❌ **Servicios conflictivos** → ✅ Detecta y deshabilita automáticamente

---

**✅ Instalación completamente automatizada - No requiere configuración manual**
