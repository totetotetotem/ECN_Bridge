# ECN Forwarder
ケーブルのように動作する(MACアドレスを書き換えない)L2フォワーダです。  
APIを通じた輻輳状況の設定、情報の取得が可能です。  
なお使用にはNICのプロミスキャスモードを有効にする必要があります。  
またForwarderはDPDKの管理するNICの0番と1番を自動で使用します。  

```
usage: sudo ./ecn_fwd -c 0x3
```

cはコアマスクの値です。基本0x3を指定してください。  
また他のDPDKに関するEALコマンドラインオプションも指定可能です。

ECNフォワーダ用のオプションは

* -q: 論理コアあたりのポート数
* -T: パケットの通過情報を出力する間隔(単位 秒)


指定する際は

```
sudo ./ecn_fwd -c 0x3 -- -q 1
```

のように--で区切ることでEALに対するオプションとECNフォワーダへのオプションを区別します。

## API
デフォルトで8080番ポートで待ち受けます。  

### GET /pkt\_stat
パケットの通過情報を取得するAPI  
* pkt0to1:  NIC0->NIC1
* pkt1to0:  NIC1->NIC0

レスポンス例:

```
{"pkt1to0":319,"pkt0to1":786}
```


### GET /conf
輻輳状態設定を取得するAPI  

レスポンス例:

```
{"congestion_10": "false","congestion_01": "true"}
```

### POST /set\_conf
輻輳状態を設定するAPI(/confへのPOSTでは無いのは使用ライブラリの都合)  
設定可能項目は

* congestion_01 (bool)
* congestion_10 (bool)


リクエスト例:

```
{"congestion_01":"true", "congestion_10":"true"}
```

curl:

```
curl -X POST \
  http://${ECN_FORWARDER_IP}:8080/set_conf \
  -H 'content-type: application/json' \
  -d '{"congestion_01":"true", "congestion_10":"true"}'
```

レスポンス例:

```
{"congestion_10": "true","congestion_01": "true","status": "OK"}
```

## build
makeでビルドできます  

### Dependencies
Ubuntu:
```
apt install libpcap-dev libdpdk-dev libboost-dev libboost-all-dev
```

## NOTE
3条項BSDライセンスのDPDK L2FWDプログラムを元に作成しています。
表示すべきBSDライセンス事項や著作権表示等はmain.cpp中に含めております。
