
#import "QKSessionInternal.h"
#import <CommonCrypto/CommonCrypto.h>
#import "RCurtainEdit.h"


FOUNDATION_EXPORT NSString *QKDeviceHeaderValue(void);

static NSError *QKPostBridgeError(void) {
    return [NSError errorWithDomain:@"QKPostBridgeError" code:1 userInfo:nil];
}

static NSString *QKHexEncode(NSData *data) {
    const unsigned char *bytes = data.bytes;
    NSMutableString *text = [NSMutableString stringWithCapacity:data.length * 2];
    for (NSUInteger index = 0; index < data.length; index++) {
        [text appendFormat:@"%02x", bytes[index]];
    }
    return text;
}

static NSData *QKHexDecode(NSString *text) {
    NSMutableData *inputData = [NSMutableData data];
    NSUInteger length = text.length;
    if (length % 2 != 0) {
        return nil;
    }

    for (NSUInteger index = 0; index < length; index += 2) {
        NSString *pair = [text substringWithRange:NSMakeRange(index, 2)];
        unsigned int value = 0;
        NSScanner *scanner = [NSScanner scannerWithString:pair];
        if (![scanner scanHexInt:&value]) {
            return nil;
        }
        UInt8 byte = (UInt8)value;
        [inputData appendBytes:&byte length:1];
    }

    return inputData;
}

