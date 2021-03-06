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
	if (argc != 5) {
		std::cerr << "使用帮助 NTPClient.exe ntp服务ip 网络超时(单位毫秒) 循环时间(单位分钟) 日志地址 i.e. NTPClient.exe 127.0.0.0 10000 10 d:\\log" << std::endl;
		return -1;
	}
	//初始化G3log
#if (defined(WIN32) || defined(_WIN32) || defined(__WIN32__))
	const std::string path_to_log_file = argv[4];
	std::string cmdPaht = "mkdir \"" + path_to_log_file+"\"";
	system(cmdPaht.c_str());
#else
	const std::string path_to_log_file = "/tmp/NTPClinetLog/";
#endif
	std::unique_ptr<g3::LogWorker> logworker{ g3::LogWorker::createLogWorker() };
	auto sinkHandle = logworker->addSink(std::make_unique<g3::FileSink>("NtpClient", path_to_log_file, "CXKJ"),
		&g3::FileSink::fileWrite);
	
	g3::initializeLogging(logworker.get());
	std::future<std::string> log_file_name = sinkHandle->call(&g3::FileSink::fileName);
	std::cout<< "日志路径： [" << log_file_name.get() << "]" << std::endl;
	//设置消息最大字节数
	g3::only_change_at_initialization::setMaxMessageSize(2048);
	//设置log文件大小
	// You can call in a thread safe manner public functions on the logrotate sink
   // The call is asynchronously executed on your custom sink.
	//const int k10MBInBytes = 10 * 1024 * 1024;
	//std::future<void> received = sinkHandle->call(&g3::LogRLogRotate::setMaxLogSize, k10MBInBytes);
	// Exmple of overriding the default formatting of log entry
	auto changeFormatting = sinkHandle->call(&g3::FileSink::overrideLogDetails, g3::LogMessage::FullLogDetailsToString);
	const std::string newHeader = "\t\tLOG format: [YYYY/MM/DD hh:mm:ss uuu* LEVEL THREAD_ID FILE->FUNCTION:LINE] message\n\t\t(uuu*: microseconds fractions of the seconds value)\n\n";
	// example of ovrriding the default formatting of header
	auto changeHeader = sinkHandle->call(&g3::FileSink::overrideLogHeader, newHeader);

	changeFormatting.wait();
	changeHeader.wait();

	//初始化数据
    x_int32_t xit_err = -1;
    x_uint64_t xut_timev = 0ULL;

#ifdef _WIN32
   vxWSASocketInit gInit;
#endif // _WIN32
   LOG(INFO) << "NTP Server:" << argv[1];
   LOG(INFO) << "NTP TimeOut:" << argv[2] << "毫秒/单位";
   LOG(INFO) << "NTP PollTime:" << argv[3] << "分钟/单位";
   double count = 0;
   while (1)
   {
	   printf("第%d次查询NTP(%s)服务",count, argv[1]);
	   count++;
	   LOG(INFO) << "NTP Poll Count:" << count;

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
