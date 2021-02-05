module.exports = {
	chainWebpack: (config) => {
		// ���л�����ʱ������ѹ��ʱ����Ч
		config.optimization.minimizer('terser').tap((args) => {
				const compress = args[0].terserOptions.compress
				// �� App ƽ̨�Ƴ� console ����(�������� console �������� log,debug,info...)
				compress.drop_console = true
				compress.pure_funcs = [
						'__f__', // App ƽ̨ vue �Ƴ���־����
						// 'console.debug' // ���Ƴ�ָ���� console ����
				]
				return args
		})
	}
}