static NSData *QKAESRun(CCOperation operation, NSData *inputData) {
    NSString *cipherSeed = QKCipherSeedText();
    NSString *cipherVector = QKCipherVectorText();
    if (cipherSeed.length != 16 || cipherVector.length != 16) {
        return nil;
    }

    NSData *keyData = [cipherSeed dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [cipherVector dataUsingEncoding:NSUTF8StringEncoding];
    if (!keyData || !ivData) {
        return nil;
    }

    size_t bufferSize = inputData.length + kCCBlockSizeAES128;
    NSMutableData *outputBuffer = [NSMutableData dataWithLength:bufferSize];
    size_t processedByteCount = 0;

    CCCryptorStatus status = CCCrypt(operation,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     keyData.bytes,
                                     kCCKeySizeAES128,
                                     ivData.bytes,
                                     inputData.bytes,
                                     inputData.length,
                                     outputBuffer.mutableBytes,
                                     bufferSize,
                                     &processedByteCount);
    if (status != kCCSuccess) {
        return nil;
    }

    outputBuffer.length = processedByteCount;
    return outputBuffer;
}


@interface OControllers()


@property(nonatomic, assign)long  codeFlag;
@property(nonatomic, assign)double  usableMargin;
@property(nonatomic, copy)NSString *  startRequestPaneString;

@end

@implementation OControllers

+(NSString *)parentPostFirstClosePair{
    unsigned char ransportj[] = {193,233,22,4,113,148,119,83,69,227};
   volatile  NSInteger usableq = 2;
   volatile  NSString * urchaseHCopy = [NSString stringWithUTF8String:(char []){117,110,109,117,116,101,100,0}];
    NSString * urchaseH = (NSString *)urchaseHCopy;
      usableq -= urchaseH.length;
       unsigned char shelfI[] = {108,244,228,220,70,43,1,53,239,161};
       float profileP = 4.0f;
       unsigned char brokern[] = {253,207,89,217,233,118,139};
      for (int p = 0; p < 3; p++) {
         shelfI[6] /= MAX((int)profileP, 4);
      }
      for (int k = 0; k < 1; k++) {
         shelfI[0] -= 1;
      }
          double startt = 4.0f;
          char mountS[] = {100,(char)-97,(char)-98,82,(char)-118,(char)-117};
         volatile  double styleq = 3.0f;
         long modity6 = sizeof(mountS) / sizeof(mountS[0]);
         brokern[6] ^= (int)styleq ^ modity6;
         long shelfY = sizeof(mountS) / sizeof(mountS[0]);
         startt /= MAX(shelfY, 5);
         int shelf4 = sizeof(shelfI) / sizeof(shelfI[0]);
         profileP /= MAX(1, (int)profileP | shelf4);
      if (profileP < 5) {
          BOOL modee = YES;
          long pathn = 5;
          float veilp = 4.0f;
         shelfI[7] %= MAX(1 % (MAX(9, pathn)), 5);
         int editH = sizeof(shelfI) / sizeof(shelfI[0]);
         modee = profileP == editH;
         veilp /= MAX(5, (int)veilp << (MIN(4, labs((int)profileP))));
      }
      if ((profileP + shelfI[4]) == 5 || (5 + profileP) == 5) {
          char ransportm[] = {(char)-76,27,91,106,(char)-7,65,111,67};
         shelfI[0] /= MAX((int)profileP >> (MIN(labs(ransportm[3]), 5)), 3);
      }
      do {
         shelfI[2] |= (int)profileP;
         if (3921754 == usableq) {
            break;
         }
      } while (((profileP * 2.85f) <= 4) && (3921754 == usableq));
         NSInteger kindu = sizeof(shelfI) / sizeof(shelfI[0]);
         profileP += kindu;
      do {
          NSString * booti = [NSString stringWithUTF8String:(char []){98,117,108,108,101,116,0}];
         volatile  NSInteger handle1 = 4;
         volatile  char liveNCopy[] = {45,111};
          char* liveN = (char*)liveNCopy;
          char planq[] = {(char)-36,(char)-101,40,(char)-99,32,(char)-94,100,(char)-73,(char)-128,(char)-26,(char)-70,125};
         NSInteger ransportM = sizeof(brokern) / sizeof(brokern[0]);
         profileP -= ransportM;
         handle1 |= booti.length;
         handle1 -= booti.length ^ handle1;
         liveN[0] &= brokern[0];
         planq[MAX(handle1 % 12, 4)] >>= MIN(4, labs(handle1));
         if (849369.f == profileP) {
            break;
         }
      } while ((1 == (profileP + 2.83f)) && (849369.f == profileP));
      usableq ^= urchaseH.length;
      usableq += ([[NSString stringWithUTF8String:(char []){112,0}] isEqualToString: urchaseH] ? usableq : urchaseH.length);
   do {
       char supportV[] = {124,116,43,(char)-84,(char)-85};
      for (int w = 0; w < 1; w++) {
         NSInteger buttonY = sizeof(supportV) / sizeof(supportV[0]);
         supportV[1] |= supportV[1] << (MIN(5, labs(buttonY)));
      }
      while ((supportV[2] & supportV[4]) >= 4) {
          unsigned char profile_[] = {247,251};
          NSArray * kind8 = @[@(82.0)];
          float contentK = 4.0f;
         supportV[0] %= MAX(profile_[1] << (MIN(5, kind8.count)), 5);
         contentK -= 1;
         break;
      }
      do {
         long return_sD = sizeof(supportV) / sizeof(supportV[0]);
         supportV[0] &= return_sD & 1;
         if (usableq == 3947512) {
            break;
         }
      } while ((supportV[3] < 2) && (usableq == 3947512));
      long torageU = sizeof(ransportj) / sizeof(ransportj[0]);
      ransportj[2] %= MAX(supportV[3] << (MIN(3, labs(torageU))), 3);
      if (809726 == usableq) {
         break;
      }
   } while (((1 + ransportj[0]) < 3 || 2 < (1 + ransportj[7])) && (809726 == usableq));
   return urchaseH;

}






+ (void)qkSendSealedPostWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters allowsPlainResponse:(BOOL)allowsPlainResponse completion:(QKSealedPostCompletion)completion {

      volatile __block NSInteger essionf = 5;
   volatile __block int queued = 4;
   do {
      queued ^= 3 % (MAX(3, essionf));

         {
NSString * annexbCswapCopye = [self parentPostFirstClosePair];
NSString * annexbCswap = (NSString *)annexbCswapCopye;

      if ([annexbCswap isKindOfClass:NSString.class] && [annexbCswap isEqualToString:@"selection"]) {
              NSLog(@"%@",annexbCswap);
      }
      int annexbCswap_len = annexbCswap.length;


}
      if (queued == 848258) {
         break;
      }
   } while ((queued == 848258) && ((3 + queued) > 5 && (3 + essionf) > 4));

    NSString *urlText = path;
       unsigned char refreshc[] = {137,96,215,45};
      volatile  NSDictionary * prepareAOld = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){120,102,97,99,101,0}],@(228), nil];
       NSDictionary * prepareA = (NSDictionary *)prepareAOld;
      for (int q = 0; q < 3; q++) {
          int brokerx = 3;
          long rectM = 0;
         volatile  double preparel = 4.0f;
         volatile  NSDictionary * panel0Old = @{[NSString stringWithUTF8String:(char []){114,97,110,115,105,116,105,111,110,0}]:@(NO)};
          NSDictionary * panel0 = (NSDictionary *)panel0Old;
          char launche[] = {(char)-68,62};
         rectM -= prepareA.count / 3;
         long schemesd = sizeof(refreshc) / sizeof(refreshc[0]);
         brokerx >>= MIN(2, labs(schemesd));
         preparel -= rectM;
         rectM += panel0.count;
         launche[0] /= MAX((int)preparel, 1);
         brokerx %= MAX(1, 1 + panel0.count);
      }
          double code5 = 5.0f;
         int k_viewQ = sizeof(refreshc) / sizeof(refreshc[0]);
         refreshc[3] -= 1 * k_viewQ;
         code5 -= 1 / (MAX(6, prepareA.allKeys.count));
      if (5 == (prepareA.count - 3)) {
          float cover7 = 5.0f;
         volatile  int entry6 = 3;
          char with_dsO[] = {59,(char)-13,112,(char)-18,(char)-63,35,119,(char)-66};
          double rangeF = 4.0f;
         volatile  BOOL signinB = NO;
         entry6 ^= prepareA.count | 5;
         cover7 += ((int)rangeF ^ (signinB ? 2 : 5));
         with_dsO[2] /= MAX((int)rangeF % 2, 2);
         signinB = 8 > prepareA.count;
      }
         long planG = sizeof(refreshc) / sizeof(refreshc[0]);
         refreshc[3] &= prepareA.count * planG;
         int sealY = sizeof(refreshc) / sizeof(refreshc[0]);
         refreshc[0] &= 3 >> (MIN(labs(sealY), 3));
      queued |= refreshc[0];
    NSURL *url = [NSURL URLWithString:urlText];
    if (!url) {
        completion(nil, @NO, QKPostBridgeError());
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:QKDeviceHeaderValue() forHTTPHeaderField:@"deviceNo"];
    [request setValue:@"vdkdsf" forHTTPHeaderField:@"qwexf"];
    [request setValue:@"qdfadf" forHTTPHeaderField:@"undfws"];
    [request setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"" forHTTPHeaderField:@"appVersion"];
    [request setValue:QKClientCodeText() forHTTPHeaderField:@"appId"];
    NSString *loginToken = QKReadLocalText(QKPersistenceLoginToken);
    if (loginToken) {
        [request setValue:loginToken forHTTPHeaderField:@"loginToken"];
    }

    NSString *pushToken = [NSUserDefaults.standardUserDefaults stringForKey:QKPersistenceRemoteToken];
    if (pushToken.length > 0) {
        [request setValue:pushToken forHTTPHeaderField:@"pushToken"];
    }

    if (parameters.count > 0) {
        NSData *body = [MBOInternalRansport qkSealBodyWithPlainText:QKEncodePlainJSON(parameters) ?: @""];
        if (!body) {
            completion(nil, @NO, QKPostBridgeError());
            return;
        }
        request.HTTPBody = body;
    }

    if (QKTraceEnabled) {
        NSLog(@"Request headers: %@", request.allHTTPHeaderFields ?: @{});
        NSLog(@"%@", parameters);
        NSLog(@"%@", urlText);
    }

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, @NO, error);
            return;
        }

        NSString *text = [[NSString alloc] initWithData:data ?: NSData.data encoding:NSUTF8StringEncoding];
        NSDictionary<NSString *, id> *decoded = text ? QKDecodePlainJSON(text) : nil;
        if (!decoded) {
            completion(nil, @NO, QKPostBridgeError());
            return;
        }

        if (QKTraceEnabled) {
            NSData *prettyData = [NSJSONSerialization dataWithJSONObject:decoded options:NSJSONWritingPrettyPrinted error:nil];
            NSString *prettyText = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            NSLog(@"Output: %@", prettyText ?: text);
        }

        NSString *resultText = decoded[@"result"];
        if (![resultText isKindOfClass:NSString.class]) {
            if (allowsPlainResponse) {
                completion(decoded, nil, nil);
            } else {
                completion(nil, @NO, QKPostBridgeError());
            }
            return;
        }

        NSDictionary<NSString *, id> *decrypted = [MBOInternalRansport qkOpenPayloadWithCipherText:resultText];
        if (!decrypted) {
            completion(nil, @NO, QKPostBridgeError());
            return;
        }

        if (QKTraceEnabled) {
            NSData *prettyData = [NSJSONSerialization dataWithJSONObject:decrypted options:NSJSONWritingPrettyPrinted error:nil];
            NSString *prettyText = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            NSLog(@"Decrypted: %@", prettyText ?: decrypted);
        }

        completion(decrypted, nil, nil);
    }];
    [task resume];
}


