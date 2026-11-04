.class final Lcra/fork/ContReader;
.super Ljava/lang/Object;
.source "ContReader.java"

# interfaces
.implements Landroid/app/Application$ActivityLifecycleCallbacks;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcra/fork/ContReader$Pages;
    }
.end annotation


# instance fields
.field private final cache:Landroid/util/LruCache;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Landroid/util/LruCache<",
            "Ljava/lang/Integer;",
            "Landroid/graphics/Bitmap;",
            ">;"
        }
    .end annotation
.end field

.field private volatile dead:Z

.field private final host:Landroid/app/Activity;

.field private final info:Ljava/lang/Object;

.field private final io:Ljava/util/concurrent/ExecutorService;

.field private label:Landroid/widget/TextView;

.field private final list:Landroid/widget/ListView;

.field private final loading:Ljava/util/Set;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Set<",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private final pageBitmap:Ljava/lang/reflect/Method;

.field private final pages:I

.field private pendingSel:I

.field private final rowMin:I

.field private shown:I

.field private final size:I

.field private final src:Ljava/lang/Object;

.field private final ui:Landroid/os/Handler;


# direct methods
.method constructor <init>(Landroid/app/Activity;Ljava/lang/Object;)V
    .locals 13
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 55
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, -0x1

    .line 47
    iput v0, p0, Lcra/fork/ContReader;->shown:I

    .line 48
    iput v0, p0, Lcra/fork/ContReader;->pendingSel:I

    .line 49
    new-instance v1, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v1, p0, Lcra/fork/ContReader;->ui:Landroid/os/Handler;

    .line 50
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v1

    iput-object v1, p0, Lcra/fork/ContReader;->io:Ljava/util/concurrent/ExecutorService;

    .line 51
    new-instance v1, Ljava/util/HashSet;

    invoke-direct {v1}, Ljava/util/HashSet;-><init>()V

    iput-object v1, p0, Lcra/fork/ContReader;->loading:Ljava/util/Set;

    .line 56
    iput-object p1, p0, Lcra/fork/ContReader;->host:Landroid/app/Activity;

    .line 57
    iput-object p2, p0, Lcra/fork/ContReader;->src:Ljava/lang/Object;

    const-string v1, "com.cyo.comicrack.a.b.h"

    .line 58
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const/4 v2, 0x0

    new-array v3, v2, [Ljava/lang/Class;

    const-string v4, "a"

    .line 59
    invoke-virtual {v1, v4, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    new-array v5, v2, [Ljava/lang/Object;

    invoke-virtual {v3, p2, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    iput-object v3, p0, Lcra/fork/ContReader;->info:Ljava/lang/Object;

    const/4 v5, 0x2

    new-array v6, v5, [Ljava/lang/Class;

    .line 60
    sget-object v7, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v7, v6, v2

    sget-object v7, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v8, 0x1

    aput-object v7, v6, v8

    invoke-virtual {v1, v4, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    iput-object v4, p0, Lcra/fork/ContReader;->pageBitmap:Ljava/lang/reflect/Method;

    .line 61
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    const-string v6, "e"

    new-array v7, v2, [Ljava/lang/Class;

    invoke-virtual {v4, v6, v7}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    new-array v6, v2, [Ljava/lang/Object;

    invoke-virtual {v4, v3, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v4

    iput v4, p0, Lcra/fork/ContReader;->pages:I

    if-lez v4, :cond_0

    .line 63
    invoke-virtual {p1}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;

    move-result-object v6

    invoke-virtual {v6}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v6

    .line 64
    iget v7, v6, Landroid/util/DisplayMetrics;->widthPixels:I

    mul-int/lit8 v7, v7, 0x3

    div-int/2addr v7, v5

    iput v7, p0, Lcra/fork/ContReader;->rowMin:I

    .line 65
    iget v7, v6, Landroid/util/DisplayMetrics;->widthPixels:I

    mul-int/lit8 v7, v7, 0x2

    const/16 v5, 0x400

    invoke-static {v5, v7}, Ljava/lang/Math;->max(II)I

    move-result v5

    iput v5, p0, Lcra/fork/ContReader;->size:I

    .line 66
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Runtime;->maxMemory()J

    move-result-wide v9

    const-wide/16 v11, 0x5

    div-long/2addr v9, v11

    const-wide/32 v11, 0x800000

    invoke-static {v11, v12, v9, v10}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v9

    long-to-int v5, v9

    .line 67
    new-instance v7, Lcra/fork/ContReader$1;

    invoke-direct {v7, p0, v5}, Lcra/fork/ContReader$1;-><init>(Lcra/fork/ContReader;I)V

    iput-object v7, p0, Lcra/fork/ContReader;->cache:Landroid/util/LruCache;

    .line 75
    :try_start_0
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v5

    const-string v7, "g"

    invoke-virtual {v5, v7}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v5

    sub-int/2addr v4, v8

    .line 76
    invoke-virtual {v5, v3}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result v3

    invoke-static {v4, v3}, Ljava/lang/Math;->min(II)I

    move-result v3

    invoke-static {v2, v3}, Ljava/lang/Math;->max(II)I

    move-result v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    const/4 v3, 0x0

    .line 81
    :goto_0
    new-instance v4, Lcra/fork/ContReader$2;

    invoke-direct {v4, p0, p1, p1}, Lcra/fork/ContReader$2;-><init>(Lcra/fork/ContReader;Landroid/content/Context;Landroid/app/Activity;)V

    iput-object v4, p0, Lcra/fork/ContReader;->list:Landroid/widget/ListView;

    const/4 v5, 0x0

    .line 91
    invoke-virtual {v4, v5}, Landroid/widget/ListView;->setDivider(Landroid/graphics/drawable/Drawable;)V

    const/high16 v7, -0x1000000

    .line 92
    invoke-virtual {v4, v7}, Landroid/widget/ListView;->setCacheColorHint(I)V

    .line 94
    new-instance v9, Landroid/view/View;

    invoke-direct {v9, p1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 95
    new-instance v10, Landroid/widget/AbsListView$LayoutParams;

    iget v6, v6, Landroid/util/DisplayMetrics;->heightPixels:I

    invoke-direct {v10, v0, v6}, Landroid/widget/AbsListView$LayoutParams;-><init>(II)V

    invoke-virtual {v9, v10}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 96
    invoke-virtual {v4, v9, v5, v2}, Landroid/widget/ListView;->addFooterView(Landroid/view/View;Ljava/lang/Object;Z)V

    .line 97
    new-instance v6, Lcra/fork/ContReader$Pages;

    invoke-direct {v6, p0, v5}, Lcra/fork/ContReader$Pages;-><init>(Lcra/fork/ContReader;Lcra/fork/ContReader$1;)V

    invoke-virtual {v4, v6}, Landroid/widget/ListView;->setAdapter(Landroid/widget/ListAdapter;)V

    .line 98
    new-instance v6, Lcra/fork/ContReader$3;

    invoke-direct {v6, p0}, Lcra/fork/ContReader$3;-><init>(Lcra/fork/ContReader;)V

    invoke-virtual {v4, v6}, Landroid/widget/ListView;->setOnScrollListener(Landroid/widget/AbsListView$OnScrollListener;)V

    .line 109
    new-instance v6, Landroid/widget/FrameLayout;

    invoke-direct {v6, p1}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    .line 110
    invoke-virtual {v6, v7}, Landroid/widget/FrameLayout;->setBackgroundColor(I)V

    .line 111
    new-instance v7, Landroid/widget/FrameLayout$LayoutParams;

    invoke-direct {v7, v0, v0}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v6, v4, v7}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 112
    new-instance v7, Landroid/widget/TextView;

    invoke-direct {v7, p1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v7, p0, Lcra/fork/ContReader;->label:Landroid/widget/TextView;

    .line 113
    invoke-virtual {v7, v0}, Landroid/widget/TextView;->setTextColor(I)V

    .line 114
    iget-object v0, p0, Lcra/fork/ContReader;->label:Landroid/widget/TextView;

    const/high16 v7, -0x67000000

    invoke-virtual {v0, v7}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 115
    iget-object v0, p0, Lcra/fork/ContReader;->label:Landroid/widget/TextView;

    const/16 v7, 0x12

    const/4 v9, 0x6

    invoke-virtual {v0, v7, v9, v7, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 116
    iget-object v0, p0, Lcra/fork/ContReader;->label:Landroid/widget/TextView;

    new-instance v7, Landroid/widget/FrameLayout$LayoutParams;

    const/16 v9, 0x55

    const/4 v10, -0x2

    invoke-direct {v7, v10, v10, v9}, Landroid/widget/FrameLayout$LayoutParams;-><init>(III)V

    invoke-virtual {v6, v0, v7}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 117
    invoke-virtual {p1}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    const/16 v7, 0x80

    invoke-virtual {v0, v7}, Landroid/view/Window;->addFlags(I)V

    .line 118
    invoke-virtual {p1, v6}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    .line 119
    invoke-virtual {v4}, Landroid/widget/ListView;->requestFocus()Z

    :try_start_1
    const-string v0, "com.cyo.comicrack.a.f"

    .line 121
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-string v4, "b"

    new-array v6, v8, [Ljava/lang/Class;

    aput-object v1, v6, v2

    invoke-virtual {v0, v4, v6}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    new-array v1, v8, [Ljava/lang/Object;

    aput-object p2, v1, v2

    invoke-virtual {v0, v5, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 125
    :catchall_1
    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "open: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget v0, p0, Lcra/fork/ContReader;->pages:I

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " pages, start at "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    const-string v0, "cra.cont"

    invoke-static {v0, p2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 126
    iput v3, p0, Lcra/fork/ContReader;->pendingSel:I

    .line 127
    iget-object p2, p0, Lcra/fork/ContReader;->list:Landroid/widget/ListView;

    invoke-virtual {p2, v3, v2}, Landroid/widget/ListView;->setSelectionFromTop(II)V

    .line 128
    invoke-direct {p0, v3}, Lcra/fork/ContReader;->show(I)V

    .line 129
    invoke-virtual {p1}, Landroid/app/Activity;->getApplication()Landroid/app/Application;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroid/app/Application;->registerActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    return-void

    .line 62
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "no pages"

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method static synthetic access$100(Lcra/fork/ContReader;)I
    .locals 0

    .line 37
    iget p0, p0, Lcra/fork/ContReader;->pages:I

    return p0
.end method

.method static synthetic access$1000(Lcra/fork/ContReader;)I
    .locals 0

    .line 37
    iget p0, p0, Lcra/fork/ContReader;->pendingSel:I

    return p0
.end method

.method static synthetic access$1002(Lcra/fork/ContReader;I)I
    .locals 0

    .line 37
    iput p1, p0, Lcra/fork/ContReader;->pendingSel:I

    return p1
.end method

.method static synthetic access$1100(Lcra/fork/ContReader;)Landroid/os/Handler;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->ui:Landroid/os/Handler;

    return-object p0
.end method

.method static synthetic access$1200(Lcra/fork/ContReader;)Landroid/app/Activity;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->host:Landroid/app/Activity;

    return-object p0
.end method

.method static synthetic access$1300(Lcra/fork/ContReader;)I
    .locals 0

    .line 37
    iget p0, p0, Lcra/fork/ContReader;->rowMin:I

    return p0
.end method

.method static synthetic access$1400(Lcra/fork/ContReader;I)V
    .locals 0

    .line 37
    invoke-direct {p0, p1}, Lcra/fork/ContReader;->load(I)V

    return-void
.end method

.method static synthetic access$200(Lcra/fork/ContReader;I)V
    .locals 0

    .line 37
    invoke-direct {p0, p1}, Lcra/fork/ContReader;->show(I)V

    return-void
.end method

.method static synthetic access$300(Lcra/fork/ContReader;)Ljava/lang/Object;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->src:Ljava/lang/Object;

    return-object p0
.end method

.method static synthetic access$400(Lcra/fork/ContReader;)I
    .locals 0

    .line 37
    iget p0, p0, Lcra/fork/ContReader;->size:I

    return p0
.end method

.method static synthetic access$500(Lcra/fork/ContReader;)Ljava/lang/reflect/Method;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->pageBitmap:Ljava/lang/reflect/Method;

    return-object p0
.end method

.method static synthetic access$600(Lcra/fork/ContReader;)Ljava/util/Set;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->loading:Ljava/util/Set;

    return-object p0
.end method

.method static synthetic access$700(Lcra/fork/ContReader;)Landroid/util/LruCache;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->cache:Landroid/util/LruCache;

    return-object p0
.end method

.method static synthetic access$800(Lcra/fork/ContReader;)Z
    .locals 0

    .line 37
    iget-boolean p0, p0, Lcra/fork/ContReader;->dead:Z

    return p0
.end method

.method static synthetic access$900(Lcra/fork/ContReader;)Landroid/widget/ListView;
    .locals 0

    .line 37
    iget-object p0, p0, Lcra/fork/ContReader;->list:Landroid/widget/ListView;

    return-object p0
.end method

.method private load(I)V
    .locals 3

    .line 175
    iget-object v0, p0, Lcra/fork/ContReader;->loading:Ljava/util/Set;

    monitor-enter v0

    .line 176
    :try_start_0
    iget-object v1, p0, Lcra/fork/ContReader;->loading:Ljava/util/Set;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    monitor-exit v0

    return-void

    .line 177
    :cond_0
    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 178
    iget-object v0, p0, Lcra/fork/ContReader;->io:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcra/fork/ContReader$4;

    invoke-direct {v1, p0, p1}, Lcra/fork/ContReader$4;-><init>(Lcra/fork/ContReader;I)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    return-void

    :catchall_0
    move-exception p1

    .line 177
    :try_start_1
    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method private save()V
    .locals 8

    const-string v0, "save: page "

    .line 140
    :try_start_0
    iget v1, p0, Lcra/fork/ContReader;->pages:I

    const/4 v2, 0x1

    sub-int/2addr v1, v2

    iget v3, p0, Lcra/fork/ContReader;->shown:I

    invoke-static {v1, v3}, Ljava/lang/Math;->min(II)I

    move-result v1

    const/4 v3, 0x0

    invoke-static {v3, v1}, Ljava/lang/Math;->max(II)I

    move-result v1

    const-string v4, "cra.cont"

    .line 141
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v4, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 142
    iget-object v0, p0, Lcra/fork/ContReader;->info:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const-string v4, "b"

    new-array v5, v2, [Ljava/lang/Class;

    .line 143
    sget-object v6, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v6, v5, v3

    invoke-virtual {v0, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    iget-object v5, p0, Lcra/fork/ContReader;->info:Ljava/lang/Object;

    new-array v6, v2, [Ljava/lang/Object;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v6, v3

    invoke-virtual {v4, v5, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    const-string v4, "g"

    new-array v5, v3, [Ljava/lang/Class;

    .line 144
    invoke-virtual {v0, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    iget-object v5, p0, Lcra/fork/ContReader;->info:Ljava/lang/Object;

    new-array v6, v3, [Ljava/lang/Object;

    invoke-virtual {v4, v5, v6}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v4

    if-le v1, v4, :cond_0

    const-string v4, "c"

    new-array v5, v2, [Ljava/lang/Class;

    .line 145
    sget-object v6, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v6, v5, v3

    invoke-virtual {v0, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v4, p0, Lcra/fork/ContReader;->info:Ljava/lang/Object;

    new-array v5, v2, [Ljava/lang/Object;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    aput-object v1, v5, v3

    invoke-virtual {v0, v4, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    const-string v0, "com.cyo.comicrack.a.b.h"

    .line 146
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-string v1, "com.cyo.comicrack.a.f"

    .line 147
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v4, "a"

    new-array v5, v2, [Ljava/lang/Class;

    aput-object v0, v5, v3

    invoke-virtual {v1, v4, v5}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    new-array v1, v2, [Ljava/lang/Object;

    iget-object v2, p0, Lcra/fork/ContReader;->src:Ljava/lang/Object;

    aput-object v2, v1, v3

    const/4 v2, 0x0

    invoke-virtual {v0, v2, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :catchall_0
    return-void
.end method

.method private show(I)V
    .locals 2

    .line 133
    iget-object v0, p0, Lcra/fork/ContReader;->label:Landroid/widget/TextView;

    if-eqz v0, :cond_1

    iget v1, p0, Lcra/fork/ContReader;->shown:I

    if-eq p1, v1, :cond_1

    iget v1, p0, Lcra/fork/ContReader;->pages:I

    if-nez v1, :cond_0

    goto :goto_0

    .line 134
    :cond_0
    iput p1, p0, Lcra/fork/ContReader;->shown:I

    .line 135
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    add-int/lit8 p1, p1, 0x1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " / "

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget p1, p0, Lcra/fork/ContReader;->pages:I

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :cond_1
    :goto_0
    return-void
.end method


# virtual methods
.method public onActivityCreated(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 0

    return-void
.end method

.method public onActivityDestroyed(Landroid/app/Activity;)V
    .locals 1

    .line 158
    iget-object v0, p0, Lcra/fork/ContReader;->host:Landroid/app/Activity;

    if-eq p1, v0, :cond_0

    return-void

    :cond_0
    const/4 p1, 0x1

    .line 159
    iput-boolean p1, p0, Lcra/fork/ContReader;->dead:Z

    .line 160
    iget-object p1, p0, Lcra/fork/ContReader;->io:Ljava/util/concurrent/ExecutorService;

    invoke-interface {p1}, Ljava/util/concurrent/ExecutorService;->shutdownNow()Ljava/util/List;

    .line 161
    iget-object p1, p0, Lcra/fork/ContReader;->host:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->getApplication()Landroid/app/Application;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroid/app/Application;->unregisterActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    return-void
.end method

.method public onActivityPaused(Landroid/app/Activity;)V
    .locals 1

    .line 154
    iget-object v0, p0, Lcra/fork/ContReader;->host:Landroid/app/Activity;

    if-ne p1, v0, :cond_0

    invoke-direct {p0}, Lcra/fork/ContReader;->save()V

    :cond_0
    return-void
.end method

.method public onActivityResumed(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method

.method public onActivitySaveInstanceState(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 0

    return-void
.end method

.method public onActivityStarted(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method

.method public onActivityStopped(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method
