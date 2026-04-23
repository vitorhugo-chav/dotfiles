#!/bin/bash

# Níveis de alerta
WARNING_LEVEL=20
CRITICAL_LEVEL=10
EMPTY_LEVEL=5

# Travas para não floodar a tela
NOTIFIED_WARNING=false
NOTIFIED_CRITICAL=false

while true; do
    # Descobre automaticamente o nome da sua bateria (BAT0, BAT1, etc)
    BATTERY=$(ls /sys/class/power_supply/ | grep -i bat | head -n 1)
    
    # Se não achar bateria, o script morre silenciosamente
    if [ -z "$BATTERY" ]; then
        exit 0
    fi

    LEVEL=$(cat /sys/class/power_supply/$BATTERY/capacity)
    STATUS=$(cat /sys/class/power_supply/$BATTERY/status)

    # Se estiver carregando, reseta as travas
    if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
        NOTIFIED_WARNING=false
        NOTIFIED_CRITICAL=false
        sleep 60
        continue
    fi

    # Lógica de Notificações
    if [ "$LEVEL" -le "$EMPTY_LEVEL" ]; then
        notify-send -u critical "Bateria no Fim" "O sistema vai apagar! Nível: $LEVEL%"
        sleep 60 # Avisa a cada minuto no final
    elif [ "$LEVEL" -le "$CRITICAL_LEVEL" ] && [ "$NOTIFIED_CRITICAL" = false ]; then
        notify-send -u critical "Bateria Crítica" "Conecte o carregador agora! Nível: $LEVEL%"
        NOTIFIED_CRITICAL=true
    elif [ "$LEVEL" -le "$WARNING_LEVEL" ] && [ "$NOTIFIED_WARNING" = false ]; then
        notify-send -u normal "Bateria Fraca" "Você tem apenas $LEVEL% de bateria."
        NOTIFIED_WARNING=true
    fi

    # Aguarda 60 segundos antes de checar de novo
    sleep 60
done
