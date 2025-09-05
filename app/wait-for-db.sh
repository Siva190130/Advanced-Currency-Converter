#!/bin/bash
set -e

echo "Waiting for database $DB_HOST:$DB_PORT ..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  echo "Database not ready, sleeping..."
  sleep 3
done

echo "Database reachable — starting Tomcat"
exec catalina.sh run
