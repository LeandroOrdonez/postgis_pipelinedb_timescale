#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM gitlab.ilabt.imec.be:4567/lordezan/postgis_pipelinedb:latest

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get -y update; apt-get -y install gnupg2 wget ca-certificates rpl pwgen

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# ---------------------------------------------------------------------------
# Timescale
# ---------------------------------------------------------------------------

RUN sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list"
RUN wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
RUN apt-get update

# Now install appropriate package for PG version
RUN apt-get install -y timescaledb-postgresql-11

# Open port 5432 so linked containers can see them
EXPOSE 5432

RUN timescaledb-tune

RUN service postgresql restart