apt update
apt install -y libssl-dev libsasl2-dev libncurses5-dev libnewt-dev libxml2-dev libsqlite3-dev libjansson-dev libcurl4-openssl-dev libedit-dev pkg-config build-essential cmake autoconf uuid-dev wget file git sudo nano iptables fail2ban certbot
iptables -L -v
iptables -F
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -p udp -m udp --dport 5060:6000 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 8000:20000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8088 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8089 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3389 -j ACCEPT
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sundayddr" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipsak" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipvicious" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "iWar" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "VaxSIPUserAgent/" --algo bm
/sbin/iptables-save
cd /usr/src
wget -nv "https://github.com/mongodb/mongo-c-driver/releases/download/1.13.0/mongo-c-driver-1.13.0.tar.gz" -O - | tar xzf -
cd mongo-c-driver-1.13.0
mkdir cmake-build
cd cmake-build
cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF ..
make all && sudo make install
cd /usr/src
wget -nv "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-16.9.0.tar.gz" -O - | tar -zxf -
cd asterisk*
wget https://raw.githubusercontent.com/minoruta/ast_mongo/master/patches/ast_mongo-16.0.0.patch
patch -p1 -i ast_mongo-16.0.0.patch
contrib/scripts/install_prereq install
./bootstrap.sh
./configure --with-jansson-bundled
#make menuselect
make menuselect.makeopts
menuselect/menuselect --enable format_mp3  menuselect.makeopts
menuselect/menuselect --enable codec_opus  menuselect.makeopts
menuselect/menuselect --enable codec_silk  menuselect.makeopts
menuselect/menuselect --enable codec_siren7  menuselect.makeopts
menuselect/menuselect --enable codec_siren14  menuselect.makeopts
menuselect/menuselect --disable cdr_custom menuselect.makeopts
menuselect/menuselect --disable cdr_mongodb menuselect.makeopts
menuselect/menuselect --disable cdr_odbc menuselect.makeopts
menuselect/menuselect --disable cdr_pgsql menuselect.makeopts
menuselect/menuselect --disable cdr_radius menuselect.makeopts
menuselect/menuselect --disable cdr_sqlite3_custom menuselect.makeopts
menuselect/menuselect --disable cel_mongodb menuselect.makeopts
menuselect/menuselect --disable cel_pgsql menuselect.makeopts
menuselect/menuselect --disable cel_radius menuselect.makeopts
menuselect/menuselect --disable cel_sqlite3_custom menuselect.makeopts

contrib/scripts/get_mp3_source.sh
make
make install
make config
make samples
ldconfig

service asterisk start

cd /usr/src
wget -nv "http://downloads.digium.com/pub/telephony/codec_opus/asterisk-16.0/x86-64/codec_opus-16.0_current-x86_64.tar.gz" -O - | tar -zxf -
cd codec_opus-16.0_1.3.0-x86_64/
cp -rf codec_opus.so /usr/lib/asterisk/modules/codec_opus.so
cp -rf codec_opus_config-en_US.xml /var/lib/asterisk/documentation/thirdparty/codec_opus_config-en_US.xml
cd /usr/src
wget -c http://asterisk.hosting.lv/bin/codec_g723-ast160-gcc4-glibc-x86_64-core2.so
wget -c http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-core2.so
cp -rf codec_g723-ast160-gcc4-glibc-x86_64-core2.so /usr/lib/asterisk/modules/codec_g723.so
cp -rf codec_g729-ast160-gcc4-glibc-x86_64-core2.so /usr/lib/asterisk/modules/codec_g729.so
chmod 755 /usr/lib/asterisk/modules/codec_g723.so
chmod 755 /usr/lib/asterisk/modules/codec_g729.so
service asterisk restart

echo '' > /etc/asterisk/sip.conf

echo '[transport-tcp]
type=transport
protocol=tcp
bind=0.0.0.0

