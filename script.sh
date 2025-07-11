#!/bin/bash

#Script escrito para rodar no Ubuntu Server

# CONFIGURAÇÃO
BACKEND_REPO="https://github.com/devti-star/RH_SO-backend.git"
FRONTEND_REPO="https://github.com/devti-star/RH_SO-frontend.git"
LOG_FILE_BACK="./log.backend.log"
LOG_FILE_FRONT="./log.frontend.log"
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"

# --- Atualiza sistema e instala pacotes essenciais ---
echo "Atualizando e instalando dependências do sistema..."
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    git \
    curl \
    build-essential \
    ca-certificates \
    postgresql \
    postgresql-contrib \
    libpq-dev \
    gnupg \
    lsb-release

# --- Instala Node.js LTS + npm ---
if ! command -v node &> /dev/null; then
  echo "Instalando Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
fi

echo "Node: $(node -v), NPM: $(npm -v)"

# --- Clona e prepara o backend ---
echo "Clonando backend"
git clone "$BACKEND_REPO" "$BACKEND_DIR"
cd "$BACKEND_DIR" || exit

echo "Instalando dependências do backend..."
npm install

echo "DB_HOST = 172.18.2.83
DB_USERNAME = dirti
DB_PASSWORD = \"pmtl#2025@ti\"
DB_PORT = 5433
DB_DATABASE = rh_sodb" >> .env

nohup npm run start:dev > "../$LOG_FILE_BACK" 2>&1 &

cd ..

# --- Clona e prepara o frontend ---
echo "Clonando frontend Vite..."
git clone "$FRONTEND_REPO" "$FRONTEND_DIR"
cd "$FRONTEND_DIR" || exit

echo "Instalando dependências do frontend..."
npm install

echo "VITE_BASE_URL=http://localhost:3000" >> .env

npm run dev > "../$LOG_FILE_FRONT" 2>&1 &

cd ..

echo "Ambiente configurado com sucesso!"
echo "Frontend: http://localhost:5173"
echo "Backend (Nest): http://localhost:3000"

