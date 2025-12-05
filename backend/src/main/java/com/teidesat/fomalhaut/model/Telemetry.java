package com.teidesat.fomalhaut.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * Telemetry Data Entity
 * Represents a single telemetry log entry from the ESP32
 */
@Entity
@Table(name = "telemetry_data")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Telemetry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String timestamp;
    
    @Column(nullable = false)
    private String type; // system, power, temperature, comms, general
    
    @Column(columnDefinition = "TEXT")
    private String rawLine;
    
    // Campos específicos para cada tipo de telemetría
    private Integer cpuUsage;           // system
    private Integer ramFree;            // system
    private Float voltage;              // power
    private Float current;              // power
    private Float temperature;          // temperature
    private Integer rssi;               // comms
    private Integer snr;                // comms
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
