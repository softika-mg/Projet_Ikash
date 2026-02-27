@echo off
TITLE Flutter Release Build Automator (Ikash)
echo ========================================
echo   AUTOMATISATION DU BUILD APK (RELEASE)
echo ========================================

set DEBUG_INFO_DIR=build\app\outputs\symbols

echo [1/5] Nettoyage du projet...
call flutter clean

echo [2/5] Recuperation des dependances...
call flutter pub get
if %errorlevel% neq 0 goto error

echo [3/5] Generation du code SQL (Drift)...
:: On utilise --delete-conflicting-outputs pour eviter les erreurs de generation
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 goto error

echo [4/5] Lancement du build APK...
:: L'obfuscation protege ton code, tres important pour une app de transactions
call flutter build apk --release --obfuscate --split-debug-info=%DEBUG_INFO_DIR% --split-per-abi
if %errorlevel% neq 0 goto error

echo [5/5] Ouverture du dossier...
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
