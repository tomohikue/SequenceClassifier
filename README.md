# SequenceClassifier
Microsoft Cognitive Toolkitを使った自然言語分類器


## How To Use

1. Microsoft Cognitive Toolkitをインストール

公式サイトからインストールしてください

 - 公式サイト

https://docs.microsoft.com/en-us/cognitive-toolkit/Setup-CNTK-on-your-machine

 - 利用している言語

 Brain Script ※そのため、OSはWindowsのみです。
 - 動作を確認しているバージョン・・・

2.0 ～ 2.3

2. Power Shellの実行

 - Training処理

".\SequenceClassifier\SequenceClassifier\Scripts\Train.ps1"

データモデルが作成され、".\SequenceClassifier\SequenceClassifier\Model"フォルダに出力されます。

 - Test処理

".\SequenceClassifier\SequenceClassifier\Scripts\Test.ps1"

