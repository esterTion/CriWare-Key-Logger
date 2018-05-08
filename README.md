## CriWare key logger
> iOS tweak, package at [com.estertion.crikeylogger_2_iphoneos-arm.deb](raw/master/com.estertion.crikeylogger_2_iphoneos-arm.deb) or [https://repo.estertion.win/](https://repo.estertion.win/)

![](https://wx3.sinaimg.cn/large/763783e4ly1foqrjhwy1pj20vk0hs4qp.jpg)

Intercept and log hca key  
Usage:  
1. Use [il2cppDumper](https://github.com/Perfare/il2cppDumper) to dump the function offset of `CriWareDecrypterConfig.ctor()` (You might need some tool such as Clutch to dump the app exectuable binary)
2. Install the deb package
3. Modify `/Library/MobileSubstrate/DynamicLibraries/CRIKeyLogger.plist`, edit entry `InjectAppID` to app id to inject, edit entry `InjectFunctionOffset` to function offset from `dump.cs`
4. Open the game and retrive your key

拦截并记录hca密钥  
用法:  
1. 用 [il2cppDumper](https://github.com/Perfare/il2cppDumper) 获取 `CriWareDecrypterConfig.ctor()` 函数的偏移地址 (你可能需要如 Clutch 之类的工具获得未加密的程序可执行文件)
2. 安装deb包
3. 在设备上修改 `/Library/MobileSubstrate/DynamicLibraries/CRIKeyLogger.plist`, 编辑 `InjectAppID` 至需要注入的程序id, 编辑 `InjectFunctionOffset` 至从 `dump.cs` 里得到的函数偏移地址
4. 打开游戏取得key
