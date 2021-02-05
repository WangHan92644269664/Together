import utils from './utils.js'
import api from './api.js'
let getProductImg = val => {
	if (val) {
		let v = val.slice(0, 17);
		console.log(process.env.VUE_APP_IMG_URL + 'product/' + v)
		return process.env.VUE_APP_IMG_URL + 'product/' + v;
	}
}
let getProductPreviewImg = val => {
	if (val) {
		let v = val.slice(0, 17);
		return process.env.VUE_APP_IMG_URL + 'product/preview-' + v;
	}
}
let getProductThumbImg = val => {
	if (val) {
		let v = val.slice(0, 17);
		return process.env.VUE_APP_IMG_URL + 'product/thumb-' + v;
	}
}
// 将数据比较大的时候进行转化
let formatMoney = (num) => {
	const si = [{
			value: 1,
			symbol: ""
		},
		{
			value: 1E3,
			symbol: "K"
		},
		{
			value: 1E6,
			symbol: "M"
		},
		{
			value: 1E9,
			symbol: "G"
		},
		{
			value: 1E12,
			symbol: "T"
		},
		{
			value: 1E15,
			symbol: "P"
		},
		{
			value: 1E18,
			symbol: "E"
		}
	];
	const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
	let i;
	for (i = si.length - 1; i > 0; i--) {
		if (num >= si[i].value) {
			break;
		}
	}
	return (num / si[i].value).toFixed(2).replace(rx, "$1") + si[i].symbol;
}

// 将数据比较大的时候进行转化
let formatDistance = (num) => {
	const si = [{
			value: 1,
			symbol: "m"
		},
		{
			value: 1E3,
			symbol: "km"
		}
	];
	const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
	let i;
	for (i = si.length - 1; i > 0; i--) {
		if (num >= si[i].value) {
			break;
		}
	}
	return (num / si[i].value).toFixed(2).replace(rx, "$1") + si[i].symbol;
}

// 整数
let Fixed = (val) => {
	return Number(val).toFixed(0)
}

// 整数
let Two = (val) => {
	return Number(val).toFixed(2)
}

// 获取战队头像
let getImg = (val) => {
	console.log(val)
	if (val) {
		return val.indexOf('https') !== -1 ? val : utils.imgUrl + 'avatar/' + val
	} else {
		return utils.webImg2 + 'logo.png'
	}
}

let getAreaName = (val) => {
	const areas = uni.getStorageSync('areas')
	for (const item of areas) {
		if (val === item.area_id) {
			return item.area_name
		}
	}
}

let getFinanceName = val => {
	const finances = uni.getStorageSync('finances')
	for (const item of finances) {
		if (item.finance_type === Number(val)) {
			return item.financeType.finance_type_name
		}
	}
}

// 获取分组名称
let getGroupName = val => {
	const groups = uni.getStorageSync('groups')
	for (const item of groups) {
		if (item.product_group_id === Number(val)) {
			return item.product_group_name
		}
	}
}


export default {
	getProductImg,
	getProductPreviewImg,
	getProductThumbImg,
	formatMoney,
	formatDistance,
	Fixed,
	getImg,
	getAreaName,
	Two,
	getFinanceName,
	getGroupName
}
