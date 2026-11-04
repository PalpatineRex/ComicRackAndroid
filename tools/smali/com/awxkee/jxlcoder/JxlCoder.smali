.class public final Lcom/awxkee/jxlcoder/JxlCoder;
.super Ljava/lang/Object;
.source "JxlCoder.java"


# static fields
.field private static final INSTANCE:Lcom/awxkee/jxlcoder/JxlCoder;

.field private static final LOADED:Z


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .line 12
    new-instance v0, Lcom/awxkee/jxlcoder/JxlCoder;

    invoke-direct {v0}, Lcom/awxkee/jxlcoder/JxlCoder;-><init>()V

    sput-object v0, Lcom/awxkee/jxlcoder/JxlCoder;->INSTANCE:Lcom/awxkee/jxlcoder/JxlCoder;

    :try_start_0
    const-string v0, "jxlcoder"

    .line 18
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    const/4 v0, 0x1

    goto :goto_0

    :catchall_0
    move-exception v0

    const-string v1, "cra.jxl"

    const-string v2, "JPEG XL library not available"

    .line 21
    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    const/4 v0, 0x0

    .line 24
    :goto_0
    sput-boolean v0, Lcom/awxkee/jxlcoder/JxlCoder;->LOADED:Z

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 27
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static decode([BI)Landroid/graphics/Bitmap;
    .locals 9

    .line 56
    sget-boolean v0, Lcom/awxkee/jxlcoder/JxlCoder;->LOADED:Z

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return-object v1

    :cond_0
    const/4 v0, 0x1

    if-le p1, v0, :cond_1

    .line 59
    :try_start_0
    sget-object v2, Lcom/awxkee/jxlcoder/JxlCoder;->INSTANCE:Lcom/awxkee/jxlcoder/JxlCoder;

    invoke-direct {v2, p0}, Lcom/awxkee/jxlcoder/JxlCoder;->getSizeImpl([B)Landroid/util/Size;

    move-result-object v3

    if-eqz v3, :cond_1

    .line 61
    invoke-virtual {v3}, Landroid/util/Size;->getWidth()I

    move-result v4

    div-int/2addr v4, p1

    invoke-static {v0, v4}, Ljava/lang/Math;->max(II)I

    move-result v4

    .line 62
    invoke-virtual {v3}, Landroid/util/Size;->getHeight()I

    move-result v3

    div-int/2addr v3, p1

    invoke-static {v0, v3}, Ljava/lang/Math;->max(II)I

    move-result v5

    const/4 v6, 0x2

    const/4 v7, 0x3

    const/4 v8, 0x4

    move-object v3, p0

    .line 61
    invoke-direct/range {v2 .. v8}, Lcom/awxkee/jxlcoder/JxlCoder;->decodeSampledImpl([BIIIII)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 65
    :cond_1
    sget-object v2, Lcom/awxkee/jxlcoder/JxlCoder;->INSTANCE:Lcom/awxkee/jxlcoder/JxlCoder;

    const/4 v4, -0x1

    const/4 v5, -0x1

    const/4 v6, 0x2

    const/4 v7, 0x1

    const/4 v8, 0x6

    move-object v3, p0

    invoke-direct/range {v2 .. v8}, Lcom/awxkee/jxlcoder/JxlCoder;->decodeSampledImpl([BIIIII)Landroid/graphics/Bitmap;

    move-result-object p0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-object p0

    :catchall_0
    move-exception p0

    const-string p1, "cra.jxl"

    const-string v0, "decode failed"

    .line 67
    invoke-static {p1, v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-object v1
.end method

.method private native decodeSampledImpl([BIIIII)Landroid/graphics/Bitmap;
.end method

.method private native getSizeImpl([B)Landroid/util/Size;
.end method

.method public static isJxl([BI)Z
    .locals 6

    const/4 v0, 0x2

    const/4 v1, 0x1

    const/4 v2, 0x0

    if-lt p1, v0, :cond_0

    .line 35
    aget-byte v0, p0, v2

    const/4 v3, -0x1

    if-ne v0, v3, :cond_0

    aget-byte v0, p0, v1

    const/16 v3, 0xa

    if-ne v0, v3, :cond_0

    return v1

    :cond_0
    const/16 v0, 0xc

    new-array v3, v0, [B

    .line 36
    fill-array-data v3, :array_0

    if-ge p1, v0, :cond_1

    return v2

    :cond_1
    const/4 p1, 0x0

    :goto_0
    if-ge p1, v0, :cond_3

    .line 38
    aget-byte v4, p0, p1

    aget-byte v5, v3, p1

    if-eq v4, v5, :cond_2

    return v2

    :cond_2
    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    :cond_3
    return v1

    nop

    :array_0
    .array-data 1
        0x0t
        0x0t
        0x0t
        0xct
        0x4at
        0x58t
        0x4ct
        0x20t
        0xdt
        0xat
        -0x79t
        0xat
    .end array-data
.end method

.method public static size([B)[I
    .locals 4

    .line 44
    sget-boolean v0, Lcom/awxkee/jxlcoder/JxlCoder;->LOADED:Z

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return-object v1

    .line 46
    :cond_0
    :try_start_0
    sget-object v0, Lcom/awxkee/jxlcoder/JxlCoder;->INSTANCE:Lcom/awxkee/jxlcoder/JxlCoder;

    invoke-direct {v0, p0}, Lcom/awxkee/jxlcoder/JxlCoder;->getSizeImpl([B)Landroid/util/Size;

    move-result-object p0

    if-nez p0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v0, 0x2

    new-array v0, v0, [I

    .line 47
    invoke-virtual {p0}, Landroid/util/Size;->getWidth()I

    move-result v2

    const/4 v3, 0x0

    aput v2, v0, v3

    invoke-virtual {p0}, Landroid/util/Size;->getHeight()I

    move-result p0

    const/4 v2, 0x1

    aput p0, v0, v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-object v1, v0

    :goto_0
    return-object v1

    :catchall_0
    move-exception p0

    const-string v0, "cra.jxl"

    const-string v2, "size failed"

    .line 49
    invoke-static {v0, v2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-object v1
.end method
