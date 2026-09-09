#!/bin/bash

set -e

shutdown_instance() {
    EXIT_CODE=$?

    echo ""
    echo "================================="
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Bootstrap finalizado com sucesso"
    else
        echo "Bootstrap finalizado com erro. Exit code: $EXIT_CODE"
    fi
    echo "Encerrando a instância..."
    echo "================================="

    shutdown -h now
}

trap shutdown_instance EXIT


yum update -y

yum install -y postgresql16

export PGPASSWORD="${password}"

echo "================================="
echo "Iniciando bootstrap PostgreSQL"
echo "================================="


echo ""
echo "Banco AUTH"

cat > /tmp/auth.sql <<'EOF'
${auth_sql}
EOF

psql \
  -h ${postgres_databases.auth.endpoint} \
  -p ${postgres_databases.auth.port} \
  -U ${username} \
  -d ${postgres_databases.auth.database} \
  -f /tmp/auth.sql


echo "Tabelas criadas no AUTH:"
psql \
  -h ${postgres_databases.auth.endpoint} \
  -p ${postgres_databases.auth.port} \
  -U ${username} \
  -d ${postgres_databases.auth.database} \
  -c "\dt"


echo ""
echo "Banco FLAG"

cat > /tmp/flag.sql <<'EOF'
${flag_sql}
EOF

psql \
  -h ${postgres_databases.flag.endpoint} \
  -p ${postgres_databases.flag.port} \
  -U ${username} \
  -d ${postgres_databases.flag.database} \
  -f /tmp/flag.sql


echo "Tabelas criadas no FLAG:"
psql \
  -h ${postgres_databases.flag.endpoint} \
  -p ${postgres_databases.flag.port} \
  -U ${username} \
  -d ${postgres_databases.flag.database} \
  -c "\dt"


echo ""
echo "Banco TARGETING"

cat > /tmp/targeting.sql <<'EOF'
${targeting_sql}
EOF

psql \
  -h ${postgres_databases.targeting.endpoint} \
  -p ${postgres_databases.targeting.port} \
  -U ${username} \
  -d ${postgres_databases.targeting.database} \
  -f /tmp/targeting.sql


echo "Tabelas criadas no TARGETING:"
psql \
  -h ${postgres_databases.targeting.endpoint} \
  -p ${postgres_databases.targeting.port} \
  -U ${username} \
  -d ${postgres_databases.targeting.database} \
  -c "\dt"


echo ""
echo "================================="
echo "Bootstrap finalizado com sucesso"
echo "================================="