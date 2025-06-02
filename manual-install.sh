#!/bin/bash

# Instalación manual rápida de HTTP Proxy 101
# Usar si el instalador automático falla

echo "🔧 HTTP Proxy 101 - Instalación Manual"
echo "======================================"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ejecutar como root: sudo bash manual-install.sh"
    exit 1
fi

echo "✅ Ejecutándose como root"

# Paso 1: Instalar Node.js (método simple)
echo ""
echo "📦 Paso 1: Instalando Node.js..."
apt update
apt install -y nodejs npm

# Verificar Node.js
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js instalado: $(node --version)"
else
    echo "❌ Error instalando Node.js. Intentando método alternativo..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt install -y nodejs
fi

# Paso 2: Crear directorio y usuario
echo ""
echo "👤 Paso 2: Configurando usuario y directorio..."
useradd --system --shell /bin/false --home /opt/http-proxy-101 --create-home proxy 2>/dev/null || echo "Usuario proxy ya existe"
mkdir -p /opt/http-proxy-101
chown -R proxy:proxy /opt/http-proxy-101

# Paso 3: Crear servidor básico
echo ""
echo "🚀 Paso 3: Creando servidor proxy..."
cat > /opt/http-proxy-101/server.js << 'EOF'
const http = require('http');
const net = require('net');
const url = require('url');

const PORT = 80;

const server = http.createServer((req, res) => {
    res.writeHead(101, 'Switching Protocols', {
        'Connection': 'upgrade',
        'Upgrade': 'HTTP/1.1',
        'Proxy-Connection': 'keep-alive'
    });
    res.end();
});

server.on('connect', (req, clientSocket, head) => {
    const { hostname, port } = url.parse(`http://${req.url}`);
    const targetPort = port || 80;
    
    const targetSocket = net.connect(targetPort, hostname, () => {
        clientSocket.write('HTTP/1.1 200 Connection Established\r\n\r\n');
        targetSocket.write(head);
        clientSocket.pipe(targetSocket);
        targetSocket.pipe(clientSocket);
    });
    
    targetSocket.on('error', () => clientSocket.destroy());
    clientSocket.on('error', () => targetSocket.destroy());
});

server.listen(PORT, () => {
    console.log(`HTTP Proxy 101 corriendo en puerto ${PORT}`);
});
EOF

# Paso 4: Crear servicio systemd
echo ""
echo "⚙️ Paso 4: Configurando servicio systemd..."
cat > /etc/systemd/system/http-proxy-101.service << 'EOF'
[Unit]
Description=HTTP Proxy 101
After=network.target

[Service]
Type=simple
User=proxy
WorkingDirectory=/opt/http-proxy-101
ExecStart=/usr/bin/node /opt/http-proxy-101/server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Paso 5: Configurar permisos y firewall
echo ""
echo "🔐 Paso 5: Configurando permisos y firewall..."
chown -R proxy:proxy /opt/http-proxy-101
chmod +x /opt/http-proxy-101/server.js

# Configurar firewall
ufw --force enable 2>/dev/null || true
ufw allow 80/tcp 2>/dev/null || true
ufw allow 443/tcp 2>/dev/null || true

# Paso 6: Iniciar servicio
echo ""
echo "🚀 Paso 6: Iniciando servicio..."
systemctl daemon-reload
systemctl enable http-proxy-101
systemctl start http-proxy-101

# Verificar estado
sleep 2
if systemctl is-active --quiet http-proxy-101; then
    echo ""
    echo "🎉 ¡INSTALACIÓN EXITOSA!"
    echo ""
    echo "📋 Información del servicio:"
    echo "   • Puerto: 80"
    echo "   • Tipo: HTTP Proxy"
    echo "   • Estado: Activo"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "   • Estado: systemctl status http-proxy-101"
    echo "   • Logs: journalctl -u http-proxy-101 -f"
    echo "   • Reiniciar: systemctl restart http-proxy-101"
    echo ""
    echo "🌐 Usar en aplicaciones:"
    echo "   • Host: $(curl -s ifconfig.me || echo 'TU_IP_SERVIDOR')"
    echo "   • Puerto: 80"
    echo "   • Tipo: HTTP Proxy"
else
    echo "❌ Error al iniciar el servicio"
    systemctl status http-proxy-101 --no-pager
    echo ""
    echo "🔍 Verificar logs:"
    echo "journalctl -u http-proxy-101 -n 20"
fi
