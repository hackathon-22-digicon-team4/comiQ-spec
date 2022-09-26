# CD module

* github actionsによる自動デプロイを行うためのモジュール
  * masterにマージされたらS3にフロントエンドのbuildファイルが自動アップロードされる
  * AWSへの認証としてはOpenID Connect(OIDC)を利用
    * これにより、githubにsecret情報を置かなくてよくなる

## OIDCの仕組み

![](https://docs.github.com/assets/cb-63262/images/help/images/oidc-architecture.png)

1. AWSにアクセスするリソースやIAM Roleなどがこれにあたる。
2. GitHub Actionsのワークフローが実行されるたびに、GitHub Actionsの環境変数から、OIDCプロバイダーがIDトークンを自動生成する。
3. GitHubのOIDCプロバイダーが自動生成したトークンを基に、AWSリソースへのアクセスをリクエストする。
4. 3のリクエストが問題ない場合、短期間だけ利用できるクラウドアクセストークンをGithub側に返すことで、Github ActionsからAWSリソースへアクセスすることが出来る。

