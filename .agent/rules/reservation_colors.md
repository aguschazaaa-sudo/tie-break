---
description: Código de colores y estados visuales para reservas en el timeline
---

# Sistema de Colores de Reservas

## Colores por Tipo de Reserva

| Tipo | Color del Theme | Uso |
|------|-----------------|-----|
| **Normal** | `primaryContainer` / `onPrimaryContainer` | Reserva estándar de cancha |
| **2 vs 2** | `tertiaryContainer` / `onTertiaryContainer` | Partido buscando contrincantes |
| **Falta 1** | `secondaryContainer` / `onSecondaryContainer` | Partido que necesita un jugador |

## Estados Visuales

| Estado | Visual | Descripción |
|--------|--------|-------------|
| **Pendiente** | Borde naranja + ⚠️ warning | Requiere aprobación del admin |
| **Aprobada** | ✅ Icono verde | Reserva confirmada |
| **Incompleta** | Opacidad 40% + "Buscando..." | 2vs2/Falta1 sin completar equipo |
| **Cancelada/Rechazada** | No se muestra | Filtradas del timeline |

## Indicadores de Pago (modo admin)

| Estado | Icono | Texto |
|--------|-------|-------|
| Pagado | ✓ check_circle | "Pagado" |
| Parcial | pie_chart | "Parcial" |
| Pendiente | schedule | "Pend." |
| Reembolsado | replay | "Reemb." |
