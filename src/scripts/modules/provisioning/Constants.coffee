keyMirror = require('react/lib/keyMirror')

module.exports =
  ActionTypes: keyMirror(
    CREDENTIALS_MYSQL_SANDBOX_LOAD: null
    CREDENTIALS_MYSQL_SANDBOX_LOAD_SUCCESS: null
    CREDENTIALS_MYSQL_SANDBOX_LOAD_ERROR: null

    CREDENTIALS_MYSQL_SANDBOX_CREATE: null
    CREDENTIALS_MYSQL_SANDBOX_CREATE_SUCCESS: null
    CREDENTIALS_MYSQL_SANDBOX_CREATE_ERROR: null

    CREDENTIALS_MYSQL_SANDBOX_DROP: null
    CREDENTIALS_MYSQL_SANDBOX_DROP_SUCCESS: null
    CREDENTIALS_MYSQL_SANDBOX_DROP_ERROR: null

    CREDENTIALS_REDSHIFT_SANDBOX_LOAD: null
    CREDENTIALS_REDSHIFT_SANDBOX_LOAD_SUCCESS: null
    CREDENTIALS_REDSHIFT_SANDBOX_LOAD_ERROR: null

    CREDENTIALS_REDSHIFT_SANDBOX_CREATE: null
    CREDENTIALS_REDSHIFT_SANDBOX_CREATE_SUCCESS: null
    CREDENTIALS_REDSHIFT_SANDBOX_CREATE_ERROR: null

    CREDENTIALS_REDSHIFT_SANDBOX_REFRESH: null
    CREDENTIALS_REDSHIFT_SANDBOX_REFRESH_SUCCESS: null
    CREDENTIALS_REDSHIFT_SANDBOX_REFRESH_ERROR: null

    CREDENTIALS_REDSHIFT_SANDBOX_DROP: null
    CREDENTIALS_REDSHIFT_SANDBOX_DROP_SUCCESS: null
    CREDENTIALS_REDSHIFT_SANDBOX_DROP_ERROR: null

    CREDENTIALS_WRDB_LOAD: null
    CREDENTIALS_WRDB_LOAD_SUCCESS: null
    CREDENTIALS_WRDB_LOAD_ERROR: null

    CREDENTIALS_WRDB_CREATE: null
    CREDENTIALS_WRDB_CREATE_SUCCESS: null
    CREDENTIALS_WRDB_CREATE_ERROR: null

    CREDENTIALS_WRDB_DROP: null
    CREDENTIALS_WRDB_DROP_SUCCESS: null
    CREDENTIALS_WRDB_DROP_ERROR: null
  )
