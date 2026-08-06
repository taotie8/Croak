
#import "OMessageMessageController.h"
#import "WYINetwork.h"
#import "LCMainCell.h"
#import "ONSNewsSession.h"
#import "Croak-Swift.h"
#import "SVProgressHUD.h"
#import "PFriendsSearchCell.h"


static NSString * const CroakDiamondsCellIdentifier = @"LCMainCell";
static NSString * const CroakDiamondsCellNibName = @"LCMainCell";

@interface OMessageMessageController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, assign)NSInteger  networkFlag;
@property(nonatomic, assign)NSInteger  field_flag;




@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_diamondsLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_diamonds;
@property (nonatomic, assign) BOOL croak_isPurchasing;

@end

@implementation OMessageMessageController

-(NSDictionary *)inputRequestLove:(NSDictionary *)imageTab {
   volatile  double envelopeM = 3.0f;
    NSString * handlel = [NSString stringWithUTF8String:(char []){104,114,116,102,0}];
    NSDictionary * edit_ = @{[NSString stringWithUTF8String:(char []){112,115,110,114,0}]:@(YES)};
   for (int t = 0; t < 3; t++) {
      envelopeM -= handlel.length - 1;
   }
   while (2 < (envelopeM * 3)) {
      envelopeM *= 3 ^ (int)envelopeM;
      break;
   }
   return edit_;

}






