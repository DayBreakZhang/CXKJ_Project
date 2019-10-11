﻿/**
 * @file    main.cpp
 * <pre>
 * Copyright (c) 2018, Gaaagaa All rights reserved.
 * 
 * 文件名称：main.cpp
 * 创建日期：2018年11月15日
 * 文件标识：
 * 文件摘要：使用NTP协议获取网络时间戳的测试程序。
 * 
 * 当前版本：1.0.0.0
 * 作    者：
 * 完成日期：2018年11月15日
 * 版本摘要：
 * 
 * 取代版本：
 * 原作者  ：
 * 完成日期：
 * 版本摘要：
 * </pre>
 */

#include "VxNtpHelper.h"
#include <iostream>

#ifdef _WIN32
#include <WinSock2.h>
#pragma comment(lib,"ws2_32.lib")
#endif // _WIN32

#include <string>
#include <vector>
#include <string.h>
#include <stdio.h>

////////////////////////////////////////////////////////////////////////////////

#ifdef _WIN32

/**
* @class vxWSASocketInit
* @brief 自动 加载/卸载 WinSock 库的操作类。
*/
class vxWSASocketInit
{
    // constructor/destructor
public:
    vxWSASocketInit(x_int32_t xit_main_ver = 2, x_int32_t xit_sub_ver = 0)
    {
        WSAStartup(MAKEWORD(xit_main_ver, xit_sub_ver), &m_wsaData);
    }

    ~vxWSASocketInit(x_void_t)
    {
        WSACleanup();
    }

    // class data
protected:
    WSAData      m_wsaData;
};

#endif // _WIN32
//====================================================================

int main(int argc, char * argv[])
{
	if (argc != 4) {
		std::cerr << "使用帮助 NTPClient.exe ntp服务ip 网络超时(单位毫秒) 循环时间(单位分钟) i.e. NTPClient.exe 127.0.0.0 10000 10" << std::endl;
		return -1;
	}
	//初始化数据
    x_int32_t xit_err = -1;
    x_uint64_t xut_timev = 0ULL;

#ifdef _WIN32
   vxWSASocketInit gInit;
#endif // _WIN32

   while (1)
   {
	   long _sleeptime = atoi(argv[3]) * 60;

	   //执行ntp
	   xit_err = ntp_get_time(argv[1], NTP_PORT, atoi(argv[2]), &xut_timev);
	   if (0 == xit_err)
	   {
		   //设置时间
		   SetSystemTime_u(xut_timev);
	   }
#if _WIN32
	   Sleep(_sleeptime * 1000);
#else
	   Sleep(_sleeptime);
#endif
   }
    return 0;
}