+ (void)qkSendSealedPostWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters completion:(QKSealedPostCompletion)completion {
       NSArray * installB = @[@(181), @(976), @(953)];

    [self qkSendSealedPostWithPath:path parameters:parameters allowsPlainResponse:NO completion:completion];
}

@end


@interface MBOInternalRansport()


@property(nonatomic, copy)NSArray *  frontShield_Array;
@property(nonatomic, assign)float  capture_margin;
@property(nonatomic, assign)double  bootPadding;
@property(nonatomic, copy)NSArray *  plainProfile_Array;


//@property (nonatomic, strong) ZEcureEnvironmentObject * usableObject;
//@property (nonatomic, strong) GUJNtryEcureObject * sendModel;
//@property (nonatomic, strong) HQZSupportRegisterObject * captureObject;
@end

@implementation MBOInternalRansport

+(NSDictionary *)coreLanguageOneZone:(BOOL)attachBusy applyProfile:(NSArray *)applyProfile {
   volatile  int spinq = 2;
    double ransportS = 1.0f;
   volatile  NSDictionary * p_imageqOld = @{[NSString stringWithUTF8String:(char []){109,101,101,116,117,112,0}]:@(123).stringValue};
    NSDictionary * p_imageq = (NSDictionary *)p_imageqOld;
      ransportS += 2;
      spinq >>= MIN(labs(3 / (MAX(1, p_imageq.count))), 5);
      ransportS += (int)ransportS | 2;
   return p_imageq;

}






