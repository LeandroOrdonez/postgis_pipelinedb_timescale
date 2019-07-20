cat > $ROOT_CONF/pipelinedb.conf << EOF
shared_preload_libraries = 'pipelinedb'
max_worker_processes = 128
EOF

echo "include 'pipelinedb.conf'" >> $ROOT_CONF/postgresql.conf
