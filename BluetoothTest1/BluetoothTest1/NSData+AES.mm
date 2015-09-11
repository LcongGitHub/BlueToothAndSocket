//
//  NSData+AES.m
//  BluetoothTest1
//
//  Created by 9377 on 15/9/2.
//  Copyright (c) 2015年 9377. All rights reserved.
//

#import "NSData+AES.h"
#include "Aes.h"

bool g_bInitTabs = false;
bool g_bInitAes = false;
struct aes_ctx  g_aes;
unsigned char g_aesKey[16];

@implementation NSData (AES)

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

bool InitEncry()
{
    //
    unsigned int key[4] = {0x97239704, 0x02189645, 0x39148921, 0x29842862};
    // 
    aes_gen_tabs();
    
    //
    if(aes_set_key(&g_aes, (u8*)key , KEY_LEN) != 0)
    {
        return false;
    }
    
    (g_aesKey, (u8*)key, KEY_LEN);
    
    return true;
}

unsigned char* EncryData(unsigned char* SrcData, unsigned char* EncData, unsigned long Len, char* CtrlSequeue)
{
    unsigned long i;
    unsigned char ch;
    unsigned char* pTmpSrcData = SrcData;
    unsigned char* pTmpEncData = EncData;

    for(i = 0; i < Len; i++)
    {
        ch = *pTmpSrcData;
        ch = (unsigned char)((ch + (i & 0x3F)) ^ 'Z');
        *pTmpEncData = ch ^ CtrlSequeue[i & 3];
        pTmpSrcData ++;
        pTmpEncData ++;
    }
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

    pTmpEncData = EncData;
    return pTmpEncData;
}

unsigned char * DecryData(unsigned char* SrcData, unsigned char* DecData, unsigned long Len, char* CtrlSequeue)
{
    unsigned long i;
    unsigned char ch;
    unsigned char* pTmpSrcData = SrcData;
    unsigned char* pTmpDecData = DecData;
    unsigned long nLost;  //

    //
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
        //
        memcpy(pTmpDecData, pTmpSrcData, nLost);
    }
    else
    {
        memcpy(DecData, SrcData, Len);
    }
    
    pTmpDecData = DecData;
    //
    for(i = 0; i < Len; i++)
    {
        ch = *pTmpDecData;
        //
        ch = ch ^ CtrlSequeue[i & 3];
        *pTmpDecData = (unsigned char)((ch ^ 'Z') - (i & 0x3F));
        pTmpDecData++;

    }
    pTmpDecData = DecData;
    
    return pTmpDecData;
}

- (NSData *)AESEncryptWithKey:(NSString *)key{
    
    if (!g_bInitTabs)
        g_bInitTabs = InitEncry();
    
    if (!g_bInitTabs)
        return nil;

   unsigned char *keySrc = (unsigned char *)[[key dataUsingEncoding:NSStringCode] bytes];
    
    if (!g_bInitAes) {
        unsigned char unKey[17]={0};
        memcpy(unKey,keySrc,16);
        SetKey128(unKey);
    }
    
    if (!g_bInitAes)
        return nil;
    
    unsigned char *szSrc = (unsigned char *)[self bytes];
    
    unsigned long iLen = self.length;

    unsigned char *szEnDst = new unsigned char[iLen];
    
    unsigned char *result = EncryData(szSrc, szEnDst, iLen, (char *)CTRL_SEQUE_KEY);
    g_bInitTabs = false;
    g_bInitAes = false;
    return [NSData dataWithBytes:result length:iLen];
}

- (NSData *)AESDecryptWithKey:(NSString *)key{
    
    unsigned char *keySrc = (unsigned char *)[[key dataUsingEncoding:NSStringCode] bytes];

    if (!g_bInitTabs)
        g_bInitTabs = InitEncry();
    
    if (!g_bInitTabs)
        return nil;
    
    if (!g_bInitAes)
    {
        unsigned char unKey[17]={0};
        memcpy(unKey,keySrc,16);
        SetKey128(unKey);
    }
    
    if (!g_bInitAes)
        return nil;
  
    unsigned char *szSrc = (unsigned char *)[self bytes];
    
    unsigned long iLen = self.length;
    unsigned char *szEnDst = new unsigned char[iLen];
    unsigned char *result = DecryData(szSrc,szEnDst ,iLen,(char *)CTRL_SEQUE_KEY);
    g_bInitTabs = false;
    g_bInitAes = false;
    return [NSData dataWithBytes:result length:iLen] ;
}

@end
