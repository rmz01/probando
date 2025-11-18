#ifndef TELEMETRY_LOGGER_H
#define TELEMETRY_LOGGER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

#define TELEMETRY_LOG_FILE "/telemetry_log.txt"

// Monta LittleFS si hace falta y prepara el archivo de log.
bool telemetry_logger_init(void);

// Escribe una linea formateada al Serial y al archivo.
void telemetry_logf(const char *fmt, ...);

// Vuelca el contenido completo del archivo de log por Serial.
void telemetry_dump_log(void);

// Borra (trunca) el archivo de log para empezar desde cero.
void telemetry_log_clear(void);

#ifdef __cplusplus
}
#endif

#endif // TELEMETRY_LOGGER_H