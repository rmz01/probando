# 🛰️ TEIDESAT - Sistema Completo ESP32 → Fomalhaut Logs

Guía para ver los logs del ESP32 en tiempo real en el dashboard de Fomalhaut.

## 🎯 Arquitectura del Sistema

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐     ┌─────────────┐
│   ESP32     │────▶│ Python Bridge│────▶│    Backend   │────▶│  Frontend   │
│  (Logs)     │     │   (Parser)   │     │ (Java Spring)│     │   (React)   │
└─────────────┘     └──────────────┘     └──────────────┘     └─────────────┘
  Serial Port       TCP Connection      HTTP REST API        Navegador
  115200 baud       Parsing JSON        Puerto 20001         Puerto 20002
```

## ⚡ Inicio Rápido (2 minutos)

### Opción 1: Todo en Docker (Recomendado ✅)

```bash
# 1. Clonar/estar en el directorio
cd /home/u/Teidesat/probando

# 2. Iniciar todo
docker-compose up -d

# 3. Abrir en navegador
# Frontend: http://localhost:20002
# Backend: http://localhost:20001/api
```

### Opción 2: Ejecución Local

```bash
# 1. Compilar backend
cd backend
mvn clean package

# 2. Ejecutar backend
java -jar target/fomalhaut-backend-1.0.0.jar &

# 3. Ejecutar frontend (en otra terminal)
cd Fomalhaut
npm install
npm run dev

# 4. El bridge se ejecutará con el ESP32 (ver abajo)
```

## 📊 Ver Logs en Fomalhaut

### Opción A: Simulación (Para Testing)

```bash
# Terminal 1: Ir al directorio del proyecto
cd /home/u/Teidesat/probando

# Terminal 2: Ejecutar demostración automática
./demo.sh
```

Esto:
- ✅ Limpia logs previos
- ✅ Inicia un simulador de ESP32
- ✅ Genera datos de telemetría
- ✅ Los muestra en el Backend
- ✅ Te da URLs para ver en Frontend

### Opción B: ESP32 Real Conectado

```bash
# 1. Asegúrate que Backend está corriendo (puerto 20001)
curl http://localhost:20001/api/telemetry

# 2. Conecta el ESP32 con cable USB

# 3. Configura el puerto serial
cd bridge
nano config.json
# Cambia "port": "/dev/ttyUSB0" al puerto correcto

# 4. Ejecuta el bridge
python3 esp32_to_fomalhaut_bridge.py
```

Los logs aparecerán automáticamente en Frontend → Logs

## 🌐 URLs de Acceso

| Servicio | URL | Puerto |
|----------|-----|--------|
| **Frontend** | http://localhost:20002 | 20002 |
| **Backend API** | http://localhost:20001/api | 20001 |
| **BD (H2)** | http://localhost:20001/api/h2-console | 20001 |

## 📡 API REST - Ejemplos de Uso

### Obtener todos los logs

```bash
curl http://localhost:20001/api/telemetry | jq
```

### Obtener por tipo

```bash
# Solo sistema
curl http://localhost:20001/api/telemetry/system | jq

# Solo potencia
curl http://localhost:20001/api/telemetry/power | jq

# Solo temperatura
curl http://localhost:20001/api/telemetry/temperature | jq

# Solo comunicaciones
curl http://localhost:20001/api/telemetry/comms | jq
```

### Últimos N logs

```bash
curl http://localhost:20001/api/telemetry/latest/50 | jq
```

### Limpiar logs

```bash
curl -X DELETE http://localhost:20001/api/telemetry/clear
```

## 📁 Estructura del Proyecto

```
probando/
├── backend/                              ← Backend Java-Spring 🆕
│   ├── pom.xml
│   ├── Dockerfile
│   ├── README.md
│   └── src/
│       └── main/java/com/teidesat/fomalhaut/
│           ├── FomalhautBackendApplication.java
│           ├── controller/TelemetryController.java
│           ├── model/Telemetry.java
│           └── repository/TelemetryRepository.java
│
├── bridge/                               ← Python Bridge (actualizado)
│   ├── esp32_to_fomalhaut_bridge.py      ← Lee ESP32 y envía al backend
│   ├── config.json                       ← Configuración (puerto 20001)
│   ├── simulate_esp32.py                 ← Simula ESP32 para testing
│   ├── requirements.txt
│   ├── README.md
│   ├── test_bridge.py
│   ├── validate_setup.sh
│   └── ARCHITECTURE.md
│
├── Fomalhaut/                            ← Frontend React (actualizado)
│   ├── src/components/pages/Logs/        ← Página de Logs
│   │   ├── Logs.tsx                      ← Componente principal
│   │   ├── LogsService.ts                ← Servicio HTTP
│   │   └── Log.model.ts
│   ├── package.json
│   ├── Dockerfile
│   └── vite.config.ts
│
├── docker-compose.yml                    ← Orquestar todo 🆕
├── start_system.sh                       ← Iniciar todo 🆕
├── demo.sh                               ← Demostración 🆕
└── README.md                             ← Este archivo
```

## 🔧 Configuración Personalizada

### Puerto del Backend

Edita `backend/src/main/resources/application.properties`:

```properties
server.port=20001  # Cambiar aquí
```

### Puerto Serial del Bridge

Edita `bridge/config.json`:

```json
{
  "serial": {
    "port": "/dev/ttyUSB0"  // Cambiar aquí
  },
  "server": {
    "base_url": "http://localhost:20001/api"
  }
}
```

### Frontend URL del Backend

Edita `Fomalhaut/src/environments/environment.ts`:

```typescript
export const environment = {
  REST_GSCS: "http://localhost:20001/api",  // Cambiar aquí
  BEARER_TOKEN: "Bearer holis123",
};
```

## 🐛 Troubleshooting

### "Port 20001 already in use"

```bash
# Ver qué ocupa el puerto
lsof -i :20001

