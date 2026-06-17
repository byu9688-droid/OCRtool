#!/bin/bash
# OCRツール ローカルサーバー起動スクリプト (Mac / Linux)

PORT=8765
URL="http://localhost:$PORT/ocrtool.html"

echo "========================================="
echo " OCRツール ローカルサーバー起動"
echo "========================================="
echo ""

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

open_browser() {
    if command -v open &> /dev/null; then
        open "$URL"          # macOS
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$URL"      # Linux (X11)
    elif command -v gnome-open &> /dev/null; then
        gnome-open "$URL"    # GNOME
    else
        echo "ブラウザを手動で開いてください: $URL"
    fi
}

# Python 3 チェック
if command -v python3 &> /dev/null; then
    echo "[OK] Python 3 が見つかりました"
    echo "サーバーを起動中... $URL"
    echo ""
    echo "停止するには Ctrl+C を押してください"
    sleep 1 && open_browser &
    python3 -m http.server $PORT
    exit 0
fi

# python コマンドが Python 3 の場合
if command -v python &> /dev/null; then
    PY_VERSION=$(python -c "import sys; print(sys.version_info[0])" 2>/dev/null)
    if [ "$PY_VERSION" = "3" ]; then
        echo "[OK] Python 3 が見つかりました"
        echo "サーバーを起動中... $URL"
        echo ""
        echo "停止するには Ctrl+C を押してください"
        sleep 1 && open_browser &
        python -m http.server $PORT
        exit 0
    fi
fi

# Node.js チェック
if command -v node &> /dev/null; then
    echo "[OK] Node.js が見つかりました"
    echo "サーバーを起動中... $URL"
    echo ""
    echo "停止するには Ctrl+C を押してください"
    sleep 1 && open_browser &
    npx --yes serve -p $PORT -s .
    exit 0
fi

# Ruby チェック (macOS に標準搭載)
if command -v ruby &> /dev/null; then
    echo "[OK] Ruby が見つかりました"
    echo "サーバーを起動中... $URL"
    echo ""
    echo "停止するには Ctrl+C を押してください"
    sleep 1 && open_browser &
    ruby -run -e httpd . -p $PORT
    exit 0
fi

echo "[エラー] サーバーを起動できるランタイムが見つかりません。"
echo ""
echo "以下のいずれかをインストールしてください:"
echo "  Python 3 : https://www.python.org/"
echo "  Node.js  : https://nodejs.org/"
echo ""
echo "または手動でHTTPサーバーを起動してください:"
echo "  python3 -m http.server $PORT"
echo "  npx serve -p $PORT"
