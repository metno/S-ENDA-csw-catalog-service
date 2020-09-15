FROM metno/pycsw:2.4.2

USER root

ADD --chown=pycsw:pycsw pycsw.cfg /etc/pycsw/pycsw.cfg
ADD pycsw_setup.sh /usr/local/bin/pycsw_setup.sh

USER pycsw

ENTRYPOINT ["/usr/local/bin/pycsw_setup.sh"]
