<template>
	<text v-if="text" :class="inverted ? 'uni-badge--' + type + ' uni-badge--' + size + ' uni-badge--' + type + '-inverted' : 'uni-badge--' + type + ' uni-badge--' + size" class="uni-badge" :style="width" @click="onClick()">{{ text }}</text>
</template>

<script>
	export default {
		name: 'UniBadge',
		props: {
			type: {
				type: String,
				default: 'default'
			},
			inverted: {
				type: Boolean,
				default: false
			},
			text: {
				type: [String, Number],
				default: ''
			},
			size: {
				// small.normal
				type: String,
				default: 'normal'
			}
		},
		data() {
			return {
				width: `display: inline-block;width: ${String(this.text).length * 15 + 15}rpx`
			};
		},
		methods: {
			onClick() {
				this.$emit('click');
			}
		}
	};
</script>

<style scoped>
	.uni-badge {
		/* #ifndef APP-PLUS */
		display: flex;
		/* #endif */
		flex-direction: row;
		height: 30rpx;
		line-height: 30rpx;
		color: #FFFFFF;
		border-radius: 100px;
		background-color: red;
		background-color: transparent;
		text-align: center;
		font-family: 'Helvetica Neue', Helvetica, sans-serif;
		font-size: 12px;
		padding: 0;
		position: absolute;
		top: 0;
		right: 0;
	}

	.uni-badge--inverted {
		padding: 0 5px 0 0;
		color: #FFFFFF;
	}

	.uni-badge--default {
		color: #FFFFFF;
		background-color: red;
	}

	.uni-badge--default-inverted {
		color: #999;
		background-color: transparent;
	}

	.uni-badge--primary {
		color: #fff;
		background-color: #007aff;
	}

	.uni-badge--primary-inverted {
		color: #007aff;
		background-color: transparent;
	}

	.uni-badge--success {
		color: #fff;
		background-color: #4cd964;
	}

	.uni-badge--success-inverted {
		color: #4cd964;
		background-color: transparent;
	}

	.uni-badge--warning {
		color: #fff;
		background-color: #f0ad4e;
	}

	.uni-badge--warning-inverted {
		color: #f0ad4e;
		background-color: transparent;
	}

	.uni-badge--error {
		color: #fff;
		background-color: #dd524d;
	}

	.uni-badge--error-inverted {
		color: #dd524d;
		background-color: transparent;
	}

	.uni-badge--small {
		transform: scale(0.8);
		transform-origin: center center;
	}
</style>