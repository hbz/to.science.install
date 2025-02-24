#!/bin/bash

  echo "Install fail2ban Service"

  zypper in fail2ban

  echo "Start fail2ban"
  systemctl enable fail2ban.service
  systemctl start fail2ban.service
 
# Bemerkung: Es wurde ein Verzeichnis /etc/fail2ban angelegt
# ggfs. die Inhalte kontrollieren / ergänzen
