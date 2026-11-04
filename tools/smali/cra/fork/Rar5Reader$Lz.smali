.class final Lcra/fork/Rar5Reader$Lz;
.super Ljava/lang/Object;
.source "Rar5Reader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcra/fork/Rar5Reader;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "Lz"
.end annotation


# instance fields
.field acc:J

.field bytesRead:J

.field fileBase:J

.field fileEnd:J

.field fileInPos:J

.field final filters:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lcra/fork/Rar5Reader$Filter;",
            ">;"
        }
    .end annotation
.end field

.field flushed:J

.field ibuf:[B

.field ilen:I

.field ipos:I

.field lastLen:I

.field mask:I

.field nbits:I

.field obuf:[B

.field regionEnd:J

.field reps:[I

.field tDist:[I

.field tLow:[I

.field tMain:[I

.field tRep:[I

.field final synthetic this$0:Lcra/fork/Rar5Reader;

.field total:J

.field win:[B


# direct methods
.method constructor <init>(Lcra/fork/Rar5Reader;I)V
    .locals 1

    .line 349
    iput-object p1, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 p1, 0x4

    new-array p1, p1, [I

    .line 334
    iput-object p1, p0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    .line 337
    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    iput-object p1, p0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    const/high16 p1, 0x10000

    new-array v0, p1, [B

    .line 338
    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    new-array p1, p1, [B

    .line 341
    iput-object p1, p0, Lcra/fork/Rar5Reader$Lz;->ibuf:[B

    .line 350
    new-array p1, p2, [B

    iput-object p1, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    add-int/lit8 p2, p2, -0x1

    .line 351
    iput p2, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    return-void
.end method

.method private applyFilter(Lcra/fork/Rar5Reader$Filter;[BJ)[B
    .locals 17
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p1

    move-object/from16 v1, p2

    .line 585
    array-length v2, v1

    .line 586
    iget v3, v0, Lcra/fork/Rar5Reader$Filter;->type:I

    const/4 v4, 0x0

    if-eqz v3, :cond_a

    const/4 v5, 0x2

    const/4 v6, 0x1

    if-eq v3, v6, :cond_3

    if-eq v3, v5, :cond_3

    const/4 v0, 0x3

    if-ne v3, v0, :cond_2

    :goto_0
    add-int/lit8 v0, v4, 0x3

    if-ge v0, v2, :cond_1

    .line 623
    aget-byte v0, v1, v0

    and-int/lit16 v0, v0, 0xff

    const/16 v3, 0xeb

    if-ne v0, v3, :cond_0

    .line 624
    aget-byte v0, v1, v4

    int-to-long v5, v0

    const-wide/16 v7, 0xff

    and-long/2addr v5, v7

    add-int/lit8 v0, v4, 0x1

    aget-byte v3, v1, v0

    int-to-long v9, v3

    and-long/2addr v9, v7

    const/16 v3, 0x8

    shl-long/2addr v9, v3

    or-long/2addr v5, v9

    add-int/lit8 v9, v4, 0x2

    aget-byte v10, v1, v9

    int-to-long v10, v10

    and-long/2addr v7, v10

    const/16 v10, 0x10

    shl-long/2addr v7, v10

    or-long/2addr v5, v7

    int-to-long v7, v4

    add-long v7, p3, v7

    const-wide/16 v11, 0x4

    .line 625
    div-long/2addr v7, v11

    sub-long/2addr v5, v7

    long-to-int v7, v5

    int-to-byte v7, v7

    .line 626
    aput-byte v7, v1, v4

    shr-long v7, v5, v3

    long-to-int v3, v7

    int-to-byte v3, v3

    .line 627
    aput-byte v3, v1, v0

    shr-long/2addr v5, v10

    long-to-int v0, v5

    int-to-byte v0, v0

    .line 628
    aput-byte v0, v1, v9

    :cond_0
    add-int/lit8 v4, v4, 0x4

    goto :goto_0

    :cond_1
    return-object v1

    .line 634
    :cond_2
    new-instance v0, Ljava/io/IOException;

    const-string v1, "unknown filter"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 602
    :cond_3
    iget v0, v0, Lcra/fork/Rar5Reader$Filter;->type:I

    if-ne v0, v5, :cond_4

    goto :goto_1

    :cond_4
    const/4 v6, 0x0

    :goto_1
    add-int/lit8 v0, v4, 0x4

    if-ge v0, v2, :cond_9

    add-int/lit8 v0, v4, 0x1

    .line 605
    aget-byte v3, v1, v4

    and-int/lit16 v3, v3, 0xff

    const/16 v4, 0xe8

    if-eq v3, v4, :cond_6

    if-eqz v6, :cond_5

    const/16 v4, 0xe9

    if-ne v3, v4, :cond_5

    goto :goto_3

    :cond_5
    :goto_2
    move v4, v0

    goto :goto_1

    :cond_6
    :goto_3
    int-to-long v3, v0

    add-long v3, v3, p3

    const-wide/32 v7, 0x1000000

    .line 607
    rem-long/2addr v3, v7

    .line 608
    invoke-static {v1, v0}, Lcra/fork/Rar5Reader;->access$400([BI)J

    move-result-wide v9

    const-wide v11, 0x80000000L

    and-long v13, v9, v11

    const-wide/16 v15, 0x0

    cmp-long v5, v13, v15

    if-eqz v5, :cond_7

    add-long/2addr v3, v9

    and-long/2addr v3, v11

    cmp-long v5, v3, v15

    if-nez v5, :cond_8

    add-long/2addr v9, v7

    .line 611
    invoke-static {v1, v0, v9, v10}, Lcra/fork/Rar5Reader;->access$500([BIJ)V

    goto :goto_4

    :cond_7
    sub-long v7, v9, v7

    and-long/2addr v7, v11

    cmp-long v5, v7, v15

    if-eqz v5, :cond_8

    sub-long/2addr v9, v3

    .line 614
    invoke-static {v1, v0, v9, v10}, Lcra/fork/Rar5Reader;->access$500([BIJ)V

    :cond_8
    :goto_4
    add-int/lit8 v0, v0, 0x4

    goto :goto_2

    :cond_9
    return-object v1

    .line 588
    :cond_a
    new-array v3, v2, [B

    .line 589
    iget v0, v0, Lcra/fork/Rar5Reader$Filter;->channels:I

    const/4 v5, 0x0

    const/4 v6, 0x0

    :goto_5
    if-ge v5, v0, :cond_c

    move v7, v5

    const/4 v8, 0x0

    :goto_6
    if-ge v7, v2, :cond_b

    add-int/lit8 v9, v6, 0x1

    .line 594
    aget-byte v6, v1, v6

    sub-int/2addr v8, v6

    and-int/lit16 v8, v8, 0xff

    int-to-byte v6, v8

    .line 595
    aput-byte v6, v3, v7

    add-int/2addr v7, v0

    move v6, v9

    goto :goto_6

    :cond_b
    add-int/lit8 v5, v5, 0x1

    goto :goto_5

    :cond_c
    return-object v3
.end method

.method private build([III)[I
    .locals 11
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x10

    new-array v0, v0, [I

    const/4 v1, 0x0

    const/4 v2, 0x0

    :goto_0
    const/4 v3, 0x1

    if-ge v2, p3, :cond_0

    add-int v4, p2, v2

    .line 421
    aget v4, p1, v4

    aget v5, v0, v4

    add-int/2addr v5, v3

    aput v5, v0, v4

    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_0
    aput v1, v0, v1

    const/16 v2, 0x11

    new-array v2, v2, [I

    const/4 v4, 0x1

    :goto_1
    const/16 v5, 0xf

    if-gt v4, v5, :cond_1

    add-int/lit8 v5, v4, 0x1

    .line 426
    aget v6, v2, v4

    aget v4, v0, v4

    add-int/2addr v6, v4

    shl-int/lit8 v4, v6, 0x1

    aput v4, v2, v5

    move v4, v5

    goto :goto_1

    :cond_1
    const v0, 0x8000

    new-array v4, v0, [I

    const/4 v5, 0x0

    :goto_2
    if-ge v5, p3, :cond_5

    add-int v6, p2, v5

    .line 430
    aget v6, p1, v6

    if-nez v6, :cond_2

    goto :goto_4

    .line 434
    :cond_2
    aget v7, v2, v6

    add-int/lit8 v8, v7, 0x1

    aput v8, v2, v6

    rsub-int/lit8 v8, v6, 0xf

    shl-int/2addr v7, v8

    shl-int v8, v3, v8

    add-int v9, v7, v8

    if-gt v9, v0, :cond_4

    shl-int/lit8 v6, v6, 0x10

    or-int/2addr v6, v5

    const/4 v9, 0x0

    :goto_3
    if-ge v9, v8, :cond_3

    add-int v10, v7, v9

    .line 442
    aput v6, v4, v10

    add-int/lit8 v9, v9, 0x1

    goto :goto_3

    :cond_3
    :goto_4
    add-int/lit8 v5, v5, 0x1

    goto :goto_2

    .line 438
    :cond_4
    new-instance p1, Ljava/io/IOException;

    const-string p2, "bad huffman table"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_5
    return-object v4
.end method

.method private copy(II)V
    .locals 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-lez p2, :cond_2

    .line 512
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    array-length v0, v0

    if-gt p2, v0, :cond_2

    int-to-long v0, p2

    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    cmp-long p2, v0, v2

    if-gtz p2, :cond_2

    .line 515
    iget-wide v4, p0, Lcra/fork/Rar5Reader$Lz;->fileEnd:J

    sub-long/2addr v4, v2

    int-to-long v6, p1

    cmp-long p2, v6, v4

    if-lez p2, :cond_0

    long-to-int p1, v4

    :cond_0
    sub-long v0, v2, v0

    .line 519
    iget p2, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    int-to-long v4, p2

    and-long/2addr v0, v4

    long-to-int v1, v0

    int-to-long v4, p2

    and-long/2addr v2, v4

    long-to-int p2, v2

    const/4 v0, 0x0

    :goto_0
    if-ge v0, p1, :cond_1

    .line 522
    iget-object v2, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    aget-byte v3, v2, v1

    aput-byte v3, v2, p2

    add-int/lit8 p2, p2, 0x1

    .line 523
    iget v2, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    and-int/2addr p2, v2

    add-int/lit8 v1, v1, 0x1

    and-int/2addr v1, v2

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 526
    :cond_1
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    int-to-long p1, p1

    add-long/2addr v0, p1

    iput-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    return-void

    .line 513
    :cond_2
    new-instance p1, Ljava/io/IOException;

    const-string p2, "bad distance"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private fill()V
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 362
    :goto_0
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    const/16 v1, 0x20

    if-gt v0, v1, :cond_3

    .line 364
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->regionEnd:J

    const/4 v4, 0x0

    cmp-long v5, v0, v2

    if-ltz v5, :cond_0

    goto :goto_2

    .line 367
    :cond_0
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->ipos:I

    iget v1, p0, Lcra/fork/Rar5Reader$Lz;->ilen:I

    if-lt v0, v1, :cond_2

    .line 368
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v0}, Lcra/fork/Rar5Reader;->access$100(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;

    move-result-object v0

    iget-wide v1, p0, Lcra/fork/Rar5Reader$Lz;->fileInPos:J

    invoke-virtual {v0, v1, v2}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 369
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->ibuf:[B

    array-length v0, v0

    int-to-long v0, v0

    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->regionEnd:J

    iget-wide v5, p0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    sub-long/2addr v2, v5

    invoke-static {v0, v1, v2, v3}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v0

    long-to-int v1, v0

    .line 370
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v0}, Lcra/fork/Rar5Reader;->access$100(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;

    move-result-object v0

    iget-object v2, p0, Lcra/fork/Rar5Reader$Lz;->ibuf:[B

    invoke-virtual {v0, v2, v4, v1}, Ljava/io/RandomAccessFile;->read([BII)I

    move-result v0

    iput v0, p0, Lcra/fork/Rar5Reader$Lz;->ilen:I

    if-lez v0, :cond_1

    .line 374
    iget-wide v1, p0, Lcra/fork/Rar5Reader$Lz;->fileInPos:J

    int-to-long v5, v0

    add-long/2addr v1, v5

    iput-wide v1, p0, Lcra/fork/Rar5Reader$Lz;->fileInPos:J

    .line 375
    iput v4, p0, Lcra/fork/Rar5Reader$Lz;->ipos:I

    goto :goto_1

    .line 372
    :cond_1
    new-instance v0, Ljava/io/IOException;

    const-string v1, "truncated data"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 377
    :cond_2
    :goto_1
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->ibuf:[B

    iget v1, p0, Lcra/fork/Rar5Reader$Lz;->ipos:I

    add-int/lit8 v2, v1, 0x1

    iput v2, p0, Lcra/fork/Rar5Reader$Lz;->ipos:I

    aget-byte v0, v0, v1

    and-int/lit16 v4, v0, 0xff

    .line 379
    :goto_2
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    const-wide/16 v2, 0x1

    add-long/2addr v0, v2

    iput-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    .line 380
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->acc:J

    const/16 v2, 0x8

    shl-long/2addr v0, v2

    int-to-long v3, v4

    or-long/2addr v0, v3

    iput-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->acc:J

    .line 381
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    add-int/2addr v0, v2

    iput v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    goto :goto_0

    :cond_3
    return-void
.end method

.method private filterData()J
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x2

    .line 639
    invoke-virtual {p0, v0}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v0

    long-to-int v1, v0

    add-int/lit8 v1, v1, 0x1

    const-wide/16 v2, 0x0

    const/4 v0, 0x0

    :goto_0
    if-ge v0, v1, :cond_0

    const/16 v4, 0x8

    .line 642
    invoke-virtual {p0, v4}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v4

    mul-int/lit8 v6, v0, 0x8

    shl-long/2addr v4, v6

    or-long/2addr v2, v4

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_0
    return-wide v2
.end method

.method private lenFromSlot(I)I
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x8

    if-ge p1, v0, :cond_0

    add-int/lit8 p1, p1, 0x2

    return p1

    :cond_0
    shr-int/lit8 v0, p1, 0x2

    add-int/lit8 v0, v0, -0x1

    and-int/lit8 p1, p1, 0x3

    or-int/lit8 p1, p1, 0x4

    shl-int/2addr p1, v0

    add-int/lit8 p1, p1, 0x2

    .line 652
    invoke-virtual {p0, v0}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v0

    long-to-int v1, v0

    add-int/2addr p1, v1

    return p1
.end method

.method private process()V
    .locals 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 545
    :goto_0
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    cmp-long v4, v0, v2

    if-gez v4, :cond_7

    .line 546
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    const/4 v0, 0x0

    goto :goto_1

    :cond_0
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcra/fork/Rar5Reader$Filter;

    :goto_1
    if-nez v0, :cond_1

    .line 548
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    invoke-direct {p0, v0, v1, v2, v3}, Lcra/fork/Rar5Reader$Lz;->write(JJ)V

    .line 549
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    iput-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    return-void

    .line 552
    :cond_1
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    iget-wide v4, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    cmp-long v6, v2, v4

    if-lez v6, :cond_2

    .line 553
    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    invoke-static {v2, v3, v4, v5}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v2

    .line 554
    iget-wide v4, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    invoke-direct {p0, v4, v5, v2, v3}, Lcra/fork/Rar5Reader$Lz;->write(JJ)V

    .line 555
    iput-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    .line 556
    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    cmp-long v6, v2, v4

    if-gez v6, :cond_2

    return-void

    .line 560
    :cond_2
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    iget-wide v4, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    cmp-long v6, v2, v4

    if-ltz v6, :cond_6

    .line 563
    iget-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    sub-long/2addr v2, v4

    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->length:J

    cmp-long v6, v2, v4

    if-gez v6, :cond_3

    return-void

    .line 566
    :cond_3
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Filter;->length:J

    const-wide/32 v4, 0x4000000

    cmp-long v6, v2, v4

    if-gtz v6, :cond_5

    .line 569
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Filter;->length:J

    long-to-int v3, v2

    new-array v2, v3, [B

    .line 570
    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    iget v6, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    int-to-long v6, v6

    and-long/2addr v4, v6

    long-to-int v5, v4

    .line 571
    iget-object v4, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    array-length v4, v4

    sub-int/2addr v4, v5

    invoke-static {v3, v4}, Ljava/lang/Math;->min(II)I

    move-result v4

    .line 572
    iget-object v6, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    invoke-static {v6, v5, v2, v1, v4}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    if-ge v4, v3, :cond_4

    .line 574
    iget-object v5, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    sub-int/2addr v3, v4

    invoke-static {v5, v1, v2, v4, v3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 576
    :cond_4
    iget-wide v3, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    iget-wide v5, p0, Lcra/fork/Rar5Reader$Lz;->fileBase:J

    sub-long/2addr v3, v5

    invoke-direct {p0, v0, v2, v3, v4}, Lcra/fork/Rar5Reader$Lz;->applyFilter(Lcra/fork/Rar5Reader$Filter;[BJ)[B

    move-result-object v2

    .line 577
    iget-object v3, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v3}, Lcra/fork/Rar5Reader;->access$200(Lcra/fork/Rar5Reader;)Ljava/util/zip/CRC32;

    move-result-object v3

    array-length v4, v2

    invoke-virtual {v3, v2, v1, v4}, Ljava/util/zip/CRC32;->update([BII)V

    .line 578
    iget-object v3, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v3}, Lcra/fork/Rar5Reader;->access$300(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;

    move-result-object v3

    array-length v4, v2

    invoke-virtual {v3, v2, v1, v4}, Ljava/io/RandomAccessFile;->write([BII)V

    .line 579
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Filter;->start:J

    iget-wide v4, v0, Lcra/fork/Rar5Reader$Filter;->length:J

    add-long/2addr v2, v4

    iput-wide v2, p0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    .line 580
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    invoke-interface {v0, v1}, Ljava/util/List;->remove(I)Ljava/lang/Object;

    goto/16 :goto_0

    .line 567
    :cond_5
    new-instance v0, Ljava/io/IOException;

    const-string v1, "filter too large"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 561
    :cond_6
    new-instance v0, Ljava/io/IOException;

    const-string v1, "bad filter position"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_7
    return-void
.end method

.method private put(I)V
    .locals 5

    .line 507
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    iget-wide v1, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    iget v3, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    int-to-long v3, v3

    and-long/2addr v3, v1

    long-to-int v4, v3

    int-to-byte p1, p1

    aput-byte p1, v0, v4

    const-wide/16 v3, 0x1

    add-long/2addr v1, v3

    .line 508
    iput-wide v1, p0, Lcra/fork/Rar5Reader$Lz;->total:J

    return-void
.end method

.method private readDist()I
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 656
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tDist:[I

    invoke-direct {p0, v0}, Lcra/fork/Rar5Reader$Lz;->sym([I)I

    move-result v0

    const/4 v1, 0x4

    if-ge v0, v1, :cond_0

    add-int/lit8 v0, v0, 0x1

    return v0

    :cond_0
    shr-int/lit8 v2, v0, 0x1

    add-int/lit8 v2, v2, -0x1

    and-int/lit8 v0, v0, 0x1

    or-int/lit8 v0, v0, 0x2

    int-to-long v3, v0

    shl-long/2addr v3, v2

    const-wide/16 v5, 0x1

    add-long/2addr v3, v5

    if-lt v2, v1, :cond_2

    if-le v2, v1, :cond_1

    sub-int/2addr v2, v1

    .line 664
    invoke-virtual {p0, v2}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    shl-long v0, v5, v1

    add-long/2addr v3, v0

    .line 666
    :cond_1
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tLow:[I

    invoke-direct {p0, v0}, Lcra/fork/Rar5Reader$Lz;->sym([I)I

    move-result v0

    int-to-long v0, v0

    goto :goto_0

    .line 668
    :cond_2
    invoke-virtual {p0, v2}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v0

    :goto_0
    add-long/2addr v3, v0

    const-wide/32 v0, 0x7fffffff

    cmp-long v2, v3, v0

    if-gtz v2, :cond_3

    long-to-int v0, v3

    return v0

    .line 671
    :cond_3
    new-instance v0, Ljava/io/IOException;

    const-string v1, "bad distance"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private readTables()V
    .locals 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x14

    new-array v1, v0, [I

    const/4 v2, 0x0

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v0, :cond_3

    const/4 v4, 0x4

    .line 460
    invoke-virtual {p0, v4}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    const/16 v5, 0xf

    if-ne v6, v5, :cond_2

    .line 462
    invoke-virtual {p0, v4}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v6

    long-to-int v4, v6

    if-nez v4, :cond_0

    add-int/lit8 v4, v3, 0x1

    .line 464
    aput v5, v1, v3

    goto :goto_2

    :cond_0
    add-int/lit8 v4, v4, 0x2

    :goto_1
    add-int/lit8 v5, v4, -0x1

    if-lez v4, :cond_1

    if-ge v3, v0, :cond_1

    add-int/lit8 v4, v3, 0x1

    .line 468
    aput v2, v1, v3

    move v3, v4

    move v4, v5

    goto :goto_1

    :cond_1
    move v4, v3

    goto :goto_2

    :cond_2
    add-int/lit8 v4, v3, 0x1

    .line 472
    aput v6, v1, v3

    :goto_2
    move v3, v4

    goto :goto_0

    .line 475
    :cond_3
    invoke-direct {p0, v1, v2, v0}, Lcra/fork/Rar5Reader$Lz;->build([III)[I

    move-result-object v0

    const/16 v1, 0x1ae

    new-array v3, v1, [I

    const/4 v4, 0x0

    :cond_4
    :goto_3
    const/16 v5, 0x10

    if-ge v4, v1, :cond_a

    .line 479
    invoke-direct {p0, v0}, Lcra/fork/Rar5Reader$Lz;->sym([I)I

    move-result v6

    if-ge v6, v5, :cond_5

    add-int/lit8 v5, v4, 0x1

    .line 481
    aput v6, v3, v4

    move v4, v5

    goto :goto_3

    :cond_5
    const/4 v7, 0x7

    const/16 v8, 0x12

    const/4 v9, 0x3

    if-ge v6, v8, :cond_8

    if-eqz v4, :cond_7

    if-ne v6, v5, :cond_6

    .line 488
    invoke-virtual {p0, v9}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    add-int/2addr v6, v9

    goto :goto_4

    :cond_6
    invoke-virtual {p0, v7}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    add-int/lit8 v6, v6, 0xb

    :goto_4
    add-int/lit8 v5, v4, -0x1

    .line 489
    aget v5, v3, v5

    goto :goto_6

    .line 486
    :cond_7
    new-instance v0, Ljava/io/IOException;

    const-string v1, "bad table"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_8
    if-ne v6, v8, :cond_9

    .line 491
    invoke-virtual {p0, v9}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    add-int/2addr v6, v9

    goto :goto_5

    :cond_9
    invoke-virtual {p0, v7}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    add-int/lit8 v6, v6, 0xb

    :goto_5
    const/4 v5, 0x0

    :goto_6
    add-int/lit8 v7, v6, -0x1

    if-lez v6, :cond_4

    if-ge v4, v1, :cond_4

    add-int/lit8 v6, v4, 0x1

    .line 495
    aput v5, v3, v4

    move v4, v6

    move v6, v7

    goto :goto_6

    :cond_a
    const/16 v0, 0x132

    .line 499
    invoke-direct {p0, v3, v2, v0}, Lcra/fork/Rar5Reader$Lz;->build([III)[I

    move-result-object v1

    iput-object v1, p0, Lcra/fork/Rar5Reader$Lz;->tMain:[I

    const/16 v1, 0x40

    .line 500
    invoke-direct {p0, v3, v0, v1}, Lcra/fork/Rar5Reader$Lz;->build([III)[I

    move-result-object v0

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tDist:[I

    const/16 v0, 0x172

    .line 501
    invoke-direct {p0, v3, v0, v5}, Lcra/fork/Rar5Reader$Lz;->build([III)[I

    move-result-object v0

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tLow:[I

    const/16 v0, 0x182

    const/16 v1, 0x2c

    .line 502
    invoke-direct {p0, v3, v0, v1}, Lcra/fork/Rar5Reader$Lz;->build([III)[I

    move-result-object v0

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tRep:[I

    return-void
.end method

.method private sym([I)I
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0xf

    .line 449
    invoke-virtual {p0, v0}, Lcra/fork/Rar5Reader$Lz;->peek(I)I

    move-result v0

    aget p1, p1, v0

    if-eqz p1, :cond_0

    ushr-int/lit8 v0, p1, 0x10

    .line 453
    invoke-virtual {p0, v0}, Lcra/fork/Rar5Reader$Lz;->skip(I)V

    const v0, 0xffff

    and-int/2addr p1, v0

    return p1

    .line 451
    :cond_0
    new-instance p1, Ljava/io/IOException;

    const-string v0, "bad huffman code"

    invoke-direct {p1, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private write(JJ)V
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    :goto_0
    cmp-long v0, p1, p3

    if-gez v0, :cond_1

    .line 531
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    array-length v0, v0

    int-to-long v0, v0

    sub-long v2, p3, p1

    invoke-static {v0, v1, v2, v3}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v0

    long-to-int v1, v0

    .line 532
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->mask:I

    int-to-long v2, v0

    and-long/2addr v2, p1

    long-to-int v0, v2

    .line 533
    iget-object v2, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    array-length v2, v2

    sub-int/2addr v2, v0

    invoke-static {v1, v2}, Ljava/lang/Math;->min(II)I

    move-result v2

    .line 534
    iget-object v3, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    iget-object v4, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    const/4 v5, 0x0

    invoke-static {v3, v0, v4, v5, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    if-ge v2, v1, :cond_0

    .line 536
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->win:[B

    iget-object v3, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    sub-int v4, v1, v2

    invoke-static {v0, v5, v3, v2, v4}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 538
    :cond_0
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v0}, Lcra/fork/Rar5Reader;->access$200(Lcra/fork/Rar5Reader;)Ljava/util/zip/CRC32;

    move-result-object v0

    iget-object v2, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    invoke-virtual {v0, v2, v5, v1}, Ljava/util/zip/CRC32;->update([BII)V

    .line 539
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->this$0:Lcra/fork/Rar5Reader;

    invoke-static {v0}, Lcra/fork/Rar5Reader;->access$300(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;

    move-result-object v0

    iget-object v2, p0, Lcra/fork/Rar5Reader$Lz;->obuf:[B

    invoke-virtual {v0, v2, v5, v1}, Ljava/io/RandomAccessFile;->write([BII)V

    int-to-long v0, v1

    add-long/2addr p1, v0

    goto :goto_0

    :cond_1
    return-void
.end method


# virtual methods
.method align()V
    .locals 2

    .line 414
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    and-int/lit8 v1, v0, 0x7

    sub-int/2addr v0, v1

    iput v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    return-void
.end method

.method bitPos()J
    .locals 4

    .line 410
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    const-wide/16 v2, 0x8

    mul-long v0, v0, v2

    iget v2, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    int-to-long v2, v2

    sub-long/2addr v0, v2

    return-wide v0
.end method

.method bits(I)J
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-nez p1, :cond_0

    const-wide/16 v0, 0x0

    return-wide v0

    :cond_0
    const/16 v0, 0x19

    if-gt p1, v0, :cond_1

    .line 401
    invoke-virtual {p0, p1}, Lcra/fork/Rar5Reader$Lz;->peek(I)I

    move-result v0

    .line 402
    invoke-virtual {p0, p1}, Lcra/fork/Rar5Reader$Lz;->skip(I)V

    int-to-long v0, v0

    return-wide v0

    :cond_1
    const/16 v0, 0x10

    sub-int/2addr p1, v0

    .line 405
    invoke-virtual {p0, p1}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v1

    shl-long/2addr v1, v0

    .line 406
    invoke-virtual {p0, v0}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v3

    or-long v0, v1, v3

    return-wide v0
.end method

.method decode(Lcra/fork/Rar5Reader$Entry;)V
    .locals 17
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    .line 677
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->total:J

    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->fileBase:J

    .line 678
    iget-wide v4, v1, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    add-long/2addr v2, v4

    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->fileEnd:J

    .line 679
    iget-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->total:J

    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    .line 680
    iget-object v2, v0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 681
    iget-wide v2, v1, Lcra/fork/Rar5Reader$Entry;->dataSize:J

    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->regionEnd:J

    const-wide/16 v2, 0x0

    .line 682
    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->bytesRead:J

    .line 683
    iput-wide v2, v0, Lcra/fork/Rar5Reader$Lz;->acc:J

    const/4 v4, 0x0

    .line 684
    iput v4, v0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    .line 685
    iput v4, v0, Lcra/fork/Rar5Reader$Lz;->ilen:I

    iput v4, v0, Lcra/fork/Rar5Reader$Lz;->ipos:I

    .line 686
    iget-wide v5, v1, Lcra/fork/Rar5Reader$Entry;->dataPos:J

    iput-wide v5, v0, Lcra/fork/Rar5Reader$Lz;->fileInPos:J

    move-wide v5, v2

    const/4 v1, 0x0

    const/4 v7, 0x0

    .line 690
    :cond_0
    :goto_0
    iget-wide v8, v0, Lcra/fork/Rar5Reader$Lz;->total:J

    iget-wide v10, v0, Lcra/fork/Rar5Reader$Lz;->fileEnd:J

    cmp-long v12, v8, v10

    if-gez v12, :cond_12

    const/4 v8, 0x1

    if-eqz v1, :cond_a

    .line 691
    invoke-virtual/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->bitPos()J

    move-result-wide v9

    cmp-long v11, v9, v5

    if-ltz v11, :cond_1

    goto/16 :goto_3

    .line 720
    :cond_1
    iget-object v9, v0, Lcra/fork/Rar5Reader$Lz;->tMain:[I

    invoke-direct {v0, v9}, Lcra/fork/Rar5Reader$Lz;->sym([I)I

    move-result v9

    const/16 v10, 0x100

    if-ge v9, v10, :cond_2

    .line 722
    invoke-direct {v0, v9}, Lcra/fork/Rar5Reader$Lz;->put(I)V

    goto/16 :goto_2

    :cond_2
    const/4 v11, 0x3

    if-ne v9, v10, :cond_4

    .line 724
    new-instance v9, Lcra/fork/Rar5Reader$Filter;

    const/4 v10, 0x0

    invoke-direct {v9, v10}, Lcra/fork/Rar5Reader$Filter;-><init>(Lcra/fork/Rar5Reader$1;)V

    .line 725
    iget-wide v12, v0, Lcra/fork/Rar5Reader$Lz;->total:J

    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->filterData()J

    move-result-wide v14

    add-long/2addr v12, v14

    iput-wide v12, v9, Lcra/fork/Rar5Reader$Filter;->start:J

    .line 726
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->filterData()J

    move-result-wide v12

    iput-wide v12, v9, Lcra/fork/Rar5Reader$Filter;->length:J

    .line 727
    invoke-virtual {v0, v11}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v10

    long-to-int v11, v10

    iput v11, v9, Lcra/fork/Rar5Reader$Filter;->type:I

    .line 728
    iget v10, v9, Lcra/fork/Rar5Reader$Filter;->type:I

    if-nez v10, :cond_3

    const/4 v10, 0x5

    .line 729
    invoke-virtual {v0, v10}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v10

    long-to-int v11, v10

    add-int/2addr v11, v8

    iput v11, v9, Lcra/fork/Rar5Reader$Filter;->channels:I

    .line 731
    :cond_3
    iget-object v8, v0, Lcra/fork/Rar5Reader$Lz;->filters:Ljava/util/List;

    invoke-interface {v8, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_2

    :cond_4
    const/16 v12, 0x101

    if-ne v9, v12, :cond_5

    .line 733
    iget v8, v0, Lcra/fork/Rar5Reader$Lz;->lastLen:I

    if-lez v8, :cond_9

    .line 734
    iget-object v9, v0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    aget v9, v9, v4

    invoke-direct {v0, v8, v9}, Lcra/fork/Rar5Reader$Lz;->copy(II)V

    goto :goto_2

    :cond_5
    const/16 v12, 0x106

    if-ge v9, v12, :cond_7

    add-int/lit16 v9, v9, -0x102

    .line 738
    iget-object v8, v0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    aget v8, v8, v9

    :goto_1
    if-lez v9, :cond_6

    .line 740
    iget-object v10, v0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    add-int/lit8 v11, v9, -0x1

    aget v11, v10, v11

    aput v11, v10, v9

    add-int/lit8 v9, v9, -0x1

    goto :goto_1

    .line 742
    :cond_6
    iget-object v9, v0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    aput v8, v9, v4

    .line 743
    iget-object v9, v0, Lcra/fork/Rar5Reader$Lz;->tRep:[I

    invoke-direct {v0, v9}, Lcra/fork/Rar5Reader$Lz;->sym([I)I

    move-result v9

    invoke-direct {v0, v9}, Lcra/fork/Rar5Reader$Lz;->lenFromSlot(I)I

    move-result v9

    .line 744
    iput v9, v0, Lcra/fork/Rar5Reader$Lz;->lastLen:I

    .line 745
    invoke-direct {v0, v9, v8}, Lcra/fork/Rar5Reader$Lz;->copy(II)V

    goto :goto_2

    :cond_7
    add-int/lit16 v9, v9, -0x106

    .line 747
    invoke-direct {v0, v9}, Lcra/fork/Rar5Reader$Lz;->lenFromSlot(I)I

    move-result v9

    .line 748
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->readDist()I

    move-result v12

    if-le v12, v10, :cond_8

    add-int/lit8 v9, v9, 0x1

    const/16 v10, 0x2000

    if-le v12, v10, :cond_8

    add-int/lit8 v9, v9, 0x1

    const/high16 v10, 0x40000

    if-le v12, v10, :cond_8

    add-int/lit8 v9, v9, 0x1

    .line 758
    :cond_8
    iget-object v10, v0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    const/4 v13, 0x2

    aget v14, v10, v13

    aput v14, v10, v11

    .line 759
    aget v11, v10, v8

    aput v11, v10, v13

    .line 760
    aget v11, v10, v4

    aput v11, v10, v8

    .line 761
    aput v12, v10, v4

    .line 762
    iput v9, v0, Lcra/fork/Rar5Reader$Lz;->lastLen:I

    .line 763
    invoke-direct {v0, v9, v12}, Lcra/fork/Rar5Reader$Lz;->copy(II)V

    .line 765
    :cond_9
    :goto_2
    iget-wide v8, v0, Lcra/fork/Rar5Reader$Lz;->total:J

    iget-wide v10, v0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    sub-long/2addr v8, v10

    const-wide/32 v10, 0x10000

    cmp-long v12, v8, v10

    if-ltz v12, :cond_0

    .line 766
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->process()V

    goto/16 :goto_0

    :cond_a
    :goto_3
    if-eqz v1, :cond_c

    if-nez v7, :cond_b

    goto :goto_4

    .line 693
    :cond_b
    new-instance v1, Ljava/io/IOException;

    const-string v2, "data ended early"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 695
    :cond_c
    :goto_4
    invoke-virtual/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->align()V

    const/16 v1, 0x8

    .line 696
    invoke-virtual {v0, v1}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v5

    long-to-int v6, v5

    .line 697
    invoke-virtual {v0, v1}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v9

    long-to-int v5, v9

    shr-int/lit8 v7, v6, 0x3

    and-int/lit8 v7, v7, 0x7

    add-int/2addr v7, v8

    xor-int/lit8 v9, v6, 0x5a

    move-wide v11, v2

    const/4 v10, 0x0

    :goto_5
    if-ge v10, v7, :cond_d

    .line 702
    invoke-virtual {v0, v1}, Lcra/fork/Rar5Reader$Lz;->bits(I)J

    move-result-wide v13

    long-to-int v14, v13

    xor-int/2addr v9, v14

    int-to-long v13, v14

    mul-int/lit8 v15, v10, 0x8

    shl-long/2addr v13, v15

    or-long/2addr v11, v13

    add-int/lit8 v10, v10, 0x1

    goto :goto_5

    :cond_d
    and-int/lit16 v1, v9, 0xff

    if-ne v1, v5, :cond_11

    and-int/lit8 v1, v6, 0x40

    if-eqz v1, :cond_e

    const/4 v7, 0x1

    goto :goto_6

    :cond_e
    const/4 v7, 0x0

    .line 710
    :goto_6
    invoke-virtual/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->bitPos()J

    move-result-wide v9

    const-wide/16 v13, 0x1

    sub-long/2addr v11, v13

    const-wide/16 v15, 0x8

    mul-long v11, v11, v15

    add-long/2addr v9, v11

    and-int/lit8 v1, v6, 0x7

    int-to-long v11, v1

    add-long/2addr v9, v11

    add-long/2addr v9, v13

    and-int/lit16 v1, v6, 0x80

    if-eqz v1, :cond_f

    .line 714
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->readTables()V

    goto :goto_7

    .line 715
    :cond_f
    iget-object v1, v0, Lcra/fork/Rar5Reader$Lz;->tMain:[I

    if-eqz v1, :cond_10

    :goto_7
    move-wide v5, v9

    const/4 v1, 0x1

    goto/16 :goto_0

    .line 716
    :cond_10
    new-instance v1, Ljava/io/IOException;

    const-string v2, "missing tables"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 707
    :cond_11
    new-instance v1, Ljava/io/IOException;

    const-string v2, "bad block header"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 769
    :cond_12
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader$Lz;->process()V

    .line 770
    iget-wide v1, v0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    iget-wide v3, v0, Lcra/fork/Rar5Reader$Lz;->fileEnd:J

    cmp-long v5, v1, v3

    if-eqz v5, :cond_13

    .line 772
    invoke-direct {v0, v1, v2, v3, v4}, Lcra/fork/Rar5Reader$Lz;->write(JJ)V

    .line 773
    iget-wide v1, v0, Lcra/fork/Rar5Reader$Lz;->fileEnd:J

    iput-wide v1, v0, Lcra/fork/Rar5Reader$Lz;->flushed:J

    :cond_13
    return-void
.end method

.method peek(I)I
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 386
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    if-ge v0, p1, :cond_0

    .line 387
    invoke-direct {p0}, Lcra/fork/Rar5Reader$Lz;->fill()V

    .line 389
    :cond_0
    iget-wide v0, p0, Lcra/fork/Rar5Reader$Lz;->acc:J

    iget v2, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    sub-int/2addr v2, p1

    ushr-long/2addr v0, v2

    const-wide/16 v2, 0x1

    shl-long v4, v2, p1

    sub-long/2addr v4, v2

    and-long/2addr v0, v4

    long-to-int p1, v0

    return p1
.end method

.method reset()V
    .locals 2

    .line 355
    iget-object v0, p0, Lcra/fork/Rar5Reader$Lz;->reps:[I

    const/4 v1, 0x0

    invoke-static {v0, v1}, Ljava/util/Arrays;->fill([II)V

    .line 356
    iput v1, p0, Lcra/fork/Rar5Reader$Lz;->lastLen:I

    const/4 v0, 0x0

    .line 357
    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tRep:[I

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tLow:[I

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tDist:[I

    iput-object v0, p0, Lcra/fork/Rar5Reader$Lz;->tMain:[I

    return-void
.end method

.method skip(I)V
    .locals 1

    .line 393
    iget v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    sub-int/2addr v0, p1

    iput v0, p0, Lcra/fork/Rar5Reader$Lz;->nbits:I

    return-void
.end method
