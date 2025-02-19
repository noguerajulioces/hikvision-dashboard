@echo off
cd C:\multicarnes

echo Preparando la base de datos...
rails db:prepare

echo Migrando la base de datos...
rails db:migrate

echo Precompilando los assets...
rails assets:precompile

echo Iniciando el servidor...
start cmd /k "rails server"

timeout /t 5

echo Abriendo el navegador...
start http://localhost:3000

echo Proceso completado.
pause
