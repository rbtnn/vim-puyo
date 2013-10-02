
# puyo.vim

これは[Vim Advent Calendar 2012](http://atnd.org/events/33746) : ATND 304日目になります。

![](https://raw.github.com/rbtnn/puyo.vim/master/puyo.png)

Vimでぷよぷよっぽいものを実装してみた。  
わざわざQiitaやブログにまとめるのもあれだったのでGithubのREADMEでVAC記事にしてみました。(gistで投稿している方もいるし...)  
使い方や操作方法は以下のような感じです。  
とりあえず作ってみたシリーズなので、Vimがおかしくなってもよい環境で試してみてください。  

## 始め方

        " 1000以上推奨。
        :set maxfuncdepth=1000
        " 数値が低いほど難しい.100～500あたりを推奨。
        :set updatetime=100
        " ゲームを始める
        :Puyo

## 操作方法

* h,j,lで移動  
* zで左回転  
* xで右回転  
* qで終了  


