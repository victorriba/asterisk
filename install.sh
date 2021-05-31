apt update
apt install -y libssl-dev libsasl2-dev libncurses5-dev libnewt-dev libxml2-dev libsqlite3-dev libjansson-dev libcurl4-openssl-dev libedit-dev pkg-config build-essential cmake autoconf uuid-dev wget file git sudo nano iptables fail2ban
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
systemctl enable asterisk
service asterisk enable
service asterisk start
asterisk -r
ls
echo '' > /etc/asterisk/sip.conf 
nano /etc/asterisk/pjsip.conf 
apt isntall nano
apt install nano
nano /etc/asterisk/pjsip.conf 
echo ''> /etc/asterisk/pjsip.conf
nano /etc/asterisk/pjsip.conf 
nano /etc/asterisk/extconfig.conf 
nano /etc/asterisk/sorcery.conf 
nano /etc/asterisk/ast_mongo.conf
asterisk -r 
echo ''> /etc/asterisk/extensions.conf 
nano /etc/asterisk/extensions.conf 
nano /etc/asterisk/http.conf 
nano /etc/asterisk/ari.conf 
mkdir /etc/asterisk/keys
asterisk -r
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
nano ~/.bashrc
