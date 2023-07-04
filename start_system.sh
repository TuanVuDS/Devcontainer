#!/bin/bash
systemctl start postgresql
systemctl enable postgresql
service postgresql start
systemctl start zookeeper
systemctl enable zookeeper
systemctl start kafka
systemctl enable kafka