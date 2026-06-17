@echo off
chcp 65001 > nul 2>&1
title OCRツール 起動中...

:: ============================================================
::  このファイルがあるフォルダに移動（重要）
:: ============================================================
cd /d "%~dp0"

echo.
echo  =============================================
echo   OCRツール  ローカルサーバー起動
echo  =============================================
echo.
echo  フォルダ: %~dp0
echo.

:: ocrtool.html の存在確認
if not exist "ocrtool.html" (
    echo  [エラー] ocrtool.html が見つかりません！
    echo.
    echo  start.bat と ocrtool.html を同じフォルダに
    echo  入れてから再実行してください。
    echo.
    echo  現在のフォルダの中身:
    dir /b
    echo.
    pause
    exit /b
)

echo  ocrtool.html ... 検出 OK
echo.

set PORT=8765
set URL=http://localhost:%PORT%/ocrtool.html

:: ---- Python 3 チェック ----
where python > nul 2>&1
if %ERRORLEVEL% == 0 (
    python -c "import sys; exit(0 if sys.version_info[0]==3 else 1)" > nul 2>&1
    if %ERRORLEVEL% == 0 (
        echo  [OK] Python 3 を使用してサーバーを起動します
        echo.
        echo  ブラウザで開く URL : %URL%
        echo  停止するには Ctrl+C を押してください
        echo.
        start "" "%URL%"
        python -m http.server %PORT%
        goto :done
    )
)

:: ---- python3 コマンドチェック ----
where python3 > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  [OK] Python3 を使用してサーバーを起動します
    echo.
    echo  ブラウザで開く URL : %URL%
    echo  停止するには Ctrl+C を押してください
    echo.
    start "" "%URL%"
    python3 -m http.server %PORT%
    goto :done
)

:: ---- Node.js チェック ----
where node > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  [OK] Node.js を使用してサーバーを起動します
    echo.
    echo  ブラウザで開く URL : %URL%
    echo  停止するには Ctrl+C を押してください
    echo.
    start "" "%URL%"
    npx --yes serve -p %PORT% -s .
    goto :done
)

:: ---- 何も見つからなかった場合 ----
echo  ============================================
echo   [エラー] サーバーを起動できませんでした
echo  ============================================
echo.
echo  Python または Node.js をインストールしてください。
echo.
echo  Python (推奨・無料):
echo    https://www.python.org/downloads/
echo    ※ インストール時に「Add Python to PATH」に
echo       チェックを入れてください！
echo.
echo  Node.js (無料):
echo    https://nodejs.org/
echo.
echo  インストール後、このファイルを再実行してください。
echo.

:done
pause
