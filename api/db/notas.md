## COMANDO CLI

\l = lista todos os bancos
\c = USE DATABASE

### Como importar um dump em postgres

docker exec -i postgres-container /bin/bash -c "PGPASSWORD=admin psql --username postgres dbsistema_acesso" < api\db\db-acesso.sql