@echo off
chcp 65001 > nul
title OCRツール 起動

echo =========================================
echo  OCRツール ローカルサーバー起動スクリプト
echo =========================================
echo.

:: ポート番号
set PORT=8765

:: Python 3 チェック
where python > nul 2>&1
if %ERRORLEVEL% == 0 (
    python -c "import sys; exit(0 if sys.version_info[0]==3 else 1)" > nul 2>&1
    if %ERRORLEVEL% == 0 (
        echo [OK] Python 3 が見つかりました
        echo サーバーを起動中... http://localhost:%PORT%/ocrtool.html
        echo.
        echo ブラウザが自動で開きます。サーバーを停止するには Ctrl+C を押してください。
        start "" "http://localhost:%PORT%/ocrtool.html"
        python -m http.server %PORT%
        goto :end
    )
)

:: python3 コマンドチェック
where python3 > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo [OK] Python 3 が見つかりました
    echo サーバーを起動中... http://localhost:%PORT%/ocrtool.html
    echo.
    echo ブラウザが自動で開きます。サーバーを停止するには Ctrl+C を押してください。
    start "" "http://localhost:%PORT%/ocrtool.html"
    python3 -m http.server %PORT%
    goto :end
)

:: Node.js チェック
where node > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo [OK] Node.js が見つかりました
    echo サーバーを起動中... http://localhost:%PORT%/ocrtool.html
    echo.
    echo ブラウザが自動で開きます。サーバーを停止するには Ctrl+C を押してください。
    start "" "http://localhost:%PORT%/ocrtool.html"
    npx --yes serve -p %PORT% -s .
    goto :end
)

:: どちらも見つからない場合
echo [エラー] Python または Node.js がインストールされていません。
echo.
echo 以下のいずれかをインストールしてください:
echo.
echo   Python  : https://www.python.org/downloads/
echo             インストール時に「Add Python to PATH」にチェックを入れてください
echo.
echo   Node.js : https://nodejs.org/
echo.
echo インストール後、このファイルをダブルクリックして再起動してください。
echo.
pause
:end