- (void)croak_purchaseProductIdentifier:(NSString *)productIdentifier fallbackAmount:(NSInteger)fallbackAmount {

      volatile __block long l_imageE = 0;
   for (int s = 0; s < 3; s++) {
       NSArray * return_byV = [NSArray arrayWithObjects:@(506), @(789), nil];
      volatile  double interfacee = 0.0f;
      volatile  double pricej = 2.0f;
         pricej /= MAX(return_byV.count, 1);

         {
NSDictionary * sqlPredictorsbCopyh = [self inputRequestLove:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){112,105,101,99,101,119,105,115,101,0}],@(353), [NSString stringWithUTF8String:(char []){99,100,102,116,0}],@(175).stringValue, nil]];
NSDictionary * sqlPredictorsb = (NSDictionary *)sqlPredictorsbCopyh;

      [sqlPredictorsb enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"square"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];
      int sqlPredictorsb_len = sqlPredictorsb.count;


}
         pricej -= 1 + return_byV.count;
      for (int u = 0; u < 1; u++) {
          NSString * emptyX = [NSString stringWithUTF8String:(char []){114,101,101,108,0}];
         interfacee /= MAX(1, 4);
         pricej -= emptyX.length + 3;
         interfacee /= MAX(emptyX.length, 5);
      }
      if (4 >= (return_byV.count / 4) || (interfacee - return_byV.count) >= 3.64f) {
         interfacee -= (int)pricej;
      }
          NSArray * sourceh = [NSArray arrayWithObjects:@(31), @(710), nil];
          char coinsb[] = {15,117,103,16,(char)-87,23};
         volatile  char modityDOld[] = {86,105,(char)-127,(char)-43,37,64,47,(char)-106};
          char* modityD = (char*)modityDOld;
         interfacee += (int)pricej;
         pricej -= sourceh.count / 4;
         int envelope2 = sizeof(coinsb) / sizeof(coinsb[0]);
         coinsb[2] ^= 3 & envelope2;
         modityD[4] |= return_byV.count % (MAX(10, coinsb[1]));
         interfacee /= MAX(sourceh.count, 4);
      do {
         interfacee /= MAX(return_byV.count, 5);
         if (return_byV.count == 1160950) {
            break;
         }
      } while ((return_byV.count >= pricej) && (return_byV.count == 1160950));
         pricej -= return_byV.count;
      while (2.74f <= (pricej - 2.96f)) {
         pricej /= MAX(1, 1);
         break;
      }
         pricej /= MAX(return_byV.count + 3, 5);
      l_imageE |= (int)interfacee;
   }

    NSString *agreement = [self croak_trimmedString:ONSNewsSession.croak_currentAccount];
    if (agreement.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    self.croak_isPurchasing = YES;
    [SVProgressHUD showWithStatus:@"Purchasing..."];
    [[CIVideoStore croak_sharedManager] croak_purchaseProductIdentifier:productIdentifier
                                                                              completion:^(GHome *purchaseResult, NSError *error) {
        if (error) {
            self.croak_isPurchasing = NO;
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        if (!purchaseResult) {
            self.croak_isPurchasing = NO;
            [SVProgressHUD dismiss];
            return;
        }

        NSInteger identifier = fallbackAmount;
        [SVProgressHUD showWithStatus:@"Saving..."];
        [[WYINetwork sharedStore] croak_addDiamonds:identifier
                                                    account:agreement
                                                 completion:^(NSDictionary<NSString *,id> *userInfo, NSError *saveError) {
            if (saveError) {
                self.croak_isPurchasing = NO;
                [SVProgressHUD showErrorWithStatus:saveError.localizedDescription];
                return;
            }

            [[CIVideoStore croak_sharedManager] croak_finishTransactionIdentifier:purchaseResult.croak_transactionIdentifier
                                                                                        completion:^(NSError *finishError) {
                self.croak_isPurchasing = NO;
                [self croak_updateDiamonds];
                if (finishError) {
                    [SVProgressHUD showErrorWithStatus:finishError.localizedDescription];
                    return;
                }
                [SVProgressHUD showSuccessWithStatus:@"Purchase successful."];
            }];
        }];
    }];
}

-(NSString *)sealTitleYearPrepare:(NSDictionary *)local_7wNews {
   volatile  int timeout0 = 0;
    NSArray * window_mob = @[@(170), @(400)];
   volatile  NSString * mine0Old = [NSString stringWithUTF8String:(char []){112,105,101,0}];
    NSString * mine0 = (NSString *)mine0Old;
   do {
      volatile  unsigned char morezOld[] = {55,206,104,195,229,70,102};
       unsigned char* morez = (unsigned char*)morezOld;
      volatile  float fetchG = 0.0f;
      volatile  NSArray * keyboardHOld = @[@(679), @(872)];
       NSArray * keyboardH = (NSArray *)keyboardHOld;
         volatile  char reportqCopy[] = {99,3};
          char* reportq = (char*)reportqCopy;
         volatile  unsigned char modity1Old[] = {230,243,145,139,149};
          unsigned char* modity1 = (unsigned char*)modity1Old;
          long timerg = 1;
         morez[4] -= morez[6] / 1;
         reportq[1] /= MAX(3, 3);
         modity1[4] *= timerg;
      if (3 < (morez[0] / (MAX(10, fetchG)))) {
         morez[3] += keyboardH.count << (MIN(labs(3), 3));
      }
          NSString * savingZ = [NSString stringWithUTF8String:(char []){115,116,114,116,111,105,110,116,0}];
         volatile  unsigned char notificationNOld[] = {244,244,151,149,208,113,202,56,16,1,218,176};
          unsigned char* notificationN = (unsigned char*)notificationNOld;
          float fieldd = 5.0f;
         fetchG += (int)fieldd;
         fieldd -= 1 - savingZ.length;
         long handlerh = sizeof(notificationN) / sizeof(notificationN[0]);
         notificationN[4] -= (int)fieldd >> (MIN(labs(handlerh), 1));
         fieldd += savingZ.length;
         volatile  NSDictionary * coinslOld = @{[NSString stringWithUTF8String:(char []){112,114,101,102,101,116,99,104,101,114,0}]:@(816).stringValue, [NSString stringWithUTF8String:(char []){98,101,103,117,110,0}]:@(964), [NSString stringWithUTF8String:(char []){110,111,114,109,97,108,105,115,101,0}]:@(753).stringValue};
          NSDictionary * coinsl = (NSDictionary *)coinslOld;
          double passwordn = 1.0f;
          int accessoryM = 2;
         morez[6] /= MAX(keyboardH.count << (MIN(1, labs((int)fetchG))), 1);
         accessoryM %= MAX(2 & coinsl.count, 1);
         passwordn -= morez[2];
         accessoryM &= 1 % (MAX(2, keyboardH.count));
         accessoryM += coinsl.count >> (MIN(labs(3), 3));
         volatile  double password_ = 1.0f;
         fetchG *= keyboardH.count;
         password_ /= MAX(5, morez[4] * (int)password_);
      for (int i = 0; i < 2; i++) {
          unsigned char delegate_wd[] = {113,83,47,253,243,27,19,252,194};
          NSInteger empty9 = 2;
          long messageh = 1;
         volatile  NSDictionary * listROld = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){98,101,104,97,118,105,111,117,114,0}],@(273).stringValue, [NSString stringWithUTF8String:(char []){102,101,101,100,98,97,99,107,0}],@(128), nil];
          NSDictionary * listR = (NSDictionary *)listROld;
          BOOL store8 = YES;
         morez[5] -= keyboardH.count;
         delegate_wd[0] -= 2;
         empty9 %= MAX(1, 3);
         messageh |= morez[0] + listR.count;
         empty9 %= MAX(listR.count, 4);
         store8 = 95 <= messageh;
      }
      for (int r = 0; r < 3; r++) {
         morez[3] <<= MIN(labs((int)fetchG), 3);
      }
         volatile  NSDictionary * listNCopy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){115,101,103,102,101,97,116,117,114,101,115,0}],@(891).stringValue, nil];
          NSDictionary * listN = (NSDictionary *)listNCopy;
          unsigned char draftD[] = {60,159,171,249,102,30,35};
          char textfiledK[] = {(char)-58,14,(char)-109,94,11,(char)-17,109,44};
         int changeO = sizeof(textfiledK) / sizeof(textfiledK[0]);
         fetchG /= MAX((int)fetchG + changeO, 1);
         fetchG += listN.count;
         draftD[3] /= MAX(4, 1);
         fetchG += listN.count;
      for (int i = 0; i < 2; i++) {
         fetchG += morez[3];
      }
      timeout0 /= MAX(window_mob.count, 2);
      if (window_mob.count == 1638210) {
         break;
      }
   } while ((mine0.length > window_mob.count) && (window_mob.count == 1638210));
   if (5 >= (5 >> (MIN(3, mine0.length)))) {
      timeout0 -= mine0.length;
   }
      timeout0 &= mine0.length;
   return mine0;

}






