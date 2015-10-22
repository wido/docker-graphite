FROM ubuntu:14.04

RUN apt-get -y install wget
RUN wget -O /etc/apt/sources.list http://apt-get.eu/trusty/sources.list && apt-get -y update

RUN	apt-get -y install python-ldap python-cairo python-django python-twisted python-django-tagging python-simplejson python-memcache python-pysqlite2 python-support python-pip supervisor apache2 libapache2-mod-wsgi
RUN	pip install whisper \
    && pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon \
    && pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

RUN rm /etc/apache2/sites-enabled/*
RUN a2enmod wsgi

ADD	./apache2.vhost.conf /etc/apache2/sites-enabled/graphite.conf
ADD ./graphite.wsgi /var/lib/graphite/conf/graphite.wsgi
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
ADD ./local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
ADD ./carbon.conf /var/lib/graphite/conf/carbon.conf
ADD ./storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf

RUN mkdir -p /var/lib/graphite/storage/whisper
RUN touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index
RUN chown -R www-data /var/lib/graphite/storage
RUN chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper
RUN chmod 0664 /var/lib/graphite/storage/graphite.db
RUN cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

EXPOSE 80 2003 2004 7002

CMD ["/usr/bin/supervisord"]
