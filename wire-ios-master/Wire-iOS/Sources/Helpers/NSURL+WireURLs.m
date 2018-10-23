// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 

#import "NSURL+WireURLs.h"

@implementation NSURL (WireURLs)

+ (instancetype)wr_fingerprintLearnMoreURL
{
    return [self URLWithString:@"https://chatbox.tech/privacy/why"];
}

//我该怎么办
+ (instancetype)wr_fingerprintHowToVerifyURL
{
    return [self URLWithString:@"http://chatbox.tech/how.html"];
}

//使用条款
+ (instancetype)wr_termsOfServicesURLForTeamAccount:(BOOL)teamAccount
{
    
    
     return [self URLWithString:@"http://chatbox.tech/clause.html"];
    
//    if (teamAccount) {
//        return [self URLWithString:@"https://wire.com/legal/terms/teams"];
//    } else {
//        return [self URLWithString:@"https://wire.com/legal/terms/personal"];
//    }
}
//隐私政策
+ (instancetype)wr_privacyPolicyURL
{
    return [self URLWithString:@"http://chatbox.tech/policy.html"];
}

//授权资讯
+ (instancetype)wr_licenseInformationURL
{
    return [self URLWithString:@"http://chatbox.tech/authorization.html"];
}

//Secret官网
+ (instancetype)wr_websiteURL
{
    return [self URLWithString:@"https://chatbox.tech"];
}

//更新密码
+ (instancetype)wr_passwordResetURL
{
    return [self URLWithString:@"http://chatbox.tech/reset_password.html"];
}


//secret帮助
+ (instancetype)wr_supportURL
{
    
    
    return [self URLWithString:@"http://chatbox.tech/help.html"];
}

+ (instancetype)wr_askSupportURL
{
    return [self URLWithString:@"http://chatbox.tech/service.html"];
}

//滥用报告
+ (instancetype)wr_reportAbuseURL
{
    return [self URLWithString:@"http://chatbox.tech/misuse.html"];
}

+ (instancetype)wr_cannotDecryptHelpURL
{
    return [self URLWithString:@"https://chatbox.tech/privacy/error-1"];
}

+ (instancetype)wr_cannotDecryptNewRemoteIDHelpURL
{
    return [self URLWithString:@"https://chatbox.tech/privacy/error-2"];
}

+ (instancetype)wr_unknownMessageHelpURL
{
    return [self URLWithString:@"https://chatbox.tech/compatibility/unknown-message"];
}

+ (instancetype)wr_createTeamURL
{
    return [self URLWithString:@"https://chatbox.tech/create-team?pk_campaign=client&pk_kwd=ios"];
}

+ (instancetype)wr_createTeamFeaturesURL
{
    return [self URLWithString:@"http://chatbox.tech/team.html"];
}

+ (instancetype)wr_manageTeamURL
{
    return [self URLWithString:@"https://teams.chatbox.tech/login?pk_campaign=client&pk_kwd=ios"];
}

+ (instancetype)wr_emailInUseLearnMoreURL
{
    return [self URLWithString:@"https://chatbox.tech/support/email-in-use"];
}

@end
