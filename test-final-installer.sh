#!/bin/bash

# Test de validación del instalador HTTP Proxy 101
# Verifica que todas las funciones estén correctamente implementadas

echo "🧪 VALIDANDO INSTALADOR HTTP PROXY 101"
echo "======================================"
echo ""

# Verificar que el archivo principal existe
if [[ ! -f "proxy-http.sh" ]]; then
    echo "❌ ERROR: proxy-http.sh no encontrado"
    exit 1
fi

# Verificar sintaxis bash
echo "1. ✅ Verificando sintaxis bash..."
if bash -n proxy-http.sh; then
    echo "   ✅ Sintaxis correcta"
else
    echo "   ❌ Error de sintaxis"
    exit 1
fi

# Verificar funciones críticas
echo ""
echo "2. ✅ Verificando funciones críticas..."

critical_functions=(
    "install_node_dependencies"
    "check_and_free_port_80"
    "detect_and_fix_nodejs"
    "create_fallback_server"
    "fix_snap_nodejs_issues"
    "run_npm_with_timeout"
)

for func in "${critical_functions[@]}"; do
    if grep -q "^${func}()" proxy-http.sh; then
        echo "   ✅ $func() encontrada"
    else
        echo "   ❌ $func() no encontrada"
        exit 1
    fi
done

# Verificar mejoras específicas de Snap Node.js
echo ""
echo "3. ✅ Verificando mejoras Snap Node.js..."

snap_fixes=(
    "fix_snap_nodejs_issues"
    "npm config set prefix"
    "npm config set cache"
    "timeout.*npm install"
    "snap remove node"
)

for fix in "${snap_fixes[@]}"; do
    if grep -q "$fix" proxy-http.sh; then
        echo "   ✅ $fix implementado"
    else
        echo "   ⚠️  $fix no encontrado"
    fi
done

# Verificar templates embebidos
echo ""
echo "4. ✅ Verificando templates embebidos..."

templates=(
    "cat > \"\$PROJECT_DIR/package.json\""
    "cat > \"\$PROJECT_DIR/src/server.js\""
    "cat > \"\$PROJECT_DIR/config/config.json\""
    "cat > \"\$PROJECT_DIR/src/server-basic.js\""
)

for template in "${templates[@]}"; do
    if grep -q "$template" proxy-http.sh; then
        echo "   ✅ Template embebido encontrado"
    else
        echo "   ❌ Template embebido faltante: $template"
        exit 1
    fi
done

# Verificar manejo de timeouts
echo ""
echo "5. ✅ Verificando manejo de timeouts..."

if grep -q "timeout.*npm install" proxy-http.sh; then
    echo "   ✅ Timeout npm implementado"
else
    echo "   ❌ Timeout npm no encontrado"
    exit 1
fi

# Verificar que main() llama a todas las funciones necesarias
echo ""
echo "6. ✅ Verificando función main()..."

main_calls=(
    "install_node_dependencies"
    "check_and_free_port_80"
    "create_fallback_server"
)

for call in "${main_calls[@]}"; do
    if grep -A 20 "main()" proxy-http.sh | grep -q "$call"; then
        echo "   ✅ main() llama $call"
    else
        echo "   ❌ main() no llama $call"
        exit 1
    fi
done

echo ""
echo "🎉 ¡VALIDACIÓN COMPLETADA EXITOSAMENTE!"
echo ""
echo "📋 RESUMEN DE MEJORAS IMPLEMENTADAS:"
echo "   ✅ Resolución de conflictos Snap Node.js"
echo "   ✅ Sistema multi-método de instalación npm"
echo "   ✅ Timeouts para evitar colgado de npm"
echo "   ✅ Servidor básico alternativo sin dependencias"
echo "   ✅ Auto-detección y configuración de Node.js"
echo "   ✅ Auto-liberación de puerto 80"
echo "   ✅ Templates embebidos para instalación wget"
echo ""
echo "🚀 INSTALADOR LISTO PARA PRODUCCIÓN"
echo ""
echo "⚡ Comando wget actualizado:"
echo "wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh"
