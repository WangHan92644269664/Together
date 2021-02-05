export default class LastMayday {
	palette(portrait,name,code) {
		return ({
			"width": "654px",
			"height": "1000px",
			"background": "#ffffff",
			"views": [{
					"type": "image",
					"url": "http://reg.25175.com/share/images/shareBg.png",
					"css": {
						"width": "654px",
						"height": "1000px",
						"top": "0px",
						"left": "0px",
						"rotate": "0",
						"borderRadius": "",
						"borderWidth": "",
						"borderColor": "#000000",
						"shadow": "",
						"mode": "scaleToFill"
					}
				},
				{
					"type": "qrcode",
					"content": code,
					"css": {
						"color": "#000000",
						"background": "#ffffff",
						"width": "95.5px",
						"height": "95.5px",
						"top": "736.5px",
						"left": "417.5px",
						"rotate": "0",
						"borderRadius": ""
					}
				},
				{
					"type": "image",
					"url": portrait,
					"css": {
						"width": "100px",
						"height": "100px",
						"top": "267px",
						"left": "120px",
						"rotate": "0",
						"borderRadius": "15px",
						"borderWidth": "",
						"borderColor": "#000000",
						"shadow": "",
						"mode": "scaleToFill"
					}
				},
				{
					"type": "text",
					"text": "你的好友【"+ name +"】",
					"css": {
						"color": "#333333",
						"background": "rgba(0,0,0,0)",
						"width": "320px",
						"height": "35.74999999999999px",
						"top": "271px",
						"left": "237px",
						"rotate": "0",
						"borderRadius": "",
						"borderWidth": "",
						"borderColor": "#000000",
						"shadow": "",
						"padding": "0px",
						"fontSize": "25px",
						"fontWeight": "bold",
						"maxLines": "2",
						"lineHeight": "36.07500000000001px",
						"textStyle": "fill",
						"textDecoration": "none",
						"fontFamily": "",
						"textAlign": "left"
					}
				},
				{
					"type": "text",
					"text": "正在分享，快来加入吧！",
					"css": {
						"color": "#999999",
						"background": "rgba(0,0,0,0)",
						"width": "320px",
						"height": "22.88px",
						"top": "340px",
						"left": "236px",
						"rotate": "0",
						"borderRadius": "",
						"borderWidth": "",
						"borderColor": "#000000",
						"shadow": "",
						"padding": "0px",
						"fontSize": "16px",
						"fontWeight": "normal",
						"maxLines": "2",
						"lineHeight": "23.088000000000005px",
						"textStyle": "fill",
						"textDecoration": "none",
						"fontFamily": "",
						"textAlign": "left"
					}
				}
			]
		});
	}
}