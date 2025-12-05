#!/bin/bash
# Script de Demo: Muestra los logs del ESP32 en Fomalhaut Frontend

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         DEMOSTRACIÓN: ESP32 → FOMALHAUT LOGS              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Verificar que todo está corriendo
echo "🔍 Verificando servicios..."
echo ""

# Backend
if curl -s http://localhost:20001/api/telemetry > /dev/null; then
    echo -e "${GREEN}✅ Backend está corriendo (Puerto 20001)${NC}"
    BACKEND_OK=true
else
    echo -e "${RED}❌ Backend NO está corriendo${NC}"
    BACKEND_OK=false
fi

# Frontend
if curl -s http://localhost:20002 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend está corriendo (Puerto 20002)${NC}"
    FRONTEND_OK=true
else
    echo -e "${RED}⚠️  Frontend podría no estar corriendo${NC}"
    FRONTEND_OK=false
fi

echo ""

if [ "$BACKEND_OK" = false ]; then
    echo -e "${RED}Error: Backend no está disponible${NC}"
    echo "Inicia el backend primero con: ./start_system.sh"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 INICIANDO SIMULACIÓN DE DATOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Limpiar logs previos
echo "🗑️  Limpiando logs previos..."
curl -s -X DELETE http://localhost:20001/api/telemetry/clear > /dev/null
sleep 1

echo -e "${GREEN}✅ Base de datos limpia${NC}"
echo ""

# Iniciar simulador en background
echo "🚀 Iniciando simulador de ESP32..."
cd bridge

# Usar socat para crear un puerto serial virtual (opcional)
# De momento, usaremos el simulador directo

timeout 30 python3 simulate_esp32.py 2>/dev/null | python3 esp32_to_fomalhaut_bridge.py &
BRIDGE_PID=$!

echo -e "${GREEN}✅ Bridge iniciado (PID: $BRIDGE_PID)${NC}"
echo ""

# Esperar a que se generen datos
echo "⏳ Generando datos de telemetría durante 30 segundos..."
echo "   (Puedes ver los logs en tiempo real abajo)"
echo ""

sleep 5

# Mostrar logs en tiempo real
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 LOGS RECIBIDOS EN EL BACKEND"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Loop para mostrar logs actualizados
for i in {1..15}; do
    TOTAL=$(curl -s http://localhost:20001/api/telemetry | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    
    # Mostrar resumen
    SYSTEM=$(curl -s http://localhost:20001/api/telemetry/system | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    POWER=$(curl -s http://localhost:20001/api/telemetry/power | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    TEMP=$(curl -s http://localhost:20001/api/telemetry/temperature | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    COMMS=$(curl -s http://localhost:20001/api/telemetry/comms | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    
    echo -e "📊 Total: ${BLUE}${TOTAL}${NC} logs"
    echo -e "   💻 Sistema: ${SYSTEM}  🔋 Potencia: ${POWER}  🌡️  Temperatura: ${TEMP}  📡 Comms: ${COMMS}"
    echo ""
    
    sleep 2
done

# Detener simulador
kill $BRIDGE_PID 2>/dev/null || true
cd ..

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DEMOSTRACIÓN COMPLETADA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Mostrar URLs
echo "📱 Accede a los logs:"
echo ""
if [ "$FRONTEND_OK" = true ]; then
    echo -e "   🖥️  Frontend: ${BLUE}http://localhost:20002${NC}"
    echo "   → Abre la pestaña 'Logs' para ver los datos"
else
    echo "   ⚠️  Frontend no iniciado"
    echo "   Inicia con: cd Fomalhaut && npm run dev"
fi
echo ""
echo -e "   🔌 Backend API: ${BLUE}http://localhost:20001/api${NC}"
echo ""
echo "🔍 Ver todos los logs:"
echo "   curl http://localhost:20001/api/telemetry | jq"
echo ""
echo "🔍 Ver logs por tipo:"
echo "   curl http://localhost:20001/api/telemetry/system | jq"
echo "   curl http://localhost:20001/api/telemetry/power | jq"
echo "   curl http://localhost:20001/api/telemetry/temperature | jq"
echo "   curl http://localhost:20001/api/telemetry/comms | jq"
echo ""
echo "💡 Próximos pasos:"
echo "   1. Abre el Frontend en tu navegador"
echo "   2. Navega a la pestaña 'Logs'"
echo "   3. Verás los datos de telemetría en tiempo real"
echo "   4. Conecta un ESP32 real y ejecuta:"
echo "      cd bridge && python3 esp32_to_fomalhaut_bridge.py"
echo ""
