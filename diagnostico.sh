#!/bin/bash

# Script de diagnóstico para problemas de instalación
# Ejecutar si la instalación falla

echo "🔍 HTTP Proxy 101 - Diagnóstico de Instalación"
echo "=============================================="
echo ""

# Información del sistema
echo "📋 Información del Sistema:"
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Desconocido')"
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(uname -m)"
echo ""

# Verificar permisos
echo "🔐 Verificación de Permisos:"
if [[ $EUID -eq 0 ]]; then
    echo "✅ Ejecutándose como root"
else
    echo "❌ NO se está ejecutando como root"
    echo "   Solución: sudo bash proxy-http.sh"
fi
echo ""

# Verificar conectividad
echo "🌐 Verificación de Conectividad:"
if ping -c 1 google.com >/dev/null 2>&1; then
    echo "✅ Conectividad a Internet OK"
else
    echo "❌ Sin conectividad a Internet"
fi

if curl -s https://deb.nodesource.com >/dev/null 2>&1; then
    echo "✅ Acceso a NodeSource OK"
else
    echo "❌ No se puede acceder a NodeSource"
fi
echo ""

# Verificar puertos
echo "🔌 Verificación de Puertos:"
if netstat -tulpn 2>/dev/null | grep -q ":80 "; then
    echo "❌ Puerto 80 está en uso:"
    netstat -tulpn | grep ":80 "
    echo "   Solución: sudo pkill -f :80"
else
    echo "✅ Puerto 80 disponible"
fi

if netstat -tulpn 2>/dev/null | grep -q ":443 "; then
    echo "⚠️  Puerto 443 está en uso:"
    netstat -tulpn | grep ":443 "
else
    echo "✅ Puerto 443 disponible"
fi
echo ""

# Verificar Node.js
echo "📦 Verificación de Node.js:"
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js instalado: $NODE_VERSION"
    
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        echo "✅ npm instalado: $NPM_VERSION"
    else
        echo "❌ npm no encontrado"
    fi
else
    echo "❌ Node.js no encontrado"
    echo "   Posibles soluciones:"
    echo "   1. sudo apt update && sudo apt install -y nodejs npm"
    echo "   2. sudo snap install node --classic"
    echo "   3. curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -"
fi
echo ""

# Verificar dependencias del sistema
echo "🛠️ Verificación de Dependencias:"
DEPS=("curl" "wget" "git" "build-essential")
for dep in "${DEPS[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "✅ $dep instalado"
    else
        echo "❌ $dep no encontrado"
    fi
done
echo ""

# Verificar espacio en disco
echo "💾 Verificación de Espacio:"
AVAILABLE=$(df / | awk 'NR==2 {print $4}')
if [[ $AVAILABLE -gt 1000000 ]]; then
    echo "✅ Espacio suficiente: $(($AVAILABLE/1024)) MB disponibles"
else
    echo "⚠️  Poco espacio: $(($AVAILABLE/1024)) MB disponibles"
fi
echo ""

# Verificar logs del sistema
echo "📄 Últimos errores del sistema:"
journalctl -p err -n 5 --no-pager 2>/dev/null || echo "No se pueden leer logs"
echo ""

# Sugerencias de solución
echo "🔧 Soluciones Comunes:"
echo ""
echo "1. **Reinstalar dependencias:**"
echo "   sudo apt update && sudo apt upgrade -y"
echo "   sudo apt install -y curl wget git build-essential"
echo ""
echo "2. **Limpiar e instalar Node.js manualmente:**"
echo "   sudo apt remove -y nodejs npm"
echo "   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -"
echo "   sudo apt install -y nodejs"
echo ""
echo "3. **Liberar puerto 80:**"
echo "   sudo systemctl stop apache2 nginx"
echo "   sudo pkill -f :80"
echo ""
echo "4. **Reinstalar script:**"
echo "   wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh"
echo "   sudo bash proxy-http.sh"
echo ""
echo "5. **Verificar firewall:**"
echo "   sudo ufw status"
echo "   sudo ufw allow 80/tcp"
echo ""

echo "📞 Si persisten los problemas, copiar este diagnóstico completo."
