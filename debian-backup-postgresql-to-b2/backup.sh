#!/usr/bin/env bash

set -eo pipefail
set -o pipefail

if [ -z "${B2_APPLICATION_KEY_ID}" ]; then
  echo "You need to set the B2_APPLICATION_KEY_ID environment variable."
  exit 1
fi

if [ -z "${B2_APPLICATION_KEY}" ]; then
  echo "You need to set the B2_APPLICATION_KEY environment variable."
  exit 1
fi

if [ -z "${B2_BUCKET}" ]; then
  echo "You need to set the B2_BUCKET environment variable."
  exit 1
fi

if [ -z "${B2_PREFIX}" ]; then
  echo "You need to set the B2_PREFIX environment variable."
  exit 1
fi

if [ -z "${POSTGRES_DATABASE}" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ -z "${POSTGRES_HOST}" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ -z "${POSTGRES_PORT}" ]; then
  echo "You need to set the POSTGRES_PORT environment variable."
  exit 1
fi

if [ -z "${POSTGRES_USER}" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."

pg_dump $POSTGRES_HOST_OPTS $POSTGRES_DATABASE | gzip > dump.sql.gz

echo "Authenticating to b2..."

b2 authorize-account "${B2_APPLICATION_KEY_ID}" "${B2_APPLICATION_KEY}"

echo "Uploading dump to $B2_BUCKET"

b2 upload-file ${B2_BUCKET} ./dump.sql.gz ${B2_PREFIX}/${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H-%M-%SZ").sql.gz || exit 2

echo "SQL backup uploaded successfully"
