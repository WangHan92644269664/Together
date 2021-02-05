#!/bin/bash
#检查是否已存在站点
function exist_site()
{
  echo $(ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "cd $SITE_CONF_PATH && [ -f ${PROJ_NAME}.conf ] && echo true || echo false")
}
function enable_site()
{
  set +e
  ssh root@$SERVER "cd $DOCKER_PATH/data/web/nginx/sites-enabled && ln -sf ../sites-available/${PROJ_NAME}.conf ${PROJ_NAME}.conf"
  if [[ $? != 0 ]]; then
    set -e
    echo "无法开启站点,请执行FORCE_SITE"
    exit 9
  else
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
    cd $DOCKER_PATH \
    && docker-compose exec -T web nginx -s reload"
    if [[ $? != 0 ]]; then
      set -e
      disable_site
      echo "开启站点失败,已禁用该站点"
      exit 9
    fi
  fi
  set -e
}
function disable_site()
{
  set +e
  ssh root@$SERVER "rm -f $DOCKER_PATH/data/web/nginx/sites-enabled/${PROJ_NAME}.conf"
  if [[ $? == 0 ]]; then
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $DOCKER_PATH \
      && docker-compose exec -T web nginx -s reload"
  else
    echo "站点没有开启，所以不需要执行什么"
  fi
  set -e
}
#检查是否存在cordova项目
function exist_cordova()
{
  echo [ -f cordova_build/config.xml ] && echo true || echo false
}
#申请证书，若证书已存在则跳过
function request_cer()
{
  set +e
  if [[ $(is_exist_cer) == "false" ]]; then
    set +e
    if [[ -z "$DNS_TYPE" ]]; then
      ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $DOCKER_PATH && docker-compose exec -T acme.sh acme.sh \
      --issue  \
      --debug ${ACME_OPTS} \
      -d $DOMAIN -w /var/www/${PROJ_NAME} -d $UPDATE_DOMAIN -w /var/www/${PROJ_NAME}"
    else
      ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $DOCKER_PATH && docker-compose exec -T acme.sh acme.sh \
      --issue  \
      --dns $DNS_TYPE \
      --debug ${ACME_OPTS} \
      -d $DOMAIN -d $UPDATE_DOMAIN"
    fi
    if [[ $? != 0 ]]; then
      set -e
      echo "证书申请失败，请执行force_site test任务以修复问题或检查域名解析的IP与\$SERVER是否一致"
      disable_site
      exit 3
    fi
    set -e
  else
    echo "证书已存在，跳过证书申请"
  fi
}
#检查是否存在证书
function is_exist_cer()
{
  ret_exist_cer=`ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "[[ -f $DOCKER_PATH/data/acme.sh/${DOMAIN}/fullchain.cer ]] && echo true || echo false"`
  if [[ "$ret_exist_cer" == "true" ]]; then
    echo true
    return 0
  fi;
  echo false
  return 0
}
#删除旧证书
function remove_cer()
{
  cer_name=`ssh -o StrictHostKeyChecking=no root@$SERVER "grep -o -P -m 1 '(?<=server\_name\s)[A-Za-z0-9\._\-]+' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"`
  if [[ -n "$cer_name" ]]; then
    set +e
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $DOCKER_PATH && docker-compose exec -T acme.sh \
      --remove -d $cer_name"
    set -e
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "[[ -d $DOCKER_PATH/data/acme.sh/$cer_name ]] && rm -rf $DOCKER_PATH/data/acme.sh/$cer_name || echo 删除证书时证书已不存在"
  else
    echo "移除旧证书时证书不存在"
  fi
}
#移除当前项目证书
function remove_proj_cer()
{
  cer_name=$DOMAIN
  if [[ -n "$cer_name" ]]; then
    set +e
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $DOCKER_PATH && docker-compose exec -T acme.sh acme.sh --remove -d $cer_name"
    set -e
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "[[ -d $DOCKER_PATH/data/acme.sh/$cer_name ]] && rm -rf $DOCKER_PATH/data/acme.sh/$cer_name || echo 删除证书时证书已不存在"
  else
    echo "移除当前证书时证书不存在"
  fi
}
#检查是否需要申请证书，如部署新站点，修改域名，开启https
function is_change_cer()
{
  if [[ "$HTTPS_DOMAIN" == "false" ]] && [[ -z `ssh root@$SERVER "grep -E '#\s*listen\s+443' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    echo true
    return 0
  fi
  if [[ "$HTTPS_DOMAIN" == "true" ]] && [[ "$(is_change_domain)" == "true" ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#检查域名是否改变
function is_change_domain()
{
  is_exist=`ssh root@$SERVER "grep -E '^\s*server_name\s+${DOMAIN}' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"`
  if [[ -z $is_exist ]]; then
    echo true
    return 0
  fi
  is_exist=`ssh root@$SERVER "grep -E '^\s*server_name\s+${UPDATE_DOMAIN}' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"`
  if [[ -z $is_exist ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#检查是否需要开启https
function is_enable_tls()
{
  if [[ "$HTTPS_DOMAIN" == "true" ]] && [[ -n `ssh root@$SERVER "grep -E '#\s*listen\s+443' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    echo true
    return 0
  fi
  if [[ "$HTTPS_DOMAIN" == "true" ]] && [[ "$(is_change_domain)" == "true" ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#检查是否需要关闭https
function is_disable_tls()
{
  if [[ "$HTTPS_DOMAIN" == "false" ]] && [[ -z `ssh root@$SERVER "grep -E '#\s*listen\s+443' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#检查是否需要开启强制https跳转
function is_enable_hsts()
{
  #hsts
  if [ "$HTTPS_HSTS" == "true" ] && [[ -n `ssh root@$SERVER "grep -E '#\s*return\s+301' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#检查是否需要关闭https跳转
function is_disable_hsts()
{
  if [[ "$HTTPS_HSTS" == "false" ]] && [[ -z `ssh root@$SERVER "grep -E '#\s*return\s+301' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    echo true
    return 0
  fi
  echo false
  return 0
}
#开启https
function enable_hsts()
{
  if [[ "$(is_enable_hsts)" == "true" ]]; then
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
      cd $SITE_CONF_PATH \
      && sed -i '/return 301/s/\#//' ${PROJ_NAME}.conf \
      && sed -i '/Strict-Transport-Security/s/\#//' ${PROJ_NAME}.conf \
      && cd $DOCKER_PATH \
      && docker-compose exec -T web nginx -s reload"
  fi
}
#禁用https
function disable_hsts()
{
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
    cd $SITE_CONF_PATH \
    && sed -i '/return 301/s/^/\#&/' ${PROJ_NAME}.conf \
    && sed -i '/Strict-Transport-Security/s/^/\#&/' ${PROJ_NAME}.conf \
    && cd $DOCKER_PATH \
    && docker-compose exec -T web nginx -s reload"
}
#执行创建新站点的一系列操作，包括创建nginx配置文件，申请证书，重启nginx
function new_site()
{
  set +e
  ssh root@$SERVER mkdir -p $WWW_PATH/${PROJ_NAME}
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
  cd $SITE_CONF_PATH \
  && sed 's/mobile-template/${PROJ_NAME}/g'  mobile-template.conf>${PROJ_NAME}.conf \
  && sed -i 's/^\s*server_name\s\+.*www-domain$/\tserver_name $DOMAIN;\#www-domain/' ${PROJ_NAME}.conf \
  && sed -i 's/^\s*server_name\s\+.*update-domain$/\tserver_name $UPDATE_DOMAIN;\#update-domain/' ${PROJ_NAME}.conf \
  && cat ${PROJ_NAME}.conf \
  && cd ../sites-enabled \
  && ln -sf ../sites-available/${PROJ_NAME}.conf ${PROJ_NAME}.conf \
  && cd $DOCKER_PATH \
  && docker-compose exec -T web nginx -s reload"
  if [[ $? != 0 ]]; then
    set -e
    echo "创建站点失败，请执行force_site任务以修复问题或检查域名解析的IP与\$SERVER是否一致"
    disable_site
    exit 3
  fi
  set -e
  sleep 5
  dns_check
  if [[ "$(is_enable_tls)" == "true" ]]; then
    enable_tls
  fi
  if [[ "$(is_enable_hsts)" == "true" ]]; then
    enable_hsts
  fi
}
#移除站点，包括删除nginx配置，删除证书
function remove_site()
{
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "[[ -f $SITE_CONF_PATH/../sites-enabled/${PROJ_NAME}.conf ]] && rm $SITE_CONF_PATH/../sites-enabled/${PROJ_NAME}.conf || echo no exist"
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "[[ -f $SITE_CONF_PATH/${PROJ_NAME}.conf ]] && rm $SITE_CONF_PATH/${PROJ_NAME}.conf || echo no exist"
  remove_proj_cer
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER "cd $DOCKER_PATH && docker-compose exec -T web nginx -s reload"
}
#修改站点配置，与new_site相对应，主要是域名和证书,hsts的修改
function change_site()
{
  if [[ "$(is_disable_hsts)" == "true" ]]; then
    disable_hsts
  fi
  ret_is_change_cer=`is_change_cer`
  ret_is_disable_tls=`is_disable_tls`
  if [[ -n `ssh root@$SERVER "grep -E '^\s*listen\s+443' ${SITE_CONF_PATH}/${PROJ_NAME}.conf"` ]]; then
    if [[ "$ret_is_change_cer" == "true" ]] || [[ "$ret_is_disable_tls" == "true" ]]; then
      disable_tls
    fi
  fi
  #修改域名
  if [[ "$(is_change_domain)" == "true" ]]; then
    ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
    cd $SITE_CONF_PATH \
    && sed -i 's/^\s*server_name\s\+.*www-domain$/\tserver_name $DOMAIN;\#www-domain/' ${PROJ_NAME}.conf \
    && sed -i 's/^\s*server_name\s\+.*update-domain$/\tserver_name $UPDATE_DOMAIN;\#update-domain/' ${PROJ_NAME}.conf \
    && cat ${PROJ_NAME}.conf"
  fi
  enable_site
  sleep 5
  dns_check
  if [[ "$(is_enable_tls)" == "true" ]]; then
    enable_tls
  fi
  if [[ "$(is_enable_hsts)" == "true" ]]; then
    enable_hsts
  fi
}
function dns_check()
{
  set +e
  ssh root@$SERVER "mkdir -p $WWW_PATH/${PROJ_NAME}/.well-known && echo -n ok > $WWW_PATH/${PROJ_NAME}/.well-known/dns-test.txt"
  status=$(curl -Ss http://$DOMAIN/.well-known/dns-test.txt 2>&1 || echo "域名无法访问")
  ssh root@$SERVER "rm $WWW_PATH/${PROJ_NAME}/.well-known/dns-test.txt"
  if [[ $status != "ok" ]]; then
    set -e
    echo "dns-test.txt返回结果为:$status,不是ok,请检查是否是有效的域名并且dns绑定正确,证书测试请用FORCE_SITE test,问题排除后执行FORCE_SITE true"
    disable_site
    exit 8
  fi
    ssh root@$SERVER "mkdir -p $WWW_PATH/${PROJ_NAME}/.well-known && echo -n ok > $WWW_PATH/${PROJ_NAME}/.well-known/dns-update-test.txt"
    status=$(curl -Ss http://$UPDATE_DOMAIN/.well-known/dns-update-test.txt 2>&1 || echo "域名无法访问")
    ssh root@$SERVER "rm $WWW_PATH/${PROJ_NAME}/.well-known/dns-update-test.txt"
    if [[ $status != "ok" ]]; then
      set -e
      echo "dns-test.txt返回结果为:$status,不是ok,请检查是否是有效的域名并且dns绑定正确,证书测试请用FORCE_SITE test,问题排除后执行FORCE_SITE true"
      disable_site
      exit 8
    fi
    set -e
}
#执行开启https的一系列操作
function enable_tls()
{
  request_cer
  set +e
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
    cd $SITE_CONF_PATH \
    && sed -i '/listen\s\+443/s/\#//' ${PROJ_NAME}.conf \
    && sed -i '/ssl\.conf/s/\#//' ${PROJ_NAME}.conf \
    && sed -i '/ssl_early_data/s/\#//' ${PROJ_NAME}.conf \
    && sed -i '/ssl_certificate\s\+/s/.*/\tssl_certificate \/opt\/certs\/${DOMAIN}\/fullchain.cer;/' ${PROJ_NAME}.conf \
    && sed -i '/ssl_certificate_key\s\+./s/.*/\tssl_certificate_key \/opt\/certs\/${DOMAIN}\/${DOMAIN}.key;/' ${PROJ_NAME}.conf \
    && docker-compose exec -T web nginx -s reload"
  if [[ $? != 0 ]]; then
    set -e
    echo "开启tls失败，请执行force_site任务以修复问题或检查域名解析的IP与\$SERVER是否一致"
    disable_site
    exit 7
  fi
  set -e
}
#禁用https
function disable_tls()
{
  ssh -o BatchMode=true -o StrictHostKeyChecking=no root@$SERVER " \
  cd $SITE_CONF_PATH \
  && sed -i '/listen\s\+443/s/^/\#&/' ${PROJ_NAME}.conf \
  && sed -i '/ssl\.conf/s/^/\#&/' ${PROJ_NAME}.conf \
  && sed -i '/ssl_early_data/s/^/\#&/' ${PROJ_NAME}.conf \
  && sed -i '/^\s*ssl_certificate/s/^/\#&/' ${PROJ_NAME}.conf \
  && sed -i '/^\s*ssl_certificate_key/s/^/\#&/' ${PROJ_NAME}.conf \
  && cd $DOCKER_PATH \
  && docker-compose exec -T web nginx -s reload"
  remove_cer
}
#站点部署，如果站点不存在新建站点，如果已存在则修改站点
function site()
{
  if [[ "$(exist_site)" == "true" ]]; then
    change_site
  else
    new_site
  fi
}
#移除站点的所有数据并重新创建点点
function force_site()
{
  remove_site
  new_site
}
function exist_splash()
{
  if [[ -f ${CI_PROJECT_DIR}/env/cordova/splash.png ]]; then
    echo "true"
  else
    echo "false"
  fi
}
#创建cordova项目
function create_package()
{
  rvm use system #使用系统ruby
  #不存在才重新创建项目，加速新建流水线时的执行速度
  #若需要重新创建app项目可在流水线中清除缓存
  #移除或添加splash.png也需要清空splash.png
  if [[ -d "cordova_build" ]]; then
    rm -rf cordova_build
  fi
  if [[ ! -d "cordova_build" ]]; then
    cordova create cordova_build ${APP_ID} ${APP_NAME}
    cd cordova_build
    mkdir -p resources/android
    cp ../env/cordova/config.xml ./
    cp ../env/cordova/build.json ./
    cp ../env/cordova/icon.png ./resources/
    #cp ../env/cordova/icon.png ./resources/android/icon-foreground.png
    if [[ $(exist_splash) == "true" ]]; then
      cp ../env/cordova/splash.png ./resources/
    fi
    sed -i "" "s/{APP_NAME}/${APP_NAME}/g" config.xml
    sed -i "" "s/{APP_ID}/${APP_ID}/g" config.xml
    sed -i "" "s/{APP_VERSION}/${APP_VERSION}/g" config.xml
    cordova platform add android
    cordova platform add ios
    cordova plugin add cordova-plugin-wkwebview-file-xhr
    cordova plugin add cordova-plugin-code-push
    if [[ $(exist_splash) == "true" ]]; then
      cordova plugin add cordova-plugin-splashscreen
    fi
    cordova plugin add cordova-plugin-geolocation
    cordova plugin add cordova-plugin-dialogs
    cordova plugin add cordova-plugin-device
    cordova plugin add cordova-plugin-statusbar
    cordova plugin add cordova-plugin-screen-orientation
    cordova plugin add cordova-plugin-app-version
    cordova plugin add cordova-plugin-inappbrowser
    cordova plugin add cordova-plugin-alipay-v2 --variable APP_ID=2021001161611262
    cordova plugin add cordova-plugin-wechat  --variable wechatappid=wx700094cc07feeb6b --variable universallink=https://together.youtuosoft.com
    cordova prepare
  else
    cd cordova_build
    mkdir -p resources/android
    cp ../env/cordova/config.xml ./
    cp ../env/cordova/build.json ./
    cp ../env/cordova/icon.png ./resources/
    #cp ../env/cordova/icon.png ./resources/android/icon-foreground.png
    if [[ $(exist_splash) == "true" ]]; then
      cp ../env/cordova/splash.png ./resources/
    fi
    sed -i "" "s/{APP_NAME}/${APP_NAME}/g" config.xml
    sed -i "" "s/{APP_ID}/${APP_ID}/g" config.xml
    sed -i "" "s/{APP_VERSION}/${APP_VERSION}/g" config.xml
  fi
  cordova-res --icon-background-source '#FFFFFF'
  if [[ -z `code-push app list|grep ${PROJ_NAME}-android` ]]; then
    code-push app add ${PROJ_NAME}-android android cordova
  fi
  if [[ -z `code-push app list|grep ${PROJ_NAME}-ios` ]]; then
    code-push app add ${PROJ_NAME}-ios ios cordova
  fi
  if [[ $DEPLOY_ENV == "dev" ]]; then
    push_key=`code-push deployment list ${PROJ_NAME}-android -k|grep Staging|awk '{print $4}'`
    #以下用的sed语法与linux不同，是macos特有语法
    sed -i "" "s/{UPDATE_KEY_ANDROID}/${push_key}/g" config.xml
    push_key=`code-push deployment list ${PROJ_NAME}-ios -k|grep Staging|awk '{print $4}'`
    sed -i "" "s/{UPDATE_KEY_IOS}/${push_key}/g" config.xml
  else
    push_key=`code-push deployment list ${PROJ_NAME}-android -k|grep Production|awk '{print $4}'`
    #以下用的sed语法与linux不同，是macos特有语法
    sed -i "" "s/{UPDATE_KEY_ANDROID}/${push_key}/g" config.xml
    push_key=`code-push deployment list ${PROJ_NAME}-ios -k|grep Production|awk '{print $4}'`
    sed -i "" "s/{UPDATE_KEY_IOS}/${push_key}/g" config.xml
  fi
  sed -i "" "s/{HTTP_SCHEMA}/${HTTP_SCHEMA}/g" config.xml
  sed -i "" "s/{UPDATE_DOMAIN}/${UPDATE_DOMAIN}/g" config.xml
  cat config.xml
}
#执行cordova构建操作，主要是执行cordova build
function package()
{
  if [[ ! -d cordova_build ]]; then
    echo "cordova_build目录不存在，请重新完整运行流水线"
    exit 3
  fi
  rvm use system #使用系统ruby
  cd cordova_build
  rm -rf ./www/*
  cp -a ../app_dist/* ./www/
  #设置app版本号
  awk -v CONFIG_VERSION="version=\"${APP_VERSION}\"" '/widget id.*version=.*xmlns/ { gsub(/version=\"([0-9\.]{1,}|\{APP_VERSION\})\"/,CONFIG_VERSION); print $0; next }
			{print $0}
			' config.xml>config.xml.tmp
	cp config.xml.tmp config.xml
	rm config.xml.tmp
	cat config.xml
  if [[ $DEPLOY_ENV == "dev" ]]; then
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      cordova build --debug --device --gradleArg=--parallel android
    fi
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      security unlock-keychain -p YoutuoSoft1234
      cordova build --debug --device --gradleArg=--parallel ios
    fi
  else
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      cordova build --release --device --gradleArg=--parallel android
    fi
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      security unlock-keychain -p YoutuoSoft1234
      cordova build --release --device --gradleArg=--parallel ios
    fi
  fi
  echo "{
  \"APP_VERSION\": \"$APP_VERSION\"
}" > version.json
}
#上传android app包到服务器根目录
function upload_package_android()
{
  #CHANGELOG=`git show -s --format=%s`
  rvm use system #使用系统ruby
  ssh root@$SERVER mkdir -p $WWW_PATH/${PROJ_NAME}
  cd cordova_build
  if [[ $DEPLOY_ENV == "dev" ]]; then
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      cp "platforms/android/app/build/outputs/apk/debug/app-debug.apk" ${APP_SHORT_NAME}.apk
      scp -qB ${APP_SHORT_NAME}.apk root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.apk
    fi
  else
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      cp "platforms/android/app/build/outputs/apk/release/app-release.apk" ${APP_SHORT_NAME}.apk
      scp -qB ${APP_SHORT_NAME}.apk root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.apk
    fi
  fi
  scp -qB version.json root@$SERVER:$WWW_PATH/${PROJ_NAME}/version.json
}
#上传ios app包到服务器根目录
function upload_package_ios()
{
  #CHANGELOG=`git show -s --format=%s`
  rvm use system #使用系统ruby
  ssh root@$SERVER mkdir -p $WWW_PATH/${PROJ_NAME}
  cd cordova_build
  if [[ $DEPLOY_ENV == "dev" ]]; then
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      cp "platforms/ios/build/device/${APP_NAME}.ipa" ${APP_SHORT_NAME}.ipa
      scp -qB ${APP_SHORT_NAME}.ipa root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.ipa
      ipa_plist_gen -i ${RECOMMEND_URL}${APP_SHORT_NAME}.ipa -b ${APP_ID} -t ${APP_NAME} --display-image ${RECOMMEND_URL}/icon.png > ${APP_SHORT_NAME}.plist
      scp -qB ${APP_SHORT_NAME}.plist root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.plist
    fi
  else
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      cp "platforms/ios/build/device/${APP_NAME}.ipa" ${APP_SHORT_NAME}.ipa
#      scp -qB ${APP_SHORT_NAME}.ipa root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.ipa
      ipa_plist_gen -i ${RECOMMEND_URL}/${APP_SHORT_NAME}.ipa -b ${APP_ID} -t ${APP_NAME} --display-image ${RECOMMEND_URL}/icon.png > ${APP_SHORT_NAME}.plist
      scp -qB ${APP_SHORT_NAME}.plist root@$SERVER:$WWW_PATH/${PROJ_NAME}/${APP_SHORT_NAME}.plist
    fi
  fi
  scp -qB version.json root@$SERVER:$WWW_PATH/${PROJ_NAME}/version.json
}
#android热更新部署
function codepush_android()
{
  #CHANGELOG=`git show -s --format=%s`
  rvm use system #使用系统ruby
  ssh root@$SERVER mkdir -p $WWW_PATH/${PROJ_NAME}
  cd cordova_build
  if [[ $DEPLOY_ENV == "dev" ]]; then
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      code-push release-cordova ${PROJ_NAME}-android android -d Staging --noDuplicateReleaseError --mandatory -t "$TARGET_VERSION"
    fi
  else
    if [[ $BUILD_PLATFORM == "android" || $BUILD_PLATFORM == "all" ]]; then
      code-push release-cordova ${PROJ_NAME}-android android -d Production --noDuplicateReleaseError --mandatory -t "$TARGET_VERSION"
    fi
  fi
}
#部署ios热更新
function codepush_ios()
{
  #CHANGELOG=`git show -s --format=%s`
  rvm use system #使用系统ruby
  ssh root@$SERVER mkdir -p $WWW_PATH/${PROJ_NAME}
  cd cordova_build
  if [[ $DEPLOY_ENV == "dev" ]]; then
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      code-push release-cordova ${PROJ_NAME}-ios ios -d Staging --noDuplicateReleaseError --mandatory -t "$TARGET_VERSION"
    fi
  else
    if [[ $BUILD_PLATFORM == "ios" || $BUILD_PLATFORM == "all" ]]; then
      code-push release-cordova ${PROJ_NAME}-ios ios -d Production --noDuplicateReleaseError --mandatory -t "$TARGET_VERSION"
    fi
  fi
}
#执行app包的npm build
function npm_build_mode()
{
  cp env/cordova/index.html public/index.html
  echo "VUE_APP_MODE = 'hash'" >> .env.local
  echo "VUE_APP_PUBLIC = './'" >> .env.local
  if [[ ! -d node_modules ]]; then
    echo "没有node_modules目录，可能是缓存已清空或instal失败，请重新完整运行流水线"
    exit 4
  fi
  cat .env.local
  if [[ $DEPLOY_ENV == "dev" ]]; then
    mkdir -p public/js
		#删除了eruda
    NODE_ENV=production UNI_OUTPUT_DIR=app_dist/ npx vue-cli-service uni-build
  else
		NODE_ENV=production UNI_OUTPUT_DIR=app_dist/ npx vue-cli-service uni-build
  fi
}
#执行h5的npm build
function npm_build()
{
  cp env/${ENV_MODE}/index.html public/index.html
  echo "VUE_APP_MODE='${MODE}'" >> .env.local
  echo "VUE_APP_PUBLIC='${PUBLIC}'" >> .env.local
  if [[ ! -d node_modules ]]; then
    echo "没有node_modules目录，可能是缓存已清空或instal失败，请重新完整运行流水线"
    exit 4
  fi
  cat .env.local
  if [[ $DEPLOY_ENV == "dev" ]]; then
    mkdir -p public/js
    #删除了eruda
		NODE_ENV=production UNI_OUTPUT_DIR=dist/ npx vue-cli-service uni-build
  else
    NODE_ENV=production UNI_OUTPUT_DIR=dist/ npx vue-cli-service uni-build
  fi
}
function down_cer()
{
  mkdir -p certs
  scp -r root@$SERVER:$DOCKER_PATH/data/acme.sh/$DOMAIN/* certs/ || echo certificate files is not exists.
}
function remove_build()
{
  echo "将删除当前项目所有build文件"
  current_dir=$(pwd)
  cd ../../.. && rm -rf ./*/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}/*
  cd "$current_dir"
}
#检查项目冲突
function check()
{
  #是否mobile分组
  if [[ $CI_PROJECT_NAMESPACE != 'mobile' ]]; then
    echo "不是mobile分组的项目"
    exit 7
  fi
  #域名是否已存在
  all_count=`ssh root@$SERVER "grep -P '\s+$DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/*.conf|wc -l"`
  proj_count=0
  if [[ `exist_site` == "true" ]]; then
    proj_count=`ssh root@$SERVER "grep -P '\s+$DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/${PROJ_NAME}.conf|wc -l"`
  fi
  if [[ $all_count != "${proj_count}" ]]; then
    echo "域名冲突"
    ssh root@$SERVER "grep -P '\s+$DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/*.conf"
    exit 7
  fi
  #update域名是否已存在
  all_count=`ssh root@$SERVER "grep -P '\s+$UPDATE_DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/*.conf|wc -l"`
  proj_count=0
  if [[ `exist_site` == "true" ]]; then
    proj_count=`ssh root@$SERVER "grep -P '\s+$UPDATE_DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/${PROJ_NAME}.conf|wc -l"`
  fi
  if [[ $all_count != "${proj_count}" ]]; then
    echo "update域名冲突"
    ssh root@$SERVER "grep -P '\s+$UPDATE_DOMAIN(\s+|;)' $DOCKER_PATH/data/web/nginx/sites-enabled/*.conf"
    exit 7
  fi
  #check package name
  package_name=$(grep -P -o  '(?<=name": ")[a-zA-Z0-9_\-\/@]+' package.json)
  if [[ -z "$package_name" ]]; then
    echo "package.json不存在name字段"
    exit 7
  fi
  all_count=$(grep -P -o "(?<=name\": \")${package_name}" ../../*/*/package.json | wc -l)
  proj_count=$(grep -P -o "(?<=name\": \")${package_name}" package.json | wc -l)
  if [[ $all_count != $proj_count ]]; then
    echo "package.json中name冲突,修改name后再重新上传,以下是可能冲突的项目文件"
    grep -P "(?<=name\": \")${package_name}" ../../*/*/package.json
    remove_build
    exit 7
  fi
}
#检查APP_ID是否冲突
#该函数在mac上运行
function check_app()
{
  #appid是否已存在
  if [[ -z "$APP_ID" ]]; then
    echo "APP_ID不存在"
  fi
  all_count=`grep "${APP_ID}" ../../*/*/cordova_build/config.xml || echo -n | wc -l | xargs` #xargs是为了删除前导空格,mac上才需要这么写
  proj_count=0
  if [[ $(exist_cordova) == "true" ]]; then
    proj_count=`grep "${APP_ID}" cordova_build/config.xml || echo -n | wc -l | xargs`
  fi
  if [[ $all_count != $proj_count ]]; then
    echo "APP_ID冲突,修改APP_ID后再重新上传,以下是可能冲突的项目文件"
    grep "${APP_ID}" ../../*/*/cordova_build/config.xml
    remove_build
    exit 7
  fi
}
#部署环境
export DEPLOY_ENV=$CI_COMMIT_REF_SLUG
#项目名称
export PROJ_NAME=$CI_PROJECT_PATH_SLUG
#生成版本号
BUILD_VERSION=`git rev-list --count HEAD`
HASH_VERSION=`git rev-parse --short HEAD`
export BUILD_VERSION
TAG_VERSION=`git describe --tags --abbrev=0 || echo 1.0`
if [[ -z `git describe --tags --abbrev=0` ]]; then
  TAG_VERSION=1.0
  PATCH_VERSION=$BUILD_VERSION
else
  TAG_BUILD_VERSION=`git rev-list --count $TAG_VERSION`
  PATCH_VERSION=$(($BUILD_VERSION - $TAG_BUILD_VERSION))
fi

APP_VERSION=${TAG_VERSION}.${PATCH_VERSION}
#设置不同部署环境下的环境变量
if [[ $DEPLOY_ENV == "dev" ]]; then
  export DOMAIN=$LOCAL_DOMAIN
  export API_URL=$LOCAL_API_URL
  export IMG_URL=$LOCAL_IMG_URL
  export RECOMMEND_URL=$LOCAL_RECOMMEND_URL
  export SERVER=$LOCAL_SERVER
  export WWW_PATH=$LOCAL_WWW_PATH
  export DOCKER_PATH=$LOCAL_DOCKER_PATH
  export SITE_CONF_PATH=$LOCAL_SITE_CONF_PATH
  export MODE=$LOCAL_MODE
  export PUBLIC=$LOCAL_PUBLIC
  export ENV_MODE=development
  export UPDATE_DOMAIN=$LOCAL_UPDATE_DOMAIN
  export BUILD_PLATFORM=$LOCAL_BUILD_PLATFORM
  export HTTPS_DOMAIN=$LOCAL_HTTPS_DOMAIN
  export HTTPS_HSTS=$LOCAL_HTTPS_HSTS
else
  export DOMAIN=$REMOTE_DOMAIN
  export API_URL=$REMOTE_API_URL
  export IMG_URL=$REMOTE_IMG_URL
  export RECOMMEND_URL=$REMOTE_RECOMMEND_URL
  export SERVER=$REMOTE_SERVER
  export WWW_PATH=$REMOTE_WWW_PATH
  export DOCKER_PATH=$REMOTE_DOCKER_PATH
  export SITE_CONF_PATH=$REMOTE_SITE_CONF_PATH
  export MODE=$REMOTE_MODE
  export PUBLIC=$REMOTE_PUBLIC
  export ENV_MODE=production
  export UPDATE_DOMAIN=$REMOTE_UPDATE_DOMAIN
  export BUILD_PLATFORM=$REMOTE_BUILD_PLATFORM
  export HTTPS_DOMAIN=$REMOTE_HTTPS_DOMAIN
  export HTTPS_HSTS=$REMOTE_HTTPS_HSTS
fi
#热更新服务器的协议前缀
if [[ "$HTTPS_DOMAIN" == "true" ]]; then
  export HTTP_SCHEMA=https
else
  export HTTP_SCHEMA=http
fi
#acme.sh增加--test选项以申请测试证书
if [[ "$FORCE_SITE" == "test" ]]; then
  export ACME_OPTS=" --test"
fi
