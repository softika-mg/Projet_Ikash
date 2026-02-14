@echo off
cls
echo ---------------------------------------------------
echo ✨ iKash Mobile - Automating the magic ✨
echo ---------------------------------------------------

echo 🧹 1/4 Nettoyage des caches...
call flutter clean > nul

echo 📦 2/4 Recuperation des packages (pub get)...
call flutter pub get

echo 🏗️  3/4 Generation de l'ORM Drift (build_runner)...
echo (Cette etape peut prendre 30s-1min)
call dart run build_runner build --delete-conflicting-outputs

echo 🚀 4/4 Lancement sur ton Oppo...
echo ---------------------------------------------------
call flutter run