- (void)croak_loadDiamonds {

         {
NSString * translatedParentsOld = [self sealTitleYearPrepare:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){82,0}],[NSString stringWithUTF8String:(char []){85,0}], nil]];
NSString * translatedParents = (NSString *)translatedParentsOld;

      if ([translatedParents isKindOfClass:NSString.class] && [translatedParents isEqualToString:@"streak"]) {
              NSLog(@"%@",translatedParents);
      }
      int translatedParents_len = translatedParents.length;


}

      __strong NSDictionary * sharedq = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){114,101,103,105,115,116,101,114,101,114,0}],@[[NSString stringWithUTF8String:(char []){107,101,114,110,101,108,0}], [NSString stringWithUTF8String:(char []){115,101,108,101,99,116,105,118,101,0}]], nil];
   for (int d = 0; d < 1; d++) {
       char plaintextj[] = {119,(char)-24,(char)-47};
      for (int g = 0; g < 1; g++) {
          int bart = 4;
          NSDictionary * comments = @{[NSString stringWithUTF8String:(char []){104,117,103,103,105,110,103,0}]:@(208).stringValue, [NSString stringWithUTF8String:(char []){109,97,114,107,101,114,0}]:@(738).stringValue};
         volatile  char mine_Copy[] = {24,(char)-24,(char)-93,37,58,(char)-93};
          char* mine_ = (char*)mine_Copy;
          float croak4 = 5.0f;
          unsigned char noncej[] = {186,13,188,141,65,3,146,118};
         plaintextj[MAX(bart % 3, 2)] &= bart;
         bart += comments.count | 1;
         NSInteger header1 = sizeof(noncej) / sizeof(noncej[0]);
         mine_[0] &= header1 % (MAX(7, (int)croak4));
         croak4 += 1 & bart;
         bart += comments.count;
      }
      while (plaintextj[2] > 1) {
         int coinsi = sizeof(plaintextj) / sizeof(plaintextj[0]);
         plaintextj[0] += coinsi >> (MIN(labs(plaintextj[0]), 2));
         break;
      }
      while (plaintextj[0] >= 3) {
         long bodyA = sizeof(plaintextj) / sizeof(plaintextj[0]);
         plaintextj[1] += bodyA - plaintextj[2];
         break;
      }
   }

    if ([WYINetwork sharedStore].croak_isLoaded) {
        [self croak_updateDiamonds];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loading..."];
    [[WYINetwork sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_updateDiamonds];
    }];
}

-(NSDictionary *)selectionEnvelopeKeyCost:(float)tipStore {
   volatile  NSArray * croakGOld = @[@(815), @(348), @(150)];
    NSArray * croakG = (NSArray *)croakGOld;
   volatile  char edituOld[] = {(char)-16,78,(char)-101,(char)-126,43,66,3,(char)-75,2,(char)-115,(char)-97,19};
    char* editu = (char*)edituOld;
   volatile  NSDictionary * sealedJOld = @{[NSString stringWithUTF8String:(char []){118,97,108,0}]:@(102).stringValue, [NSString stringWithUTF8String:(char []){105,112,113,102,0}]:@(202)};
    NSDictionary * sealedJ = (NSDictionary *)sealedJOld;
       BOOL blackj = NO;
       long croakg = 0;
      volatile  double likem = 4.0f;
      do {
         croakg >>= MIN(4, labs(((blackj ? 5 : 2) + (int)likem)));
         if (2644370 == croakg) {
            break;
         }
      } while ((likem > 4.62f) && (2644370 == croakg));
         likem /= MAX(4, (int)likem / (MAX(2, croakg)));
      for (int f = 0; f < 2; f++) {
          NSInteger hasr = 0;
          NSDictionary * time_u7 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){112,111,105,110,116,99,98,98,0}],@(690), nil];
         volatile  unsigned char amountvCopy[] = {182,248,196,203,104,23,190,7,247};
          unsigned char* amountv = (unsigned char*)amountvCopy;
          long nonceE = 5;
         volatile  int identifiersi = 3;
         blackj = identifiersi > croakg;
         hasr |= 3;
         nonceE %= MAX(time_u7.count ^ 5, 2);
         amountv[MAX(identifiersi % 9, 2)] %= MAX(5, 3);
         long statusJ = sizeof(amountv) / sizeof(amountv[0]);
         nonceE ^= ((blackj ? 4 : 5) ^ statusJ);
         nonceE %= MAX(2, 1 - time_u7.count);
      }
         croakg |= croakg ^ 2;
         blackj = !blackj;
      do {
         blackj = 93 <= croakg && likem <= 39.75f;
         if (blackj ? !blackj : blackj) {
            break;
         }
      } while ((blackj ? !blackj : blackj) && ((croakg % 5) < 1 && croakg < 5));
       NSDictionary * constraint9 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){100,110,120,104,100,101,110,99,0}],@(271).stringValue, [NSString stringWithUTF8String:(char []){100,101,113,117,97,110,116,105,122,101,0}],@(921), [NSString stringWithUTF8String:(char []){114,101,115,111,108,118,101,114,115,0}],@(376), nil];
       NSDictionary * completei = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){98,114,117,116,101,102,111,114,99,101,0}],@(76), [NSString stringWithUTF8String:(char []){108,117,116,100,0}],@(241), [NSString stringWithUTF8String:(char []){99,104,97,110,103,101,0}],@(108).stringValue, nil];
      if ((croakg + 4) < 5 && croakg < 4) {
         blackj = 48 == likem || 48 == constraint9.count;
      }
         blackj = constraint9.allValues.count == 19;
         croakg %= MAX(completei.count % 4, 3);
         croakg += 5 * completei.count;
      croakg >>= MIN(1, sealedJ.count);
   if (5 < (editu[10] & 5)) {
      editu[3] &= 2;
   }
   while (croakG.count == croakG.count) {
      break;
   }
   return sealedJ;

}






- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

      volatile  float purchase2 = 3.0f;
   while ((5.61f + purchase2) >= 1.26f) {
       long time_o1 = 1;

         {
NSDictionary * playoutPeopleCopy = [self selectionEnvelopeKeyCost:77.0];
NSDictionary * playoutPeople = (NSDictionary *)playoutPeopleCopy;

      [playoutPeople enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"submit"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];
      int playoutPeople_len = playoutPeople.count;


}
      volatile  char placeholderzCopy[] = {(char)-19,(char)-90,(char)-29,38,(char)-108,(char)-18,93,(char)-45,(char)-95,4,61,119};
       char* placeholderz = (char*)placeholderzCopy;
       NSInteger timeoutV = 4;
      volatile  NSString * editFOld = [NSString stringWithUTF8String:(char []){114,117,110,116,105,109,101,0}];
       NSString * editF = (NSString *)editFOld;
       NSString * requests6 = [NSString stringWithUTF8String:(char []){108,111,97,100,101,100,0}];
      do {
         time_o1 ^= timeoutV / 3;
         if (time_o1 == 4552143) {
            break;
         }
      } while (((3 & time_o1) > 3 && (timeoutV & time_o1) > 3) && (time_o1 == 4552143));
         timeoutV += 1;
      if (timeoutV >= 2) {
         time_o1 &= requests6.length;
      }
      while (requests6.length <= 4) {
         placeholderz[MAX(time_o1 % 12, 7)] >>= MIN(labs(time_o1 % (MAX(3, 4))), 4);
         break;
      }
      while (editF.length >= 5) {
          unsigned char productt[] = {226,85,237,248};
          NSDictionary * postL = @{[NSString stringWithUTF8String:(char []){116,114,97,110,115,99,116,105,111,110,0}]:@(31)};
          long postI = 3;
          unsigned char restoreY[] = {239,57,14,227,50,44,27,42,231,222};
          char logoutL[] = {20,126,56,76,60};
         timeoutV %= MAX(1, requests6.length - 1);
         productt[MAX(timeoutV % 4, 3)] += ([requests6 isEqualToString: [NSString stringWithUTF8String:(char []){87,0}]] ? requests6.length : timeoutV);
         timeoutV %= MAX(postL.count, 2);
         postI >>= MIN(labs(editF.length % (MAX(7, time_o1))), 2);
         int secondsz = sizeof(placeholderz) / sizeof(placeholderz[0]);
         restoreY[2] -= (2 + secondsz) % (MAX(3, productt[0]));
         logoutL[0] >>= MIN(1, labs(restoreY[2]));
         postI |= 4 | postL.count;
         break;
      }
         time_o1 |= requests6.length & 2;
      for (int z = 0; z < 3; z++) {
          BOOL tick4 = YES;
          int purchasingA = 0;
         time_o1 -= purchasingA;
         tick4 = editF.length >= 52;
      }
         volatile  int sessioni = 4;
          double permissionf = 3.0f;
         volatile  unsigned char sharedoCopy[] = {47,80};
          unsigned char* sharedo = (unsigned char*)sharedoCopy;
         timeoutV |= editF.length;
         sessioni %= MAX(3, timeoutV / 1);
         permissionf += 1 - sessioni;
         sharedo[MAX(0, time_o1 % 2)] &= time_o1 >> (MIN(labs(2), 3));
      purchase2 -= time_o1;
      break;
   }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.croak_diamonds.count || self.croak_isPurchasing) {
        return;
    }

    NSDictionary<NSString *, id> *diamondsInfo = self.croak_diamonds[indexPath.row];
    NSString *tip = [self croak_trimmedString:diamondsInfo[@"productId"]];
    if (tip.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Product is not available."];
        return;
    }

    [self croak_purchaseProductIdentifier:tip
                          fallbackAmount:[[self croak_trimmedString:diamondsInfo[@"amount"]] integerValue]];
}

-(UIScrollView *)intersectInsideSquareSetupScrollView:(NSArray *)timerBox resultLoaded:(NSDictionary *)resultLoaded {
    unsigned char callb[] = {84,52,237,239,102,55,118,207,37};
   volatile  double sharedB = 2.0f;
   if (3 > (4 + callb[1]) && 4 > (callb[1] - sharedB)) {
      sharedB += (int)sharedB ^ 1;
   }
      sharedB -= (int)sharedB % (MAX(2, 3));
     UIImageView * dismissalResult = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithUTF8String:(char []){102,97,110,116,111,109,0}]]];
     NSString * diamondsEnabled = [NSString stringWithUTF8String:(char []){100,99,97,97,100,112,99,109,0}];
     int pageMain = 99;
    UIScrollView * cosignatoryGreatestUtil = [[UIScrollView alloc] init];
    cosignatoryGreatestUtil.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0];
    cosignatoryGreatestUtil.alwaysBounceVertical = YES;
    cosignatoryGreatestUtil.alwaysBounceHorizontal = YES;
    cosignatoryGreatestUtil.showsVerticalScrollIndicator = NO;
    cosignatoryGreatestUtil.showsHorizontalScrollIndicator = YES;
    cosignatoryGreatestUtil.delegate = nil;
    cosignatoryGreatestUtil.alpha = 0.7;
    cosignatoryGreatestUtil.backgroundColor = [UIColor colorWithRed:189 / 255.0 green:208 / 255.0 blue:173 / 255.0 alpha:0.1];
    cosignatoryGreatestUtil.frame = CGRectMake(300, 296, 0, 0);
    dismissalResult.frame = CGRectMake(115, 52, 0, 0);
    dismissalResult.alpha = 0.2;
    dismissalResult.backgroundColor = [UIColor colorWithRed:21 / 255.0 green:161 / 255.0 blue:209 / 255.0 alpha:0.8];
    dismissalResult.animationRepeatCount = 5;
    dismissalResult.image = [UIImage imageNamed:[NSString stringWithUTF8String:(char []){115,97,118,105,110,103,0}]];
    dismissalResult.contentMode = UIViewContentModeScaleAspectFit;
    
    [cosignatoryGreatestUtil addSubview:dismissalResult];

    
    return cosignatoryGreatestUtil;

}






