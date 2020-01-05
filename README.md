# MacSerialTransporter
Hackintosh三码拷贝工具 所谓三码就是ROM，序列号，以及系统UUID这三者，用于提供身份令牌，令用户可以正常使用iMessage,facetime等服务。  通常用户不需要修改config文件，但是EFI整体替换或者Clover转OpenCore需要拷贝三码。但是一个不小心替换错了之前又没退出登陆，会造成无法退出甚至被封号的窘境。  于是本人写了个简单的小软件，可以方便的拷贝三码。支持Clover->Clover ,Clover->OpenCore,OpenCore->Clover,OpenCore->OpeCore;

