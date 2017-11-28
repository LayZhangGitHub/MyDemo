//
//  SubclassDemoController.m
//  LayZhangDemo
//
//  Created by LayZhang on 2017/11/7.
//  Copyright © 2017年 Zhanglei. All rights reserved.
//

#import "SubclassDemoController.h"
#import "NSObject+ZLEX.h"
#import "MFObject.h"


typedef NS_OPTIONS(int, AspectBlockFlags) {
    AspectBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    AspectBlockFlagsHasSignature          = (1 << 30)
};

typedef struct _AspectBlock {
    __unused Class isa;
    AspectBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _AspectBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        // requires AspectBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires AspectBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    // imported variables
} *AspectBlockRef;


static NSMethodSignature *aspect_blockMethodSignature(id block, NSError **error) {
    AspectBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & AspectBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        NSLog(@"=====%@", description);
        //        AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & AspectBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        NSLog(@"=====%@", description);
        //        AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}


@interface SubclassDemoController ()

@end

static char kExtendVarKey;
@implementation SubclassDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSArray *array = [self subclassesOfClass:[ZLViewController class]];
//    NSLog(@"%p", &kExtendVarKey);
//    NSLog(@"%s", &kExtendVarKey);
//    NSLog(@"%c", kExtendVarKey);
    
    [self createNavBarWithTitle:@"SubclassDemo" withLeft:[UIImage imageNamed:@"icon_back"]];
    
    NSArray *array = [ZLViewController zl_subclasses];
    for (Class classes in array) {
        NSLog(@"%@", classes);
    }
    
    NSMutableArray *set = [NSMutableArray new];
    MFObject *mf1 = [[MFObject alloc] init];
    mf1.mName = @"mName1";
    
    MFObject *mf2 = [[MFObject alloc] init];
    mf2.mName = @"mName2";
    
    [set addObject:mf1];
    [set addObject:mf2];
    
    NSMutableArray *nameSet = [set valueForKey:@"mName"];
    for (NSString *string in nameSet) {
        NSLog(@".... %@", string);
    }
    
    NSLog(@"%lu", sizeof(long));
    NSLog(@"%lu", sizeof(char));
    
    MFObject *mmm = [[MFObject alloc] init];
    mmm.mName = @"uuu";
    ^{
        mmm.mName = @"123";
    }();
    NSLog(@"%@", mmm.mName);
    
    [self test];
    [self test];
    [self test];
    [self test];
    
    [self signature];
}

- (void)signature {
    // 设定方法的样子
    SEL myMethod = @selector(classssss);
    // 预备方法
//    SEL myMethod2 = @selector(run:);
    // 返回一个方法 如果那个方法找不到则返回nil
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:myMethod];
    void (^block)(void) = ^{
        NSLog(@".llll...");
    };
    
    void (^test)(int) = ^(int a){
        NSLog(@"...lllll");
    };
    NSError *err = NULL;
//    NSMethodSignature *signature=  aspect_blockMethodSignature(block, &err);
    // 通过签名初始化
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    // 设置target
    
    [invocation invokeWithTarget:test];
//    SEL select  = @selector(block);
//    IMP imple = imp_implementationWithBlock(block);
//    [invocation setSelector:block];
    
//    [invocation setArgument:&block atIndex:0];
//    [invocation setArgument:&select atIndex:0];
    
    // 设置selectro
//    NSString *name1 = @"小明";
//    NSString *name2 = @"小张";
//    NSArray *arr3 = @[@"1",@"32",@"12334"];
    //注意：1、这里设置参数的Index 需要从2开始，因为前两个被selector和target占用。下面这样写也没有任何
    
//    id mySelf = self;
//    [invocation setArgument:&mySelf atIndex:0];
//    [invocation setArgument:&myMethod atIndex:1];
//    [invocation setArgument:&name1 atIndex:2];
//    [invocation setArgument:&name2 atIndex:3];
//    [invocation setArgument:&arr3 atIndex:4];
//    invocation.target = self;
//    NSInteger returnValue = 0;
//
//    [invocation invoke];
////    [invocation getReturnValue:&returnValue];
//    NSLog(@"%ld", (long)returnValue);
}

- (void)classssss {
    NSLog(@"llll");
}

- (NSInteger)run:(NSString *)aName {
    NSLog(@"print aName %@", aName);
    return 100;
}

- (void)test {
    static NSObject *object;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[NSObject alloc] init];
    });
    NSLog(@"%@", object);
}

- (NSArray *)subclassesOfClass:(Class)parentClass {
    int numClasses = objc_getClassList(NULL, 0); // 获取当前所有类的个数
    
    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);// 配好内存空间的数组 classes 中存放元素
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < numClasses; ++i) {
        Class superClass = classes[i];
        
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil) {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