# Liberar puerto
kill -9 <PID>

# O usar otro puerto (ver configuración)
```

### "Backend no responde"

```bash
# Verificar que está corriendo
curl -v http://localhost:20001/api/telemetry

# Ver logs
docker logs fomalhaut-backend
# O si es local:
cat /tmp/backend.log
```

### "Frontend no carga"

```bash
# Verificar que está corriendo
curl http://localhost:20002

# Ejecutar manualmente
cd Fomalhaut
npm install
npm run dev
```

### "Bridge no envía datos"

```bash
# Verificar configuración
cat bridge/config.json

# Modo debug activado
cd bridge
python3 esp32_to_fomalhaut_bridge.py
```

## 🚀 Flujo Completo de Datos

1. **ESP32 genera logs**
   ```
   [Sistema] CPU: 45%, RAM: 234KB
   [Potencia] Voltaje: 3.7V, Corriente: 0.5A
   ```

2. **Bridge Python lee el puerto serial**
   ```python
   line = serial_port.readline()
   # "[Sistema] CPU: 45%, RAM: 234KB"
   ```

3. **Bridge parsea el log a JSON**
   ```json
   {
     "type": "system",
     "cpu_usage": 45,
     "ram_free": 234,
     "timestamp": "2025-12-04T10:30:45.123456"
   }
   ```

4. **Bridge envía al backend por HTTP**
   ```bash
   POST http://localhost:20001/api/telemetry/system
   Content-Type: application/json
   [JSON arriba]
   ```

5. **Backend almacena en BD**
   ```sql
   INSERT INTO telemetry_data VALUES (...)
   ```

6. **Frontend consulta backend**
   ```javascript
   GET http://localhost:20001/api/telemetry
   ```

7. **Frontend muestra logs en tabla**
   ```
   💻 CPU: 45%
   🔋 V: 3.7V, I: 0.5A
   🌡️ T: 25.3°C
   ```

## 📊 Dashboard Fomalhaut

En la pestaña **Logs** verás:

- 📊 **Telemetry Logs** - Todos los logs en tiempo real
- 🔤 **Filtros** - Por tipo (System, Power, Temperature, Comms)
- 🔄 **Auto Refresh** - Se actualiza cada 2 segundos
- 📋 **Detalles** - Haz clic en un log para ver detalles completos

## 💡 Ejemplos de Uso

### Ver datos en tiempo real

```bash
watch -n 1 'curl -s http://localhost:20001/api/telemetry | jq ".[0]"'
```

### Exportar logs a archivo

```bash
curl http://localhost:20001/api/telemetry > logs.json
```

### Procesar logs con Python

```python
import requests
import json

response = requests.get('http://localhost:20001/api/telemetry')
logs = response.json()

for log in logs:
    if log['type'] == 'system':
        print(f"CPU: {log.get('cpu_usage')}%")
```

## 📚 Documentación Adicional

- [Backend README](backend/README.md) - Detalles técnicos del servidor
- [Bridge README](bridge/README.md) - Configuración del puente Python
- [ARCHITECTURE.md](bridge/ARCHITECTURE.md) - Diagramas técnicos

## 🎓 Pasos para Producción

1. **Cambiar BD**: De H2 a PostgreSQL/MySQL
2. **Configurar HTTPS**: Añadir SSL/TLS
3. **Autenticación**: Implementar JWT
4. **Logging**: Guardar logs a archivo
5. **Monitoreo**: Implementar health checks
6. **Escalado**: Preparar para múltiples dispositivos

## ✅ Checklist Final

- [ ] Docker/Docker-Compose instalado (opcional pero recomendado)
- [ ] Java 17+ instalado
- [ ] Python3 + dependencias instaladas
- [ ] Backend compilado y corriendo (puerto 20001)
- [ ] Frontend corriendo (puerto 20002)
- [ ] Bridge Python configurado
- [ ] Acceso a http://localhost:20002 en navegador
- [ ] Logs visibles en pestaña "Logs" del frontend

## 🎉 ¡Listo!

Ya tienes el sistema completo funcionando. Los logs del ESP32 se muestran en tiempo real en el dashboard de Fomalhaut.

**Para comenzar:**

```bash
cd /home/u/Teidesat/probando
./demo.sh
```

---

**Última actualización:** Diciembre 2025  
**Versión:** 2.0  
**Autor:** TeideSat Team  
**Licencia:** GPL-3.0
