sudo apt-get update -qq
sudo apt-get install -y -qq postgresql postgresql-contrib
sudo -u postgres createuser -s vagrant
sudo -u vagrant createdb book
sudo -u vagrant psql book -c "CREATE EXTENSION tablefunc" 
sudo -u vagrant psql book -c "CREATE EXTENSION fuzzystrmatch" 
sudo -u vagrant psql book -c "CREATE EXTENSION pg_trgm" 
sudo -u vagrant psql book -c "CREATE EXTENSION cube" 
sudo -u vagrant psql book -c "CREATE EXTENSION dict_xsyn" 
