FROM ubuntu:16.04
MAINTAINER zarra  <xsp@xyan.net.cn>

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Update sources
RUN apt-get update -y

RUN apt-get install -y sudo

# install http
RUN apt-get install -y apache2 vim bash-completion unzip
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# install mysql
RUN apt-get install -y mysql-client mysql-server
#RUN echo "NETWORKING=yes" > /etc/sysconfig/network
# start mysqld to create initial tables
#RUN service mysqld start

# install php
#RUN apt-get install -y php5 php5-mysql php5-dev php5-gd php5-memcache php5-pspell php5-snmp snmp php5-xmlrpc libapache2-mod-php5 php5-cli
#RUN yum install -y php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml

RUN apt-get install -y phpmyadmin  php-mbstring php-gettext

RUN cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf

RUN a2enconf phpmyadmin

# install supervisord

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

# install sshd
RUN apt-get install -y openssh-server openssh-client passwd
RUN mkdir -p /var/run/sshd

#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
#RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
#RUN echo 'root:changeme' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
#RUN mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 700 /root/.ssh
#ADD id_rsa.pub /root/.ssh/authorized_keys

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#add user zarra
RUN adduser --quiet --disabled-password -shell /bin/bash --home /home/zarra  --gecos "User" zarra

# set password
RUN echo "zarra:zarra" | chpasswd

RUN adduser zarra  sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers



ADD phpinfo.php /var/www/html/
ADD supervisord.conf /etc/

#COPY docker-entrypoint.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
#ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 22 80 443 3306

CMD ["supervisord", "-n"]
