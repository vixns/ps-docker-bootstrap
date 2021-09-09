#!/bin/sh

exec 2>&1
if [ ! -e "/etc/proxysql/proxysql.cnf.tpl" ]; then
  touch down
  sv down .
  exit 0
fi

mkdir -p /tmp/proxysql

cp /etc/proxysql/proxysql.cnf.tpl /etc/service/proxysql/proxysql.cnf

sed -e "s/MYSQL1/${MYSQL1}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/MYSQL2/${MYSQL2}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/MYSQL_USER/${MYSQL_USER}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/MYSQL_PASSWORD/${MYSQL_PASSWORD}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/ADMIN_USER/${PROXYSQL_ADMIN_USER:-admin}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/ADMIN_PASSWORD/${PROXYSQL_ADMIN_PASSWORD:-pleasechangeme}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/MONITOR_PASSWORD/${PROXYSQL_MONITOR_PASSWORD:-pleasechangeme}/g" -i /etc/service/proxysql/proxysql.cnf
sed -e "s/MYSQL3/${MYSQL3}/g" -i /etc/service/proxysql/proxysql.cnf

a=$(nping -c 1 --tcp-connect -p 3306 $MYSQL1 | grep rtt | awk '{print $3}' | tr -d 'ms' | awk -F'=' '{print $1 * 1000}')
b=$(nping -c 1 --tcp-connect -p 3306 $MYSQL2 | grep rtt | awk '{print $3}' | tr -d 'ms' | awk -F'=' '{print $1 * 1000}')
c=$(nping -c 1 --tcp-connect -p 3306 $MYSQL3 | grep rtt | awk '{print $3}' | tr -d 'ms' | awk -F'=' '{print $1 * 1000}')

if [ $a -lt $b -a $a -lt $c ]
then
  sed -e "s/${MYSQL1}.*weight=1/\000/g" -i /etc/service/proxysql/proxysql.cnf
elif [ $b -lt $c -a $b -lt $a ]
then
  sed -e "s/${MYSQL2}.*weight=1/\000/g" -i /etc/service/proxysql/proxysql.cnf
else
  sed -e "s/${MYSQL3}.*weight=1/\000/g" -i /etc/service/proxysql/proxysql.cnf
fi

exec proxysql -c /etc/service/proxysql/proxysql.cnf -D /tmp/proxysql -f -e
