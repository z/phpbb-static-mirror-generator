#!/usr/bin/env bash
# mirror.sh
# used to crawl phpBB based on advice from https://www.archiveteam.org/index.php/PhpBB

FORUM_URL="http://${VIRTUAL_HOST}/index.php"
COOKIE_FILE="COOKIEFILE"
ARCHIVE_DIR="/application/archived"
CRAWLER_WAIT=${CRAWLER_WAIT:-2}

mkdir -p "${ARCHIVE_DIR}"
pushd "${ARCHIVE_DIR}"

sleep ${CRAWLER_START_WAIT}

echo "Waiting for forums to come online"
until $(wget --spider -S "${FORUM_URL}" 2>&1 | grep -q "HTTP/1.1 200" || exit 1); do
  printf '.'; sleep 3;
done

wget --spider --keep-session-cookies --save-cookies="${COOKIE_FILE}" ${FORUM_URL}
wget -m -np -w ${CRAWLER_WAIT} -a ${VIRTUAL_HOST}_phpBB3_$(date +%Y%m%d).log -e robots=off -nv --adjust-extension \
    --convert-links --page-requisites --reject-regex='(\?p=|&p=|mode=reply|view=|search.php|feed.php|cron.php|mode=viewprofile)' \
    --warc-file=${VIRTUAL_HOST}_phpBB3_$(date +%Y%m%d) --warc-cdx --keep-session-cookies --load-cookies="${COOKIE_FILE}" ${FORUM_URL}

