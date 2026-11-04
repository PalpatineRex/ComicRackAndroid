.class public final Lcra/fork/Img;
.super Ljava/lang/Object;
.source "Img.java"


# direct methods
.method private constructor <init>()V
    .locals 0

    .line 13
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static decode(Ljava/io/InputStream;Landroid/graphics/Rect;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;
    .locals 7

    if-nez p0, :cond_0

    .line 16
    invoke-static {p0, p1, p2}, Landroid/graphics/BitmapFactory;->decodeStream(Ljava/io/InputStream;Landroid/graphics/Rect;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 17
    :cond_0
    invoke-virtual {p0}, Ljava/io/InputStream;->markSupported()Z

    move-result v0

    const/high16 v1, 0x10000

    if-eqz v0, :cond_1

    goto :goto_0

    :cond_1
    new-instance v0, Ljava/io/BufferedInputStream;

    invoke-direct {v0, p0, v1}, Ljava/io/BufferedInputStream;-><init>(Ljava/io/InputStream;I)V

    move-object p0, v0

    :goto_0
    const/16 v0, 0xc

    new-array v2, v0, [B

    const/16 v3, 0x40

    const/4 v4, 0x0

    .line 21
    :try_start_0
    invoke-virtual {p0, v3}, Ljava/io/InputStream;->mark(I)V

    const/4 v3, 0x0

    const/4 v5, 0x0

    :goto_1
    if-ge v5, v0, :cond_3

    rsub-int/lit8 v6, v5, 0xc

    .line 23
    invoke-virtual {p0, v2, v5, v6}, Ljava/io/InputStream;->read([BII)I

    move-result v6

    if-gez v6, :cond_2

    goto :goto_2

    :cond_2
    add-int/2addr v5, v6

    goto :goto_1

    .line 27
    :cond_3
    :goto_2
    invoke-virtual {p0}, Ljava/io/InputStream;->reset()V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 31
    invoke-static {v2, v5}, Lcom/awxkee/jxlcoder/JxlCoder;->isJxl([BI)Z

    move-result v0

    if-nez v0, :cond_4

    .line 32
    invoke-static {p0, p1, p2}, Landroid/graphics/BitmapFactory;->decodeStream(Ljava/io/InputStream;Landroid/graphics/Rect;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    move-result-object p0

    return-object p0

    .line 35
    :cond_4
    :try_start_1
    new-instance p1, Ljava/io/ByteArrayOutputStream;

    const/high16 v0, 0x100000

    invoke-direct {p1, v0}, Ljava/io/ByteArrayOutputStream;-><init>(I)V

    new-array v0, v1, [B

    .line 38
    :goto_3
    invoke-virtual {p0, v0}, Ljava/io/InputStream;->read([B)I

    move-result v1

    if-lez v1, :cond_5

    invoke-virtual {p1, v0, v3, v1}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_3

    .line 39
    :cond_5
    invoke-virtual {p1}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    const-string p1, "image/jxl"

    const/4 v0, 0x1

    if-eqz p2, :cond_7

    .line 40
    :try_start_2
    iget-boolean v1, p2, Landroid/graphics/BitmapFactory$Options;->inJustDecodeBounds:Z

    if-eqz v1, :cond_7

    .line 41
    invoke-static {p0}, Lcom/awxkee/jxlcoder/JxlCoder;->size([B)[I

    move-result-object p0

    if-eqz p0, :cond_6

    .line 43
    aget v1, p0, v3

    iput v1, p2, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    .line 44
    aget p0, p0, v0

    iput p0, p2, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    .line 45
    iput-object p1, p2, Landroid/graphics/BitmapFactory$Options;->outMimeType:Ljava/lang/String;

    :cond_6
    return-object v4

    :cond_7
    if-nez p2, :cond_8

    goto :goto_4

    .line 49
    :cond_8
    iget v0, p2, Landroid/graphics/BitmapFactory$Options;->inSampleSize:I

    :goto_4
    invoke-static {p0, v0}, Lcom/awxkee/jxlcoder/JxlCoder;->decode([BI)Landroid/graphics/Bitmap;

    move-result-object p0

    if-eqz p0, :cond_9

    if-eqz p2, :cond_9

    .line 51
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v0

    iput v0, p2, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    .line 52
    invoke-virtual {p0}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v0

    iput v0, p2, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    .line 53
    iput-object p1, p2, Landroid/graphics/BitmapFactory$Options;->outMimeType:Ljava/lang/String;
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    :cond_9
    return-object p0

    :catch_0
    return-object v4
.end method
