===============


# はじめに

apiインタフェイスは https://github.com/ntplab/mbaas-chat/wiki WIKIをご参照ください

## 概要

```
chat機能は、フロントインタフェイスにcrow(full template http engine)を利用し
軽量・高速・シンプルとした

chatが利用するデータは、フロントsqlite3を利用する
インタフェイス実装とすることで、筐体外部DBも利用可能とした

```

# 動作環境

```
xCode 7.3
osx EI Capitan 10.11.3
```

# サーバコンパイルリンク

```
c++11
boost
sqlite3
```

# linux

```
mkdir ./build
cd ./build
cmake ..
make
make install
```

# 謝辞

```
サンプルUIは、sendbird提供のiosサンプルソースを
参考にして書かせていただきました
```
