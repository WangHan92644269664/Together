<template>
	<!--地址picker-->
	<view v-if="lotusAddressData.visible" class="lotus-address-mask">
		<view :class="lotusAddressData.visible?'lotus-address-box':'lotus-address-box lotus-address-box-out'">
			<view class="lotus-address-action">
				<text @tap="cancelPicker" class="lotus-address-action-cancel">取消</text>
				<text @tap="chosedVal" class="lotus-address-action-affirm">确认</text>
			</view>
			<view class="lotus-address-picker-box">
				<!--省-->
				<scroll-view scroll-y :scroll-into-view="'pid'+pChoseIndex" class="lotus-address-picker-box-item">
					<view @tap="clickPicker(0,pIndex,pItem);" :id="'pid'+pIndex" :class="pIndex === pChoseIndex?'lotus-address-picker lotus-address-picker2':'lotus-address-picker'"
					 v-for="(pItem,pIndex) in province" :key="pIndex">{{pItem.area_name}}</view>
				</scroll-view>
				<!--市-->
				<scroll-view scroll-y :scroll-into-view="'cid'+cChoseIndex" class="lotus-address-picker-box-item" v-if="cityF">
					<view @tap="clickPicker(1,cIndex,cItem);" :id="'cid'+cIndex" :class="cIndex === cChoseIndex?'lotus-address-picker lotus-address-picker2':'lotus-address-picker'"
					 v-for="(cItem,cIndex) in city" :key="cIndex">{{cItem.name}}</view>
				</scroll-view>
				<!--区-->
				<scroll-view scroll-y :scroll-into-view="'tid'+tChoseIndex" class="lotus-address-picker-box-item" v-if="townF">
					<view @tap="clickPicker(2,tIndex,tItem);" :id="'tid'+tIndex" :class="tIndex === tChoseIndex?'lotus-address-picker lotus-address-picker2':'lotus-address-picker'"
					 v-for="(tItem,tIndex) in town" :key="tIndex">{{tItem.name}}</view>
				</scroll-view>
				<!--区END-->
			</view>
		</view>
	</view>
	<!--地址picker END-->
</template>

<script>
	export default {
		props: ['lotusAddressData'],
		data() {
			return {
				visible: false,
				province: [],
				city: [],
				town: [],
				provinceName: '',
				cityName: '',
				townName: '',
				type: 0, //0新增1编辑
				pChoseIndex: -1,
				cChoseIndex: -1,
				tChoseIndex: -1,
				lotusAddressJson: [],
				cityF:false,
				townF:false
			};
		},
		async created() {
			await this.$utils.postUrl('GET', 'areas?page=1&per-page=2147483647&sort=-area-id').then(res => {
						res.data.map((item, index) => {
							if (item.area_depth!== 1) {
								this.lotusAddressJson.push({
									value: item.area_id,
									name: item.area_name,
									parent: item.area_parent_id
								})
							} else {
								this.province.push(item)
							}
						})
					})
			
		},
		methods: {
			//取消
			cancelPicker() {
				this.visible = false;
				this.$emit("choseVal", {
					visible: false
				});
			},
			//获取最后选择的省市区的值
			chosedVal() {
				if(this.cChoseIndex===-1 || this.tChoseIndex ===-1){
					this.$utils.wainToast('请选择完整')
					return
				}
				this.$emit("choseVal", {
					province: this.provinceName,
					city: this.cityName,
					town: this.townName,
					visible: false
				});
				this.tChoseIndex = this.pChoseIndex = this.cChoseIndex = -1
			},
			//选择省市区交互
			clickPicker(type, index, name) {
				let id =null;
				if (type === 0) {
					id = name.area_id;
					this.pChoseIndex = index;
					this.provinceName = name;
					this.cityF = true
					this.city = []
				}
				if (type === 1) {
					id = name.value;
					this.townF = true
					this.town = []
					this.cChoseIndex = index;
					this.cityName = name;
				}
				for(let item of this.lotusAddressJson){
					if(item.parent===id && type===0){
						this.city.push(item)
					}
					if(item.parent===id && type===1){
						this.town.push(item)
					}
				}
				if (type === 2) {
					this.tChoseIndex = index;
					this.townName = name;
				}
			},
		},
	}
</script>

<style lang="scss">
	@import "./simpleAddress.css";
</style>
