apt update
apt install -y libssl-dev libsasl2-dev libncurses5-dev libnewt-dev libxml2-dev libsqlite3-dev libjansson-dev libcurl4-openssl-dev libedit-dev pkg-config build-essential cmake autoconf uuid-dev wget file git sudo nano iptables certbot
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
make menuselect

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
dateformat = %F %T

[logfiles]
console => notice,warning,error
messages => notice,warning,error,security' > /etc/asterisk/logger.conf

cd /usr/src
git clone https://github.com/fail2ban/fail2ban.git
cd fail2ban
sudo python setup.py install

cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban start

mkdir /etc/asterisk/keys

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

