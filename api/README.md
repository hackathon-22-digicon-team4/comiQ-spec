# API

## TL;DR

- [api.proto](./api.proto) が、API の定義
- [model.proto](./model.proto) が、モデルの定義

## 認証

1. Client => Server: ユーザーID・パスワード(Login endpoint)
2. Client <= Server: セッショントークン(`Set-Cookie`ヘッダー)
3. 以降クッキーにセッショントークンをつけて通信。

(将来的にはCognitoを使ってsecureにしたい)

## NOTE

- proto で記述しているが、gRPC は使わず、RESTful に実装

## Deps

- protoc: v3.15.0
- [googleapis](https://github.com/googleapis/googleapis): d4a2367

## Styles

- https://github.com/yoheimuta/protolint
- clang-format 

```
{
  BasedOnStyle: Google,
  AlignConsecutiveAssignments: true,
  AlignConsecutiveDeclarations: true,
  ColumnLimit: 0
}
```
