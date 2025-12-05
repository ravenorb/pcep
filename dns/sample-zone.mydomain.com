$ORIGIN mydomain.com.
$TTL 3600
@   IN SOA ns1.mydomain.com. admin.mydomain.com. (
        2025010101 ; serial – update whenever changes are made
        3600       ; refresh (1 hour)
        900        ; retry (15 minutes)
        1209600    ; expire (2 weeks)
        86400 )    ; minimum (1 day)

; Name servers
        IN NS ns1.mydomain.com.
        IN NS ns2.mydomain.com.
        IN NS ns3.mydomain.com.

; A/AAAA records
ns1     IN A    192.0.2.10     ; pfSense public IP
ns2     IN A    198.51.100.20  ; VPS1 public IP
ns3     IN A    203.0.113.30   ; VPS2 public IP

mail    IN A    198.51.100.20  ; Mailcow on VPS1
auth    IN A    203.0.113.30   ; Keycloak on VPS2
files   IN A    203.0.113.30   ; Seafile on VPS2
photos  IN A    203.0.113.30   ; Immich on VPS2
notes   IN A    203.0.113.30   ; Joplin on VPS2
git     IN A    203.0.113.30   ; Forgejo on VPS2
dav     IN A    203.0.113.30   ; Baïkal on VPS2

; MX record
@       IN MX   10 mail.mydomain.com.

; SPF record
@       IN TXT  "v=spf1 mx -all"

; DKIM and DMARC would be added by Mailcow or your mail system.

; End of zone file