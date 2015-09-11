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


//����128λ��Կ��16���ֽڣ�
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

//���ܺ���
//��ʼ���ӽ���ģ�飬��Ҫ�ǳ�ʼ���㷨
bool InitEncry()
{
	//��Կ
	unsigned int key[4] = {0x97239704, 0x02189645, 0x39148921, 0x29842862};
	//ʹ��aes
	aes_gen_tabs();

	//��ʱʹ�ù̶�128λ��Կ
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
	//��ʱ���ԣ�ֱ�Ӹ�'Z'�������
    for(i = 0; i < Len; i++)
    {
        ch = *pTmpSrcData;
        ch = (char)((ch + (i & 0x3F)) ^ 'Z');
        //��CtrlSequeue�������
        *pTmpEncData = ch ^ CtrlSequeue[i & 3];
        pTmpSrcData++;
        pTmpEncData++;
    }

	//����aes���ܣ������aes����ֻ��ҪĿ�����ݼ���
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
	unsigned long nLost;  //ʣ���û�м��ܵ�����

	//����aes����
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
		//����ʣ������
		memcpy(pTmpDecData, pTmpSrcData, nLost);
	}
	else
	{
		//ֱ�ӽ�ԭ���ݿ�����Ŀ������
		memcpy(DecData, SrcData, Len);
	}

	pTmpDecData = DecData;
	//��ʱ���ԣ�ֱ�Ӹ�'Z'�������
	for(i = 0; i < Len; i++)
	{
		ch = *pTmpDecData;
		//��CtrlSequeue�������
		ch = ch ^ CtrlSequeue[i & 3];
		*pTmpDecData = (char)((ch ^ 'Z') - (i & 0x3F));
		pTmpDecData++;
	}
	return YES;
}


//ʾ������һ���ַ�����:abcdefhijklmnopqrstuvwxyz123456789
void testEnExampleFun()
{
	//������֮ǰһ��Ҫ�ȳ�ʼ��һ�¡�
	if (!g_bInitTabs)
		g_bInitTabs = InitEncry();

	if (!g_bInitTabs)
		return;

	//�����Կû�������ǲ��ܼ��ܵģ�������ƻ����ܵ�����
	//���ⲻͬ��������Ҫ�������������������
	//������Կ������16���ֽڣ����ܿɼ���Ҳ���ܲ����ַ�
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
		//��һ�ܣ���һ�º�ԭ���Ƿ���ͬ
		memset(szSrc,0,100);
		DecryData(szEnDst,szSrc,iLen,CTRL_SEQUE_KEY);
	}
}



#endif