- (NSString *)croak_trimmedString:(id)value {

         {
UIScrollView * gdspEvtagOld = [self intersectInsideSquareSetupScrollView:@[@(42)] resultLoaded:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){117,110,119,114,97,112,0}],@(684), [NSString stringWithUTF8String:(char []){119,104,101,101,108,0}],@(376).stringValue, nil]];
UIScrollView * gdspEvtag = (UIScrollView *)gdspEvtagOld;

      int gdspEvtag_tag = gdspEvtag.tag;
      [self.view addSubview: gdspEvtag];


}

      volatile  char completeoCopy[] = {(char)-39,(char)-99,(char)-80};
    char* completeo = (char*)completeoCopy;
       int agen = 5;
       unsigned char camerao[] = {252,168,8,201,102,26,238,190,140,226,245,166};
      if ((agen & camerao[5]) >= 2) {
         camerao[MAX(11, agen % 12)] |= 2;
      }
         camerao[11] /= MAX(agen << (MIN(labs(camerao[5]), 3)), 2);
      do {
         agen ^= agen / (MAX(3, 8));
         if (agen == 4209837) {
            break;
         }
      } while ((agen == 4209837) && ((camerao[4] & 5) > 4 && 3 > (5 & agen)));
      do {
         agen %= MAX(5, agen << (MIN(labs(camerao[7]), 3)));
         if (4400901 == agen) {
            break;
         }
      } while ((4400901 == agen) && (5 <= (agen * 3) || 3 <= (agen * camerao[8])));
      if (agen > 3) {
          BOOL profile9 = NO;
          char taskC[] = {110,125,(char)-45,(char)-57,39,(char)-118,62,(char)-63,(char)-86,(char)-112,(char)-128};
         volatile  NSInteger textfiledH = 0;
          double submitk = 4.0f;
         camerao[MAX(9, textfiledH % 12)] >>= MIN(labs(textfiledH >> (MIN(3, labs(1)))), 5);
         profile9 = (taskC[0] % (MAX(1, camerao[8]))) < 25;
         taskC[MAX(textfiledH % 11, 8)] /= MAX(textfiledH, 2);
         submitk /= MAX(2 | agen, 2);
      }
         agen >>= MIN(2, labs(agen));
      long emailT = sizeof(completeo) / sizeof(completeo[0]);
      completeo[1] += (2 + emailT) / (MAX(camerao[2], 10));

    if ([value isKindOfClass:NSString.class]) {
        return [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [[value stringValue] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    return @"";
}

-(NSInteger)awakeNoneSynchronize:(NSInteger)randomEnabled {
   volatile  long requestk = 3;
    unsigned char notificationn[] = {49,216,45,82,30,66,23,55,133};
    NSInteger text3 = 2;
      text3 -= 1;
   if (2 > (requestk >> (MIN(labs(4), 2))) && 4 > (4 >> (MIN(4, labs(requestk))))) {
      long h_widtht = sizeof(notificationn) / sizeof(notificationn[0]);
      requestk ^= 1 & h_widtht;
   }
      requestk |= text3 % (MAX(3, 7));
   return text3;

}






- (void)croak_updateDiamonds {

         {
NSInteger dxtysW_70 = [self awakeNoneSynchronize:46];

      for(int i = 0; i < dxtysW_70; i++) {
          if (i == 2) {
              break;
          }
      }


}

       char local_b9w[] = {119,42,46};
   while ((4 >> (MIN(4, labs(local_b9w[0])))) <= 3 && (local_b9w[0] >> (MIN(labs(4), 5))) <= 4) {
       int sealedO = 2;
      while (sealedO >= 5) {
          NSDictionary * t_positionn = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){102,114,97,109,101,104,97,115,104,0}],@(768).stringValue, [NSString stringWithUTF8String:(char []){99,111,100,101,98,108,111,99,107,115,0}],@(775), [NSString stringWithUTF8String:(char []){101,120,116,101,110,115,105,111,110,115,0}],@(576).stringValue, nil];
          NSInteger turnq = 0;
         volatile  char pathHCopy[] = {(char)-115,104,60,58,(char)-24,4,(char)-41,50,107};
          char* pathH = (char*)pathHCopy;
         volatile  BOOL callX = NO;
         volatile  unsigned char loadedZCopy[] = {65,128,244,115,174};
          unsigned char* loadedZ = (unsigned char*)loadedZCopy;
         sealedO &= loadedZ[1] << (MIN(2, labs(sealedO)));
         turnq /= MAX(t_positionn.count % 2, 1);
         turnq |= turnq;
         pathH[1] += 1 << (MIN(4, labs(turnq)));
         callX = t_positionn[@(callX).stringValue] == nil;
         break;
      }
      for (int n = 0; n < 1; n++) {
         sealedO >>= MIN(1, labs(sealedO));
      }
      if ((sealedO >> (MIN(labs(1), 5))) > 4 || (1 >> (MIN(4, labs(sealedO)))) > 3) {
         volatile  NSArray * chatqCopy = [NSArray arrayWithObjects:@(927), @(27), nil];
          NSArray * chatq = (NSArray *)chatqCopy;
          NSDictionary * selectedB = @{[NSString stringWithUTF8String:(char []){97,114,98,105,116,101,114,0}]:@(218).stringValue};
          NSArray * policyn = @[[NSString stringWithUTF8String:(char []){109,118,101,99,0}], [NSString stringWithUTF8String:(char []){105,109,109,117,116,97,98,108,101,0}], [NSString stringWithUTF8String:(char []){119,105,110,100,111,119,105,110,103,0}]];
          NSArray * scrollZ = [NSArray arrayWithObjects:@(620), @(83), @(903), nil];
         sealedO >>= MIN(labs(1 + chatq.count), 3);
         sealedO += selectedB.count * 1;
         sealedO += 1 << (MIN(1, policyn.count));
         sealedO /= MAX(4, 4 + scrollZ.count);
         sealedO /= MAX(3, selectedB.count);
         sealedO |= policyn.count;
         sealedO /= MAX(scrollZ.count & 1, 2);
      }
      local_b9w[2] |= 3 * sealedO;
      break;
   }

    NSDictionary<NSString *, id> *userInfo = [[WYINetwork sharedStore] croak_currentUserInfo];
    NSString *identifierv = [self croak_trimmedString:userInfo[@"yin"]];
    self.croak_diamondsLabel.text = identifierv.length > 0 ? identifierv : @"0";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

       NSDictionary * infoS = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){114,101,115,105,100,117,101,0}],@(83), nil];
       NSArray * unblockS = [NSArray arrayWithObjects:@(100), nil];
      volatile  char plaintextWOld[] = {74,(char)-83,122,47,24,42,47,(char)-46,(char)-61,84,(char)-32};
       char* plaintextW = (char*)plaintextWOld;
          NSDictionary * insufficientN = @{[NSString stringWithUTF8String:(char []){112,114,101,102,105,120,101,100,0}]:@(429).stringValue, [NSString stringWithUTF8String:(char []){116,109,105,120,0}]:@(169).stringValue, [NSString stringWithUTF8String:(char []){117,105,110,116,98,101,0}]:@(976)};
          double searchD = 5.0f;
         volatile  char shouldhOld[] = {46,54,(char)-125,59,(char)-16,67,97,65,(char)-83};
          char* shouldh = (char*)shouldhOld;
         plaintextW[7] |= shouldh[1] ^ 3;
         searchD /= MAX(5, 1 * insufficientN.count);
         searchD /= MAX(1, unblockS.count * shouldh[7]);
         searchD -= insufficientN.count;
      do {
         if (1257289 == unblockS.count) {
            break;
         }
      } while ((1257289 == unblockS.count) && ((unblockS.count - plaintextW[7]) >= 2));
      do {
         if (3162108 == unblockS.count) {
            break;
         }
      } while ((3162108 == unblockS.count) && ((unblockS.count + plaintextW[10]) <= 5 || 5 <= (unblockS.count + plaintextW[10])));
         volatile  int square2 = 2;
         int sendX = sizeof(plaintextW) / sizeof(plaintextW[0]);
         plaintextW[4] ^= sendX;
         square2 &= 2;
      while (3 <= (unblockS.count ^ plaintextW[2]) || 5 <= (unblockS.count ^ 3)) {
         plaintextW[7] += 1 / (MAX(6, unblockS.count));
         break;
      }
      while ((4 + unblockS.count) >= 4) {
         plaintextW[3] %= MAX(2 * unblockS.count, 5);
         break;
      }

    return self.croak_diamonds.count;
}


- (void)viewDidLoad {
       float fetchk = 3.0f;
      fetchk /= MAX((int)fetchk, 3);

    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Diamonds";
    self.croak_headerImageView.image = [UIImage imageNamed:@"countPurchasePost"];
    self.croak_diamondsLabel.text = @"0";

    self.croak_diamonds = @[
        @{@"amount": @"50", @"price": @"$0.99", @"productId": @"uckpsjjkeafvnzsr"},
        @{@"amount": @"110", @"price": @"$1.99", @"productId": @"wfppvhdtwxkpucnu"},
        @{@"amount": @"300", @"price": @"$4.99", @"productId": @"jtbodclawvdrrkzq"},
        @{@"amount": @"650", @"price": @"$9.99", @"productId": @"zvwuvnsfwxjutwkl"},
        @{@"amount": @"1400", @"price": @"$19.99", @"productId": @"hzlqlfftsnomymai"},
        @{@"amount": @"2150", @"price": @"$29.99", @"productId": @"fkwpznqvhdxjrlme"},
        @{@"amount": @"3800", @"price": @"$49.99", @"productId": @"gjgdmzzfmgwllrqh"},
        @{@"amount": @"5600", @"price": @"$69.99", @"productId": @"qmxkzvptlhrwajdc"},
        @{@"amount": @"8000", @"price": @"$99.99", @"productId": @"ymzqfwyqwqfpbmlv"}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakDiamondsCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakDiamondsCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 60.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
    [self croak_loadStoreProducts];
}


- (NSArray<NSString *> *)croak_productIdentifiers {

      volatile  double comment7 = 1.0f;
   for (int q = 0; q < 3; q++) {
       unsigned char audioS[] = {35,169};
       char begin_[] = {95,(char)-63,40,9,13};
       int barH = 1;
      volatile  char p_objectrOld[] = {(char)-119,(char)-58,(char)-97};
       char* p_objectr = (char*)p_objectrOld;
      volatile  int messagej = 0;
       NSInteger requestm = 4;
      volatile  NSInteger taskW = 3;
      while ((taskW * messagej) <= 3) {
         long encryptions = sizeof(begin_) / sizeof(begin_[0]);
         taskW /= MAX(p_objectr[1] >> (MIN(4, labs((1 + encryptions)))), 3);
         break;
      }
      volatile  unsigned char streakMOld[] = {42,225};
       unsigned char* streakM = (unsigned char*)streakMOld;
          char input4[] = {(char)-45,(char)-111,41,(char)-126,(char)-37,(char)-16,26,(char)-8};
          char transactionsR[] = {25,68,74,107,55,49,66,98,36,(char)-127,113};
         taskW %= MAX(1, 2);
         long love5 = sizeof(p_objectr) / sizeof(p_objectr[0]);
         input4[7] += (2 + love5) - begin_[1];
         transactionsR[4] /= MAX(5, 3);
          char emailT[] = {39,(char)-71,44,(char)-35,79,84,32,115,(char)-72,54,(char)-53};
         long viewsL = sizeof(p_objectr) / sizeof(p_objectr[0]);
         begin_[2] ^= viewsL + begin_[0];
         emailT[5] &= 3 / (MAX(8, messagej));
      volatile  BOOL randomo = YES;
      volatile  BOOL otherp = YES;
      for (int w = 0; w < 2; w++) {
          float names = 0.0f;
         streakM[1] -= ((otherp ? 5 : 4) & 1);
         names += 2;
      }
      for (int p = 0; p < 3; p++) {
         taskW &= barH | 1;
      }
          int unblockZ = 1;
         requestm -= unblockZ;
      if (3 < p_objectr[0] && randomo) {
         randomo = (barH - audioS[1]) == 87;
      }
         volatile  unsigned char u_centerECopy[] = {244,42,167,170,232,166,255};
          unsigned char* u_centerE = (unsigned char*)u_centerECopy;
          NSDictionary * background0 = @{[NSString stringWithUTF8String:(char []){115,121,109,108,105,110,107,0}]:@(47.0)};
         messagej /= MAX(3, 3);
         u_centerE[5] |= audioS[0];
         taskW /= MAX(background0.count + 2, 1);
         requestm |= background0.count;
      if ((barH | messagej) < 2) {
         NSInteger birthO = sizeof(begin_) / sizeof(begin_[0]);
         messagej -= birthO;
      }
      for (int j = 0; j < 1; j++) {
         volatile  NSDictionary * delegate_nRCopy = @{[NSString stringWithUTF8String:(char []){115,117,98,109,111,100,101,108,0}]:@(179).stringValue};
          NSDictionary * delegate_nR = (NSDictionary *)delegate_nRCopy;
          char directoryu[] = {(char)-5,94,(char)-55,87};
         messagej >>= MIN(labs(1), 3);
         taskW %= MAX(delegate_nR.count, 5);
         directoryu[1] %= MAX(barH, 2);
         messagej ^= delegate_nR.count << (MIN(labs(1), 3));
      }
      while (otherp && !randomo) {
          NSDictionary * callo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){109,101,109,110,0}],[NSString stringWithUTF8String:(char []){98,101,114,114,105,101,115,0}], nil];
         volatile  float delegate_pz = 5.0f;
         randomo = (messagej | streakM[1]) <= 57;
         taskW /= MAX(1, callo.count);
         delegate_pz /= MAX(streakM[0], 4);
         requestm ^= callo.count;
         break;
      }
          int screenr = 5;
          double settingc = 0.0f;
         NSInteger streakV = sizeof(streakM) / sizeof(streakM[0]);
         messagej >>= MIN(2, labs(p_objectr[1] & (2 + streakV)));
         screenr /= MAX(2, requestm & 1);
         settingc -= ((otherp ? 5 : 4));
      comment7 += 2;
   }

    NSMutableArray<NSString *> *productIdentifiers = [NSMutableArray arrayWithCapacity:self.croak_diamonds.count];
    for (NSDictionary<NSString *, id> *diamondsInfo in self.croak_diamonds) {
        NSString *tip0 = [self croak_trimmedString:diamondsInfo[@"productId"]];
        if (tip0.length > 0) {
            [productIdentifiers addObject:tip0];
        }
    }
    return productIdentifiers;
}


