#!/bin/sh

if [ -z "$PYCSW_DATABASE" ]; then
  PYCSW_DATABASE="sqlite:////home/pycsw/tests.db"
fi

sed -i '/^database=/d' /etc/pycsw/pycsw.cfg
echo database="$PYCSW_DATABASE" >> /etc/pycsw/pycsw.cfg
#database=postgresql://csw_user:csw_password@postgres:5432/csw_db

python3 /usr/local/bin/pycsw-admin.py -c setup_db -f /etc/pycsw/pycsw.cfg

# We can do the indexing in other places
#echo ""
#echo "Indexing records from " $ISO_STORE
#echo ""
#python3 /usr/local/bin/pycsw-admin.py -c load_records -f /etc/pycsw/pycsw.cfg -p "$ISO_STORE" -r -y

python3 /usr/local/bin/entrypoint.py