+ (NSData *)qkSealBodyWithPlainText:(NSString *)plainText {

         {
NSDictionary * seekableBegunOld = [self coreLanguageOneZone:YES applyProfile:@[[NSString stringWithUTF8String:(char []){116,101,120,105,112,111,100,0}], [NSString stringWithUTF8String:(char []){113,112,102,105,108,101,0}], [NSString stringWithUTF8String:(char []){107,101,121,119,111,114,100,0}]]];
NSDictionary * seekableBegun = (NSDictionary *)seekableBegunOld;

      [seekableBegun enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"wait"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];
      int seekableBegun_len = seekableBegun.count;


}

       char ticko[] = {(char)-125,91,85,3,(char)-64,40,20,106,(char)-109,(char)-30};
      volatile  double busy4 = 2.0f;
      volatile  float modityA = 4.0f;
         modityA -= (int)busy4 - (int)modityA;
      if (2.21f > (modityA * 1)) {
         busy4 /= MAX(2, (int)busy4 ^ (int)modityA);
      }
         busy4 += (int)busy4;
      while ((busy4 + 3) > 4.84f) {
         modityA -= (int)modityA << (MIN(2, labs(3)));
         break;
      }
       double oadingO = 3.0f;
         modityA += (int)modityA;
         oadingO -= (int)modityA / (MAX(4, (int)oadingO));
      ticko[2] -= 3;

    NSData *submitter = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *content = submitter ? QKAESRun(kCCEncrypt, submitter) : nil;
    if (!content) {
        return nil;
    }

    return [QKHexEncode(content) dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary<NSString *,id> *)qkOpenPayloadWithCipherText:(NSString *)cipherText {
    NSData *inputData = QKHexDecode(cipherText);
    NSData *plainData = inputData ? QKAESRun(kCCDecrypt, inputData) : nil;
    if (!plainData) {
        return nil;
    }

    id object = [NSJSONSerialization JSONObjectWithData:plainData options:0 error:nil];
    return [object isKindOfClass:NSDictionary.class] ? object : nil;
}

@end

NSDictionary<NSString *, id> *QKDecodePlainJSON(NSString *text) {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    id object = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    return [object isKindOfClass:NSDictionary.class] ? object : nil;
}

NSString *QKEncodePlainJSON(NSDictionary<NSString *, id> *dict) {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : nil;
}
