@echo off
cls
TITLE iKash Mobile - DevOps Script
echo ---------------------------------------------------
echo ✨ iKash Mobile - Automating the magic ✨
echo ---------------------------------------------------

:: 1. NETTOYAGE
echo 🧹 1/5 Nettoyage des caches...
call flutter clean > nul
if %errorlevel% neq 0 goto :error

:: 2. PACKAGES
echo 📦 2/5 Recuperation des packages (pub get)...
call flutter pub get
if %errorlevel% neq 0 goto :error

:: 3. FORMATTAGE DU CODE
echo 🎨 3/5 Formatage du code (Dart Format)...
call dart format .
if %errorlevel% neq 0 echo ⚠️ Attention: Certains fichiers n'ont pas pu etre formats.

:: 4. GÉNÉRATION DRIFT
echo 🏗️  4/5 Generation de l'ORM Drift (build_runner)...
echo (Cette etape est cruciale)
call dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 goto :error

:: 5. LANCEMENT
echo 🚀 5/5 Lancement sur ton Oppo...
echo ---------------------------------------------------
call flutter run
if %errorlevel% neq 0 goto :error

echo.
echo ✅ Tout est operationnel !


:error
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo ❌ ERREUR DETECTEE ! Le processus s'est arrete.
echo Verifie ton code ou tes dependances avant de relancer.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause

