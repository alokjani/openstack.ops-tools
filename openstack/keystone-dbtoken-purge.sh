#!/bin/bash
# Periodic clean up procedure to delete expired tokens in keystone
# Useful for Havana Clouds which used SQL backend for Keystone tokens
#

mysql_user=keystone
mysql_password=FIXME
mysql_host=127.0.0.1
mysql=$(which mysql)

logger -t keystone-cleaner "Starting Keystone 'token' table cleanup"

logger -t keystone-cleaner "Starting token cleanup"
mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; DELETE FROM token WHERE NOT DATE_SUB(CURDATE(),INTERVAL 2 DAY) <= expires;'
valid_token=$($mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; SELECT * FROM token;' | wc -l)
logger -t keystone-cleaner "Finishing token cleanup, there is still $valid_token valid tokens..."

exit 0

# ref. http://www.sebastien-han.fr/blog/2012/12/12/cleanup-keystone-tokens/
