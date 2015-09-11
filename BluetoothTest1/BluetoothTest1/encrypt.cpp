//#include "stdafx.h"

#ifndef encrypt
#define encrypt



//#import <CocoaLumberjack.h>
//static const NSInteger ddLogLevel = DDLogLevelAll;
// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.


#include "Aes.h"
#include <objc/objc.h>
#include <string.h>

bool g_bInitTabs = false;
bool g_bInitAes = false;
struct aes_ctx  g_aes;
unsigned char g_aesKey[16];


//设置128位密钥（16个字节）
bool SetKey128(unsigned char* key)
{
	if(aes_set_key(&g_aes, (u8*)key , KEY_LEN) != 0)
	{
		return false;
	}
	memcpy(g_aesKey, (u8*)key, KEY_LEN);
	g_bInitAes = true;
	return true;
}

//加密函数
//初始化加解密模块，主要是初始化算法
bool InitEncry()
{
	//密钥
	unsigned int key[4] = {0x97239704, 0x02189645, 0x39148921, 0x29842862};
	//使用aes
	aes_gen_tabs();

	//暂时使用固定128位密钥
	if(aes_set_key(&g_aes, (u8*)key , KEY_LEN) != 0)
	{
		return false;
	}
	
    (g_aesKey, (u8*)key, KEY_LEN);

	return true;
}

BOOL EncryData(char* SrcData, char* EncData, unsigned long Len, char* CtrlSequeue)
{
	unsigned long i;
	char ch;
	char* pTmpSrcData = SrcData;
	char* pTmpEncData = EncData;
	//暂时测试，直接跟'Z'进行异或
    for(i = 0; i < Len; i++)
    {
        ch = *pTmpSrcData;
        ch = (char)((ch + (i & 0x3F)) ^ 'Z');
        //和CtrlSequeue进行异或
        *pTmpEncData = ch ^ CtrlSequeue[i & 3];
        pTmpSrcData++;
        pTmpEncData++;
    }

	//进行aes加密，这里的aes加密只需要目标数据即可
	pTmpEncData = EncData;
	if(g_bInitAes)
	{
		i = Len / g_aes.key_length;
		while(i)
		{
			aes_encrypt(&g_aes, (u8*)pTmpEncData, (u8*)pTmpEncData);
			i--;
			pTmpEncData += g_aes.key_length;
		}
	}

	return YES;
}

BOOL DecryData(char* SrcData, char* DecData, unsigned long Len, char* CtrlSequeue)
{
	unsigned long i;
	char ch;
	char* pTmpSrcData = SrcData;
	char* pTmpDecData = DecData;
	unsigned long nLost;  //剩余的没有加密的数据

	//进行aes解密
	if(g_bInitAes)
	{
		i = Len / g_aes.key_length;
		nLost = Len % g_aes.key_length;
		while(i)
		{
			aes_decrypt(&g_aes, (u8*)pTmpSrcData, (u8*)pTmpDecData);
			i--;
			pTmpSrcData += g_aes.key_length;
			pTmpDecData += g_aes.key_length;
		}
		//拷贝剩余数据
		memcpy(pTmpDecData, pTmpSrcData, nLost);
	}
	else
	{
		//直接将原数据拷贝到目标数据
		memcpy(DecData, SrcData, Len);
	}

	pTmpDecData = DecData;
	//暂时测试，直接跟'Z'进行异或
	for(i = 0; i < Len; i++)
	{
		ch = *pTmpDecData;
		//和CtrlSequeue进行异或
		ch = ch ^ CtrlSequeue[i & 3];
		*pTmpDecData = (char)((ch ^ 'Z') - (i & 0x3F));
		pTmpDecData++;
	}
	return YES;
}


//示例加密一段字符如下:abcdefhijklmnopqrstuvwxyz123456789
void testEnExampleFun()
{
	//做加密之前一定要先初始化一下。
	if (!g_bInitTabs)
		g_bInitTabs = InitEncry();

	if (!g_bInitTabs)
		return;

	//如果密钥没有设置是不能加密的，否则会破坏加密的内容
	//另外不同的密码需要调用下面这个函数设置
	//这里密钥必须是16个字节，可能可见字也可能不见字符
	if (!g_bInitAes)
	{
		unsigned char unKey[17]={0};
		memcpy(unKey,"adlafsjlasdjfoik",16);
		SetKey128(unKey);
	}

	if (!g_bInitAes)
		return;

	char szSrc[100]={0};
	char szEnDst[100]={0};
	strcpy(szSrc,"abcdefhijklmnopqrstuvwxyz123456789");
	int iLen = strlen("abcdefhijklmnopqrstuvwxyz123456789");

	if (EncryData(szSrc, szEnDst, iLen,  CTRL_SEQUE_KEY))
	{
		//解一密，看一下和原来是否相同
		memset(szSrc,0,100);
		DecryData(szEnDst,szSrc,iLen,CTRL_SEQUE_KEY);
	}
}



#endif

