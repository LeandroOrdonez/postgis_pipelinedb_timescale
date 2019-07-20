cat > $ROOT_CONF/timescaledb.conf << EOF
shared_preload_libraries = 'timescaledb'
#shared_buffers = 3917MB
#effective_cache_size = 11752MB
#maintenance_work_mem = 1958MB
#work_mem = 5014kB
#timescaledb.max_background_workers = 8
#max_worker_processes = 19
#max_parallel_workers_per_gather = 4
#max_parallel_workers = 8
#wal_buffers = 16MB
#min_wal_size = 4GB
#max_wal_size = 8GB
#default_statistics_target = 500
#random_page_cost = 1.1
#checkpoint_completion_target = 0.9
#max_locks_per_transaction = 128
#autovacuum_max_workers = 10
#autovacuum_naptime = 10
#effective_io_concurrency = 200
EOF

echo "include 'timescaledb.conf'" >> $ROOT_CONF/postgresql.conf

timescaledb-tune --yes
