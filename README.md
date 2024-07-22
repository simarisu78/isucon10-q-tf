# isucon10-q-tf
isucon10の環境を再現するためのTerraform

amiの参照先を変えることで、別の年の問題に変更することも可能

## Usage
1. aws cliを使えるようにしておく
2. locals.tf の設定を自分のものに置き換える
    - 特にgithubのアカウント名（これを自分のアカウント名に変えることで、GitHubにアクセスしているSSHキーでインスタンスにアクセスできるようになる）
    - 複数人の場合は、誰か１人がログインした後、以下のコマンドをログインしたいユーザのホームディレクトリで実行する
```
$ curl https://github.com/<ユーザ名>.keys >> /home/ubuntu/.ssh/authorized_keys
```
3. `terraform plan`で作るリソースが正しいことを確認する
4. `terraform apply`でデプロイする