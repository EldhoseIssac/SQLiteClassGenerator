//
//  codeGenHeader.h
//  codegenTst
//
//  Created by Eldhose on 31/10/12.
//  Copyright (c) 2012 Islet Systems. All rights reserved.
//

#ifndef codegenTst_codeGenHeader_h
#define codegenTst_codeGenHeader_h

#define kTABLENAME @"{TABLENAME}"
#define kOBJECTLISTLOCAL @"{OBJECTLISTLOCAL}"
#define kOBJECTLISTGLOBAL @"{OBJECTLISTGLOBAL}"
#define kNSTYPE @"{NSTYPE}"
#define kOBJECTNAME @"{OBJECTNAME}"
#define kSYNTHESIZELIST @"{SYNTHESIZELIST}"
#define kCREATEQUERY @"{CREATEQUERY}"

#define kOBJECTLISTLOCALITEM @"\t{NSTYPE} * _{OBJECTNAME};\n"
#define kOBJECTLISTGLOBALITEM @"\t@property (nonatomic,strong) {NSTYPE} * {OBJECTNAME};\n"
#define kSYNTHESIZELISTITEM @"@synthesize {OBJECTNAME}=_{OBJECTNAME};\n"
#endif
