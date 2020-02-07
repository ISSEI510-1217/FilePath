#!/bin/zsh

#ユーザーに対する標準入力の内容
echo -n "検索する単語を入力してください(3つまで入力可能) : "
read str1 str2 str3
echo -n "該当するパスの詳細を表示しますか？(y/n): "
read str4
echo -n "探索するホームディレクトリに存在するディレクトリ名を入力してください: "
read str5

#標準入力した内容をそれぞれ変数に代入
search_word1=$str1
search_word2=$str2
search_word3=$str3
file_type=$str4
directory_name=$str5

#配列の定義
files=()
directorys=()
stack_array=()
str_array=()
#標準入力で入力された文字列を配列str_arrayに格納
str_array+=($search_word1)
str_array+=($search_word2)
str_array+=($search_word3)

num=0

#下記の関数popと関数pushで配列stack_arrayをスタック型として動作
function pop () {
  p=$stack_array[$num]
  num=$(( num - 1 ))
}
function push () {
  num=$((num + 1))
  stack_array[$num]=$1
}

#関数insert_arrayでは, 関数popと関数pushを利用してパスを配列に格納している.
#パスの末端がファイルかディレクトリかで格納していく配列が異なっている
#ファイルならば, 配列files　ディレクトリならば, 配列directorysに格納されていく
function insert_array () {
  pop
  if [ -n "$(ls $p)" ]; then
    for filepath in $p/*; do 
      if [ -f $filepath ] ; then
        files+=("$filepath")
      elif [ -d $filepath ] ; then
        directorys+=("$filepath")
        push $filepath
      fi
    done
  fi
}

#関数insert_arrayで取得した全てのパスにおいて, 標準入力で得た単語の数の分だけgrepコマンドをかけて出力している
#"y"と"n"のcase文では, 標準入力でパスの詳細設定を表示するかどうかの有無で出力内容を変化させている
#"y"ならば, パスの詳細を表示　"n"ならば, パスの詳細は表示せずパスだけの出力となる
function grep_number () {
  case "${#str_array[@]}" in 
  "1" )     case "$file_type" in
              "y" ) file $i | grep -e $search_word1 ;;
              "n" ) echo $i | grep -e $search_word1 ;;
            esac;;
  "2" )     case "$file_type" in
              "y" ) file $i | grep -e $search_word1 | grep -e $search_word2 ;;
              "n" ) echo $i | grep -e $search_word1 | grep -e $search_word2 ;;
            esac;;
  "3" )     case "$file_type" in
              "y" ) file $i | grep -e $search_word1 | grep -e $search_word2 | grep -e $search_word3;;
              "n" ) echo $i | grep -e $search_word1 | grep -e $search_word2 | grep -e $search_word3;;
            esac;;
  esac
}

#関数search_pathでは, 関数insert_arrayでそれぞれの配列に入っている全てパスを出力
#出力する際には, 関数grep_numberで検索単語にヒットしたものだけを表示する
function search_path () {
  echo "[ファイル一覧]"
  for i in ${files[*]}; do
    grep_number
  done
  echo "[ディレクトリ一覧]"
  for i in ${directorys[*]}; do
    grep_number
  done
}

#実際の実行部
#エラーを検出した場合
case "$search_word1" in
  "" ) echo -e "\033[31m検索する単語が正しく入力されていません。再度実行してください。\033[m"
       exit;;
esac
if [ !! != exit ]; then
  case "$file_type" in 
    ""  ) echo -e "\033[31mファイルの詳細表示設定が正しく入力されていません。再度実行してください。\033[m"
          exit;;
  esac
fi
if [ !! != exit ]; then
  case "$directory_name" in  
    ""  ) echo -e "\033[31m探索するディレクトリ名が正しく入力されていません。再度実行してください。\033[m"
          exit;;
  esac
fi
#再帰的にディレクトリ探索を行うために最初に変数home_pathを引数として関数pushを行う
#この処理はこのファイルを実行した最初の1回しか実行しない
#変数numが0になるまで関数insert_arrayを繰り返す
#最終的に, 検索にヒットしたパスのみを出力する
cd 
cd $str5
home_path=$(pwd)
push $home_path
while [[ $num != 0 ]]
do
insert_array
done
search_path