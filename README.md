# uni-template

## Project setup
clone以后编辑.env.local
```
VUE_APP_API_URL=
VUE_APP_IMG_URL=
```
依懒环境的选项要充分利用.env系列文件去管理
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
## git用法
1. 提交dev分支用批处理commit_push_dev.bat
2. merge到master分支用批处理merge_push_master
3. 先提交dev要支再merge到master分支
4. push_upload.bat同时提交dev和master分支，是上两个批处理的合并执行
