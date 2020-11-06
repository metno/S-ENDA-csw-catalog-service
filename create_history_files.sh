#!/bin/bash

# Keep bash history between ups and destroys
FILE=/vagrant/lib/dot_bash_history
if [[ ! -f "$FILE" ]]; then
  touch $FILE
  chown vagrant:vagrant $FILE
fi
BHIST=/home/vagrant/.bash_history
ln -sf $FILE $BHIST

# Keep python history between ups and destroys
FILE=/vagrant/lib/dot_python_history
if [[ ! -f "$FILE" ]]; then
  touch $FILE
  chown vagrant:vagrant $FILE
fi
PHIST=/home/vagrant/.python_history
ln -sf $FILE $PHIST

