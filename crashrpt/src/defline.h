#pragma once

#include <iostream>
#include <string>
#include <vector>

//定义程序结构休//////////////////////////////////
//头信息
typedef struct _b {
	std::string m_AppName;//程序名称
	std::string m_APPVersion;//程序版本
	std::string m_EmailSubject;//程序描述
	std::string m_EmailTo;//邮件
	int		    m_HeartBeatTime;//心跳时长 轮训时长=（心跳时长+10)*监控线程个数
	int			m_OverTime;//超时时长
	std::string m_LocalHostIP;//本机ip
	std::string m_LocalHostPort;//本机port
	std::string m_ServerIP;//服务ip
	std::string m_ServerPort;//服务端口
	std::string m_MQServerUrl;
}HeadInfo;
//本机性能信息
typedef struct _c {
	std::string m_CpuUseRate;//机器cpu使用率
	std::string m_HardDiskUseRate;//硬盘使用率
	std::string m_NetUseRate;//网络使用率
	std::string m_MemoryUseRate;//内存使用率
}LocalPerInfo;
//通信参数
typedef struct _d {
	std::string m_SignalFormat;//通信格式 以@符号间隔 后面跟序号 后面是格式化字符串 后面跟实际数据 例子@1s%s@2d%d 表示第一参数是字符串类型第二参数是数字类型
	std::string m_SignalSharedMemoryName;//共享内存名称
}SignalParameter;
//Dump参数
typedef struct _e {
	std::string m_DumpPahtName;//dump名字
	std::string m_DumpScreenCapture;//截图
	std::string m_DumpLogPaht;//log路径
	std::string m_DumpSystemLogPaht;//system log路径
	std::string m_DumpSendEmail;//邮件地址
}DumpParameter;
//进程参数
typedef struct _f {
	std::string 	m_ProcessGuid;//进程GUID
	std::string 	m_ProcessName;//进程名字
	std::string 	m_ProcessPaht;//进程路径
	std::string 	m_ProcessCpuUse;//进程cpu使用率
	std::string 	m_processHDUse;//进程硬盘使用率
	std::string 	m_ProcessMemoryUse;//进程内存使用率
	std::string		m_ProcessNetUse;//进程网络使用率
	std::string 	m_SystemType;//进程运行系统
	std::string 	m_ProcessRestartPar;//进程重启参数
	int 			m_ProcessDumpType;//进程 dump 类型 1(重启不生成dump)2(重启生成dump)3(重启生成dump 截图 打包日志和系统日志) 4(打包完成发送email)
	int 			m_ProcessSignalType;//进程 通信 类型 0(只是查找进程存在与否) 3(sharedmemory)
	DumpParameter	m_DumpPar;// 生成dump参数
	SignalParameter	m_SignalPar;//通信参数
}ProcessItem;
//主体结构
typedef struct _a {
	HeadInfo		t_CHeadInfo;//信息头
	LocalPerInfo	t_LPerInfo;//本机信息
	std::vector<ProcessItem> v_Process;//监控进程信息
}CarshrptPar;
////////////////////////////////////////////////
//全局变量
CarshrptPar g_Carshrpt;