- (IBAction)croak_backAction:(id)sender {

       int insufficientH = 3;
    double fetche = 2.0f;
      insufficientH >>= MIN(5, labs(insufficientH >> (MIN(labs((int)fetche), 3))));
   do {
      fetche /= MAX(5, (int)fetche);
      if (fetche == 1288282.f) {
         break;
      }
   } while ((2.11f < (fetche / (MAX(2.43f, 5)))) && (fetche == 1288282.f));

    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(UITableView *)oldLessInsideSetTableView{
    char errorP[] = {(char)-53,(char)-15,59,127,117};
   volatile  char infoKCopy[] = {118,1,(char)-20,(char)-85};
    char* infoK = (char*)infoKCopy;
   for (int n = 0; n < 3; n++) {
      long purchasingT = sizeof(errorP) / sizeof(errorP[0]);
      long perform8 = sizeof(infoK) / sizeof(infoK[0]);
      infoK[0] += purchasingT ^ perform8;
   }
       unsigned char textC[] = {151,132,74,164,241};
         long stringO = sizeof(textC) / sizeof(textC[0]);
         textC[2] |= textC[2] * (2 + stringO);
         int willf = sizeof(textC) / sizeof(textC[0]);
         textC[2] -= willf;
      if ((textC[3] * textC[1]) > 3) {
         volatile  char agreementKCopy[] = {(char)-10,(char)-125,31,(char)-17,122,126,(char)-81,(char)-30,(char)-95,(char)-115,(char)-8,51};
          char* agreementK = (char*)agreementKCopy;
         int b_tagi = sizeof(agreementK) / sizeof(agreementK[0]);
         int fillo = sizeof(textC) / sizeof(textC[0]);
         textC[4] ^= b_tagi % (MAX(fillo, 8));
      }
      long minet = sizeof(textC) / sizeof(textC[0]);
      infoK[2] -= errorP[4] | (3 + minet);
     int loginPlaintext = 27;
     UIView * nonceConfirm = [[UIView alloc] initWithFrame:CGRectMake(126, 369, 0, 0)];
     NSInteger update_c1Plaintext = 95;
    UITableView * evdnsPick = [UITableView new];
    evdnsPick.delegate = nil;
    evdnsPick.dataSource = nil;
    evdnsPick.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0];
    evdnsPick.alpha = 0.2;
    evdnsPick.backgroundColor = [UIColor colorWithRed:235 / 255.0 green:24 / 255.0 blue:249 / 255.0 alpha:0.4];
    evdnsPick.frame = CGRectMake(249, 17, 0, 0);
    nonceConfirm.backgroundColor = [UIColor colorWithRed:33 / 255.0 green:218 / 255.0 blue:169 / 255.0 alpha:0.1];
    nonceConfirm.alpha = 0.4;
    nonceConfirm.frame = CGRectMake(212, 100, 0, 0);
    

    

    return evdnsPick;

}






