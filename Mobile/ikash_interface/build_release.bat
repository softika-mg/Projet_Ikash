@echo off
TITLE Flutter Release Build Automator
echo ========================================
echo   AUTOMATISATION DU BUILD APK (RELEASE)
echo ========================================

set DEBUG_INFO_DIR=build\app\outputs\symbols

echo [1/4] Nettoyage du projet...
call flutter clean

echo [2/4] Recuperation des dependances...
call flutter pub get
if %errorlevel% neq 0 goto error

echo [3/4] Lancement du build APK...
call flutter build apk --release --obfuscate --split-debug-info=%DEBUG_INFO_DIR% --split-per-abi
if %errorlevel% neq 0 goto error

echo [4/4] Ouverture du dossier...
start build\app\outputs\flutter-apk\
echo ========================================
echo   BUILD TERMINE AVEC SUCCES !
echo ========================================
pause
exit

:error
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo   ERREUR DETECTEE - ARRET DU PROCESSUS
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause