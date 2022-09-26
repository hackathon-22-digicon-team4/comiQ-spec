# frontend module

* フロントエンドで必要となるリソースを定義
  * s3
  * cloudfront
  * route53(for routing of cloudfront)
* cloudfrontで利用するSSL証明書は`us-east-1`のregionで作る必要があるため、ここでは手動で作成
