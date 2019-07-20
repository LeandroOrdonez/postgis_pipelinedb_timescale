#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM debian:stable

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get -y update; apt-get -y install gnupg2 wget ca-certificates rpl pwgen

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# ---------------------------------------------------------------------------
# PostGis
# ---------------------------------------------------------------------------

# We add postgis as well to prevent build errors (that we dont see on local builds)
# on docker hub e.g.
# The following packages have unmet dependencies:
RUN apt-get update; apt-get install -y postgresql-client-11 postgresql-common postgresql-11 postgresql-11-postgis-2.5 postgresql-11-pgrouting netcat

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
ADD env-data.sh /env-data.sh
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

# We will run any commands in this when the container starts
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-ssl.sh /
ADD setup-user.sh /
RUN chmod +x /docker-entrypoint.sh

# ---------------------------------------------------------------------------
# PipelineDB
# ---------------------------------------------------------------------------
RUN apt-get -y update && apt-get install -y curl \
    && curl -s http://download.pipelinedb.com/apt.sh | bash \
    && apt-get -y install pipelinedb-postgresql-11 && apt-get purge -y --auto-remove curl

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
COPY create-pipelinedb.sql /docker-entrypoint-initdb.d/
COPY configure.sh /docker-entrypoint-initdb.d/
#RUN chmod 0755 /docker-entrypoint-initdb.d/configure.sh

# ---------------------------------------------------------------------------
# Timescale
# ---------------------------------------------------------------------------

RUN sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list"
RUN wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add -
RUN apt-get update

# Now install appropriate package for PG version
RUN apt-get install -y timescaledb-postgresql-11

# Open port 5432 so linked containers can see them
EXPOSE 5432

RUN timescaledb-tune --yes

#RUN service postgresql restart

ENTRYPOINT /docker-entrypoint.sh