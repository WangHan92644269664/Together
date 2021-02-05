
// 验证账号
function isAccount(value) {
  if(!(/^[0-9a-zA-Z_-]{1,}$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证手机号
function isPhone(value) {
  if(!(/^1(3|4|5|6|7|8|9)\d{9}$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证密码
function isPwd(value) {
  if(value.length<6){
    return false;
  }else{
    return true;
  }
}
// 验证邮箱
function isEmail(value) {
  if(!(/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证身份证号
function isId_No(value) {
  if(!(/^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证QQ号
function isQQ(value) {
  if(!(/[1-9][0-9]{4,10}$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证邮编
function isZip(value) {
  if(!(/^[1-9][0-9]{5}$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证金额
function isCurrency(value) {
  if(!(/^[1-9]\d*00$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证姓名
function isName(value) {
  if(!(/^[\u2E80-\u9FFF]+$/.test(value))){
    return false;
  }else{
    return true;
  }
}
// 验证银行卡号
function isBankNo(value) {
  if(!(/^([1-9]{1})(\d{14}|\d{18})$/.test(value))){
    return false;
  }else{
    return true;
  }
}


export  default {
  isAccount,
  isPhone,
  isPwd,
  isEmail,
  isId_No,
  isQQ,
  isZip,
  isCurrency,
  isName,
  isBankNo
}
