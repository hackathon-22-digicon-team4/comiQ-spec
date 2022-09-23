# init

* 初めにtfstate管理用のS3バケットをinit_terraform_bucket.shを用いて作成する
  * tfstate管理用のS3はterraformで管理しない方がよいため

```bash
$ bash ./init_terraform_bucket.sh digicon-team14-tfstate
```