- (void)viewWillAppear:(BOOL)animated {

       double successp = 3.0f;
   for (int c = 0; c < 2; c++) {
      successp *= (int)successp;

         {
UITableView * enchIndexingOldh = [self oldLessInsideSetTableView];
UITableView * enchIndexing = (UITableView *)enchIndexingOldh;

      [self.view addSubview: enchIndexing];
      int enchIndexing_tag = enchIndexing.tag;


}
   }

   self.networkFlag = 10;

   self.field_flag = 42;

   self.hasSessions = NO;

   self.friend_aj = 68.0;

   self.welcome_sum = 97;

   self.current_padding = 59.0;

    [super viewWillAppear:animated];
    [self croak_loadDiamonds];
}

-(NSArray *)clearWillActive:(NSArray *)interval_gzPublish {
   volatile  char loadingwOld[] = {(char)-103,71,53};
    char* loadingw = (char*)loadingwOld;
   volatile  NSInteger emailN = 5;
   volatile  NSArray * datalCopy = [NSArray arrayWithObjects:[NSString stringWithUTF8String:(char []){99,111,108,111,110,0}], [NSString stringWithUTF8String:(char []){103,101,116,115,105,103,99,116,120,110,111,0}], [NSString stringWithUTF8String:(char []){105,110,116,101,114,118,97,108,0}], nil];
    NSArray * datal = (NSArray *)datalCopy;
   for (int z = 0; z < 2; z++) {
       NSString * otherW = [NSString stringWithUTF8String:(char []){97,118,118,115,0}];
       char openF[] = {(char)-34,41,65,109,(char)-63,116,57,(char)-14,(char)-38,69,(char)-45};
         openF[2] %= MAX(1, 2);
       unsigned char coinsR[] = {222,139,131,237,30,245,59,34,9,37,23,202};
      volatile  NSArray * inputcOld = [NSArray arrayWithObjects:@(573), @(159), @(437), nil];
       NSArray * inputc = (NSArray *)inputcOld;
       double findE = 2.0f;
      for (int k = 0; k < 1; k++) {
         openF[6] -= inputc.count << (MIN(5, labs((int)findE)));
      }
         NSInteger body9 = sizeof(openF) / sizeof(openF[0]);
         coinsR[9] += body9;
      emailN += datal.count;
      emailN |= otherW.length;
      emailN %= MAX(5, otherW.length);
   }
   do {
      emailN &= 3 * datal.count;
      if (2798908 == datal.count) {
         break;
      }
   } while ((emailN < 4) && (2798908 == datal.count));
   for (int x = 0; x < 1; x++) {
      emailN /= MAX(1, emailN & datal.count);
   }
   while (1 >= (4 / (MAX(2, loadingw[0]))) || (loadingw[2] / 4) >= 3) {
      long keyt = sizeof(loadingw) / sizeof(loadingw[0]);
      loadingw[2] += keyt / 1;
      break;
   }
   return datal;

}






- (void)croak_loadStoreProducts {

      __block long originalx = 4;
   __block float cachev = 5.0f;
   while (2.41f <= (originalx - cachev)) {
      cachev -= 2 - (int)cachev;

         {
NSArray * rtcwebToggledOld = [self clearWillActive:@[@(73)]];
NSArray * rtcwebToggled = (NSArray *)rtcwebToggledOld;

      [rtcwebToggled enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (idx != 86) {
              NSLog(@"camera:%@", obj);
        }
      }];
      int rtcwebToggled_len = rtcwebToggled.count;


}
      break;
   }

    [[CIVideoStore croak_sharedManager] croak_fetchProductIdentifiers:[self croak_productIdentifiers]
                                                                            completion:^(NSArray<XTBSetting *> *products, NSError *error) {
        if (error || products.count == 0) {
            return;
        }

        NSMutableDictionary<NSString *, XTBSetting *> *productsByIdentifier = [NSMutableDictionary dictionary];
        for (XTBSetting *product in products) {
            if (product.croak_productIdentifier.length > 0) {
                productsByIdentifier[product.croak_productIdentifier] = product;
            }
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *updatedDiamonds = [NSMutableArray arrayWithCapacity:self.croak_diamonds.count];
        for (NSDictionary<NSString *, id> *diamondsInfo in self.croak_diamonds) {
            NSMutableDictionary<NSString *, id> *updatedInfo = [diamondsInfo mutableCopy];
      cachev -= originalx + (int)cachev;
            NSString *tip0M = [self croak_trimmedString:diamondsInfo[@"productId"]];
            XTBSetting *mine = productsByIdentifier[tip0M];
            if (mine.croak_displayPrice.length > 0) {
                updatedInfo[@"price"] = mine.croak_displayPrice;
            }
            [updatedDiamonds addObject:updatedInfo];
        }

        self.croak_diamonds = updatedDiamonds;
        [self.croak_tableView reloadData];
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

      volatile  int publish9 = 0;
   while (1 <= publish9) {
      publish9 ^= publish9;
      break;
   }

    LCMainCell *secondsCell = [tableView dequeueReusableCellWithIdentifier:CroakDiamondsCellIdentifier];
    if (!secondsCell) {
        secondsCell = [[NSBundle mainBundle] loadNibNamed:CroakDiamondsCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, id> *diamondsInfo = self.croak_diamonds[indexPath.row];
    [secondsCell croak_configureWithAmount:[self croak_trimmedString:diamondsInfo[@"amount"]]
                               price:[self croak_trimmedString:diamondsInfo[@"price"]]];
    return secondsCell;
}

@end
