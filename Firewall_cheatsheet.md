# 🛡️ SOC Cheat Sheet For Firewall

### 1. Gestion du Pare-feu Linux (`iptables`)
`iptables` agit comme la première ligne de défense sur un hôte Linux.

**Commandes de base :**
*   **Lister les règles avec numéros :** `iptables -L -n -v --line-numbers`
*   **Tout bloquer par défaut (White-listing) :** 
    *   `iptables -P INPUT DROP`
    *   `iptables -P FORWARD DROP`
*   **Autoriser une IP spécifique :** `iptables -A INPUT -s [IP_SOURCE] -j ACCEPT`
*   **Bloquer un port spécifique :** `iptables -A INPUT -p tcp --dport [PORT] -j DROP`
*   **Supprimer une règle par numéro :** `iptables -D INPUT [NUMERO]`

**Protection Anti-DDoS / Scan :**
*   **Limiter les connexions SSH :**
    `iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set`
    `iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP`

---

### 2. Capture de Paquets (`tcpdump`)
Essentiel pour l'analyse de trafic suspect en temps réel.


**Filtres essentiels :**
*   **Capturer sur une interface et sauvegarder :** `tcpdump -i eth0 -w capture.pcap`
*   **Filtrer par IP et Port :** `tcpdump -i eth0 host [IP] and port [PORT]`
*   **Voir le contenu en ASCII (Utile pour HTTP/Telnet) :** `tcpdump -A -i eth0`
*   **Exclure le trafic SSH (pour éviter de se capturer soi-même) :** `tcpdump -i eth0 not port 22`
*   **Détecter les scans SYN :** `tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'`

---

### 3. Analyse des Connexions Actives
Pour identifier ce qui communique actuellement avec votre machine.

*   **Lister les ports ouverts et processus liés :** `ss -tulpn` ou `netstat -tunlp`
*   **Vérifier les connexions établies :** `ss -atn | grep ESTAB`
*   **Suivre les sockets en temps réel :** `watch -n 1 "ss -tup"`

---

### 4. Persistence et Automatisation (`UFW`)
Si vous utilisez `ufw` (plus simple qu'iptables), voici les réflexes SOC :

| Action | Commande |
| :--- | :--- |
| **Vérifier l'état** | `ufw status numbered` |
| **Autoriser un service** | `ufw allow 80/tcp` |
| **Interdire une IP** | `ufw deny from [IP]` |
| **Activer les logs** | `ufw logging on` |

---

### 5. Signaux d'Alerte (Red Flags)
Lors de l'exercice, surveillez ces anomalies dans vos logs ou captures :
1.  **Beacons :** Connexions répétées vers une IP externe à intervalles réguliers (C2 potentiel).
2.  **Data Exfiltration :** Pic de trafic sortant inhabituel sur des ports non standard (ex: 53 DNS, 443).
3.  **Port Knocking :** Tentatives de connexion séquentielles sur plusieurs ports fermés.
4.  **User-Agents suspects :** Dans les captures HTTP, cherchez des outils comme `nmap`, `sqlmap` ou `curl` utilisés de manière agressive.

> **Note de sécurité :** Toujours sauvegarder les règles actuelles avant modification lors d'un exercice : `iptables-save > rules_backup.txt`.