[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0

[transport-wss]
type=transport
protocol=wss
bind=0.0.0.0

[transport-ws]
type=transport
protocol=ws
bind=0.0.0.0' > /etc/asterisk/pjsip.conf


echo '[general]
enabled=yes
bindaddr=0.0.0.0
bindport=8088
tlsenable=yes
tlsbindaddr=0.0.0.0:8089
tlscertfile=/etc/asterisk/keys/asterisk.crt
tlsprivatekey=/etc/asterisk/keys/asterisk.key' > /etc/asterisk/http.conf


echo '[res_pjsip]
endpoint=realtime,ps_endpoints  ; map endpoint to ps_endpoints source
auth=realtime,ps_auths          ; map auth to ps_auths source
aor=realtime,ps_aors            ; map aor to ps_aors source

[res_pjsip_endpoint_identifier_ip]
identify=realtime,ps_identifies

[res_pjsip_outbound_registration]
registration=realtime,ps_registrations' > /etc/asterisk/sorcery.conf

echo '[settings]
ps_endpoints => mongodb,asterisk
ps_auths => mongodb,asterisk
ps_aors => mongodb,asterisk
ps_registrations => mongodb,asterisk
ps_identifies => mongodb,asterisk' > /etc/asterisk/extconfig.conf

echo '[dial]
exten => _X.,1,Stasis(dial)

[outbound]
exten => _X.,1,Stasis(outbound)

[inbound]
exten => _X.,1,Stasis(inbound)

[bot]
exten => _X.,1,Stasis(bot)' > /etc/asterisk/extensions.conf

echo '[general]
enabled = yes
pretty = yes
allowed_origins = localhost:8088,http://apiserver.com

[asterisk]
type = user
read_only = no
password = astsystempassword' > /etc/asterisk/ari.conf


echo '[modules]
autoload=yes
noload => chan_alsa.so
noload => chan_console.so
noload => chan_sip.so
noload => res_hep.so
noload => res_hep_pjsip.so
noload => res_hep_rtcp.so' > /etc/asterisk/modules.conf


echo '[common]
[config]
uri=mongodb://mongodb:27017/asterisk' > /etc/asterisk/ast_mongo.conf

echo '[general]
rtpstart=8000
rtpend=20000' > /etc/asterisk/rtp.conf

echo '[general]

[logfiles]
console => notice,warning,error
messages => notice,warning,error,security' > /etc/asterisk/logger.conf

mkdir /etc/asterisk/keys

echo '[INCLUDES]

before = paths-debian.conf

[DEFAULT]
ignorecommand =
bantime  = 10m
findtime  = 10m
maxretry = 5
maxmatches = %(maxretry)s
backend = systemd
usedns = warn
logencoding = auto
enabled = false
mode = normal
filter = %(__name__)s[mode=%(mode)s]
destemail = root@localhost
sender = root@<fq-hostname>
mta = sendmail
protocol = tcp
chain = <known/chain>
port = 0:65535
fail2ban_agent = Fail2Ban/%(fail2ban_version)s
banaction = iptables-multiport
banaction_allports = iptables-allports
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
            %(mta)s-whois[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
             %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath="%(logpath)s", chain="%(chain)s"]
action_xarf = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
             xarf-login-attack[service=%(__name__)s, sender="%(sender)s", logpath="%(logpath)s", port="%(port)s"]
action_cf_mwl = cloudflare[cfuser="%(cfemail)s", cftoken="%(cfapikey)s"]
                %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath="%(logpath)s", chain="%(chain)s"]
action_blocklist_de  = blocklist_de[email="%(sender)s", service=%(filter)s, apikey="%(blocklist_de_apikey)s", agent="%(fail2ban_agent)s"]
action_badips = badips.py[category="%(__name__)s", banaction="%(banaction)s", agent="%(fail2ban_agent)s"]
action_badips_report = badips[category="%(__name__)s", agent="%(fail2ban_agent)s"]
action_abuseipdb = abuseipdb
action = %(action_)s

[asterisk]
enabled  = true
port     = 5060,5061
action   = %(banaction)s[name=%(__name__)s-tcp, port="%(port)s", protocol="tcp", chain="%(chain)s", actname=%(banaction)s-tcp]
           %(banaction)s[name=%(__name__)s-udp, port="%(port)s", protocol="udp", chain="%(chain)s", actname=%(banaction)s-udp]
           %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s"]
logpath  = /var/log/asterisk/messages
maxretry = 10' > /etc/fail2ban/jail.conf

certbot certonly --standalone -d sip.domain.com

cp /etc/letsencrypt/live/sip.domain.com/privkey.pem /etc/asterisk/keys/asterisk.key
cp /etc/letsencrypt/live/sip.domain.com/fullchain.pem /etc/asterisk/keys/asterisk.crt

chmod 777 /etc/asterisk/keys/asterisk.crt 
chmod 777 /etc/asterisk/keys/asterisk.key 

service asterisk restart

nano ~/.bashrc
service asterisk start
rm /var/run/fail2ban/fail2ban.sock
service fail2ban start

