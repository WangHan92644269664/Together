<template>
	<view class="content">
		<view class="mix-tree-list">
			<block v-for="(item, index) in treeList" :key="index">
				<view 
					class="mix-tree-item"
					:style="[{
							paddingLeft: item.rank*15 + 'px',
							zIndex: item.rank*-1 +50
						}]"
					:class="{
							border: treeParams.border === true,
							show: item.show,
							last: item.lastRank,
							showchild: item.showChild
						}"
					@click.stop="treeItemTap(item, index)"
				>
				<text class="mix-tree-icon" :class="item.lastRank ?'icon-racle':item.showChild ?'icon-down':'icon-arrfill_d-copy-copy'">
				</text>
					{{item.name}}
					<text class="see" @click.stop="see(item)">查看</text>
				</view>
			</block>
		</view>
	</view>
</template>

<script>
	export default {
		props: {
			list: {
				type: Array,
				default(){
					return [];
				}
			},
			params: {
				type: Object,
				default(){
					return {}
				}
			}
		},
		data() {
			return {
				treeList: [],
				treeParams: {
					defaultIcon: '/static/goods/star.png',
					currentIcon: '/static/goods/star.png',
					lastIcon: '/static/goods/star.png',
					border: false
				}
			}
		},
		watch: {
			list(list){
				
				this.treeParams = Object.assign(this.treeParams, this.params);
				console.log(this.treeParams, this.params);
				this.renderTreeList(list);
			}
		},
		methods: {
			//扁平化树结构
			renderTreeList(list=[], rank=0, parentId=[]){
				list.forEach(item=>{
					this.treeList.push({
						id: item.id,
						name: item.name,
						parentId,  // 父级id数组
						rank,  // 层级
						showChild: false,  //子级是否显示
						show: rank === 0  // 自身是否显示
					})
					if(Array.isArray(item.children) && item.children.length > 0){
						let parents = [...parentId];
						parents.push(item.id);
						this.renderTreeList(item.children, rank+1, parents);
					}else{
						this.treeList[this.treeList.length-1].lastRank = true;
					}
				})
			},
			// 点击
			treeItemTap(item){
				let list = this.treeList;
				let id = item.id;
				// if(item.lastRank === true){
					//点击最后一级时触发事件
					this.$emit('treeItemClick', item);
					// return;
				// }
				item.showChild = !item.showChild;
				list.forEach(childItem=>{
					if(item.showChild === false){
						//隐藏所有子级
						if(!childItem.parentId.includes(id)){
							return;
						}
						if(childItem.lastRank !== true){
							childItem.showChild = false;
						}
						childItem.show = false;
					}else{
						if(childItem.parentId[childItem.parentId.length-1] === id){
							childItem.show = true;
						}
					}
				})
			},
			see(item){
				let {
					id,
					name,
					parentId
                } = item;
				let data = {
                    "memberinfo_account": name
                }
                this.$api.getRecommend(data)
                .then((res) => {
                    uni.showModal({
                    	content: res.data.title
                    })
                })
			}
		}
	}
</script>

<style>
	.mix-tree-list{
		display: flex;
		flex-direction: column;
		padding-left: 30upx;
	}
	.mix-tree-item{
		display: flex;
		align-items: center;
		font-size: 30upx;
		color: #333;
		height: 0;
		opacity: 0;
		transition: .2s;
		position: relative;
	}
	.mix-tree-item.border{
		border-bottom: 1px solid #eee;
	}
	.mix-tree-item.show{
		height: 80upx;
		opacity: 1;
	}
	.mix-tree-icon{
		width: 26upx;
		height: 26upx;
		margin-right: 8upx;
		opacity: .9;
	}
	
	.mix-tree-item.showchild:before{
		transform: rotate(90deg);
	}
	.mix-tree-item.last:before{
		opacity: 0;
	}
	.see{
		display: inline-block;
		padding: 5rpx 10rpx;
		border-radius: 10rpx;
		background: #408CE2;
		color: #FFFFFF;
		position: absolute;
		right: 40rpx;
		font-size: 20rpx;
	}
</style>
