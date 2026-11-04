.class final Lcra/fork/Rar5Reader;
.super Ljava/lang/Object;
.source "Rar5Reader.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcra/fork/Rar5Reader$Entry;,
        Lcra/fork/Rar5Reader$Lz;,
        Lcra/fork/Rar5Reader$Filter;
    }
.end annotation


# static fields
.field private static final BC:I = 0x14

.field private static final NC:I = 0x132

.field private static final NDC:I = 0x40

.field private static final NLDC:I = 0x10

.field private static final NRC:I = 0x2c

.field private static final SIG:[I

.field private static final TABLE_BITS:I = 0xf


# instance fields
.field private final crc:Ljava/util/zip/CRC32;

.field private final in:Ljava/io/RandomAccessFile;

.field private final out:Ljava/io/RandomAccessFile;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/16 v0, 0x8

    new-array v0, v0, [I

    .line 12
    fill-array-data v0, :array_0

    sput-object v0, Lcra/fork/Rar5Reader;->SIG:[I

    return-void

    :array_0
    .array-data 4
        0x52
        0x61
        0x72
        0x21
        0x1a
        0x7
        0x1
        0x0
    .end array-data
.end method

.method private constructor <init>(Ljava/io/RandomAccessFile;Ljava/io/RandomAccessFile;)V
    .locals 1

    .line 47
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 45
    new-instance v0, Ljava/util/zip/CRC32;

    invoke-direct {v0}, Ljava/util/zip/CRC32;-><init>()V

    iput-object v0, p0, Lcra/fork/Rar5Reader;->crc:Ljava/util/zip/CRC32;

    .line 48
    iput-object p1, p0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    .line 49
    iput-object p2, p0, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    return-void
.end method

.method static synthetic access$100(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;
    .locals 0

    .line 11
    iget-object p0, p0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    return-object p0
.end method

.method static synthetic access$200(Lcra/fork/Rar5Reader;)Ljava/util/zip/CRC32;
    .locals 0

    .line 11
    iget-object p0, p0, Lcra/fork/Rar5Reader;->crc:Ljava/util/zip/CRC32;

    return-object p0
.end method

.method static synthetic access$300(Lcra/fork/Rar5Reader;)Ljava/io/RandomAccessFile;
    .locals 0

    .line 11
    iget-object p0, p0, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    return-object p0
.end method

.method static synthetic access$400([BI)J
    .locals 0

    .line 11
    invoke-static {p0, p1}, Lcra/fork/Rar5Reader;->u32([BI)J

    move-result-wide p0

    return-wide p0
.end method

.method static synthetic access$500([BIJ)V
    .locals 0

    .line 11
    invoke-static {p0, p1, p2, p3}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    return-void
.end method

.method static convert(Ljava/io/File;Ljava/io/File;)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 53
    new-instance v0, Ljava/io/RandomAccessFile;

    const-string v1, "r"

    invoke-direct {v0, p0, v1}, Ljava/io/RandomAccessFile;-><init>(Ljava/io/File;Ljava/lang/String;)V

    const/4 p0, 0x0

    .line 56
    :try_start_0
    new-instance v1, Ljava/io/RandomAccessFile;

    const-string v2, "rw"

    invoke-direct {v1, p1, v2}, Ljava/io/RandomAccessFile;-><init>(Ljava/io/File;Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    const-wide/16 p0, 0x0

    .line 57
    :try_start_1
    invoke-virtual {v1, p0, p1}, Ljava/io/RandomAccessFile;->setLength(J)V

    .line 58
    new-instance p0, Lcra/fork/Rar5Reader;

    invoke-direct {p0, v0, v1}, Lcra/fork/Rar5Reader;-><init>(Ljava/io/RandomAccessFile;Ljava/io/RandomAccessFile;)V

    invoke-direct {p0}, Lcra/fork/Rar5Reader;->run()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 60
    invoke-virtual {v0}, Ljava/io/RandomAccessFile;->close()V

    .line 62
    invoke-virtual {v1}, Ljava/io/RandomAccessFile;->close()V

    return-void

    :catchall_0
    move-exception p0

    goto :goto_0

    :catchall_1
    move-exception p1

    move-object v1, p0

    move-object p0, p1

    .line 60
    :goto_0
    invoke-virtual {v0}, Ljava/io/RandomAccessFile;->close()V

    if-eqz v1, :cond_0

    .line 62
    invoke-virtual {v1}, Ljava/io/RandomAccessFile;->close()V

    .line 64
    :cond_0
    throw p0
.end method

.method private copyStored(Lcra/fork/Rar5Reader$Entry;)V
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 301
    iget-wide v0, p1, Lcra/fork/Rar5Reader$Entry;->dataSize:J

    iget-wide v2, p1, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    cmp-long v4, v0, v2

    if-nez v4, :cond_2

    .line 304
    iget-object v0, p0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    iget-wide v1, p1, Lcra/fork/Rar5Reader$Entry;->dataPos:J

    invoke-virtual {v0, v1, v2}, Ljava/io/RandomAccessFile;->seek(J)V

    const/high16 v0, 0x10000

    new-array v1, v0, [B

    .line 306
    iget-wide v2, p1, Lcra/fork/Rar5Reader$Entry;->dataSize:J

    :goto_0
    const-wide/16 v4, 0x0

    cmp-long p1, v2, v4

    if-lez p1, :cond_1

    .line 308
    iget-object p1, p0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    int-to-long v4, v0

    invoke-static {v4, v5, v2, v3}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v4

    long-to-int v5, v4

    const/4 v4, 0x0

    invoke-virtual {p1, v1, v4, v5}, Ljava/io/RandomAccessFile;->read([BII)I

    move-result p1

    if-lez p1, :cond_0

    .line 312
    iget-object v5, p0, Lcra/fork/Rar5Reader;->crc:Ljava/util/zip/CRC32;

    invoke-virtual {v5, v1, v4, p1}, Ljava/util/zip/CRC32;->update([BII)V

    .line 313
    iget-object v5, p0, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {v5, v1, v4, p1}, Ljava/io/RandomAccessFile;->write([BII)V

    int-to-long v4, p1

    sub-long/2addr v2, v4

    goto :goto_0

    .line 310
    :cond_0
    new-instance p1, Ljava/io/IOException;

    const-string v0, "truncated data"

    invoke-direct {p1, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_1
    return-void

    .line 302
    :cond_2
    new-instance p1, Ljava/io/IOException;

    const-string v0, "stored size mismatch"

    invoke-direct {p1, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method static isSignature([B)Z
    .locals 5

    .line 18
    array-length v0, p0

    const/4 v1, 0x0

    const/16 v2, 0x8

    if-ge v0, v2, :cond_0

    return v1

    :cond_0
    const/4 v0, 0x0

    :goto_0
    if-ge v0, v2, :cond_2

    .line 22
    aget-byte v3, p0, v0

    and-int/lit16 v3, v3, 0xff

    sget-object v4, Lcra/fork/Rar5Reader;->SIG:[I

    aget v4, v4, v0

    if-eq v3, v4, :cond_1

    return v1

    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_2
    const/4 p0, 0x1

    return p0
.end method

.method private static nextPow2(J)J
    .locals 5

    const-wide/16 v0, 0x1

    :goto_0
    cmp-long v2, v0, p0

    if-gez v2, :cond_0

    const-wide v2, 0x10000000000L

    cmp-long v4, v0, v2

    if-gez v4, :cond_0

    const/4 v2, 0x1

    shl-long/2addr v0, v2

    goto :goto_0

    :cond_0
    return-wide v0
.end method

.method private static put32([BIJ)V
    .locals 3

    long-to-int v0, p2

    int-to-byte v0, v0

    .line 270
    aput-byte v0, p0, p1

    add-int/lit8 v0, p1, 0x1

    const/16 v1, 0x8

    shr-long v1, p2, v1

    long-to-int v2, v1

    int-to-byte v1, v2

    .line 271
    aput-byte v1, p0, v0

    add-int/lit8 v0, p1, 0x2

    const/16 v1, 0x10

    shr-long v1, p2, v1

    long-to-int v2, v1

    int-to-byte v1, v2

    .line 272
    aput-byte v1, p0, v0

    add-int/lit8 p1, p1, 0x3

    const/16 v0, 0x18

    shr-long/2addr p2, v0

    long-to-int p3, p2

    int-to-byte p2, p3

    .line 273
    aput-byte p2, p0, p1

    return-void
.end method

.method private putCrc16([BI)V
    .locals 4

    .line 262
    new-instance v0, Ljava/util/zip/CRC32;

    invoke-direct {v0}, Ljava/util/zip/CRC32;-><init>()V

    const/4 v1, 0x2

    sub-int/2addr p2, v1

    .line 263
    invoke-virtual {v0, p1, v1, p2}, Ljava/util/zip/CRC32;->update([BII)V

    .line 264
    invoke-virtual {v0}, Ljava/util/zip/CRC32;->getValue()J

    move-result-wide v0

    const-wide/32 v2, 0xffff

    and-long/2addr v0, v2

    long-to-int p2, v0

    const/4 v0, 0x0

    int-to-byte v1, p2

    .line 265
    aput-byte v1, p1, v0

    shr-int/lit8 p2, p2, 0x8

    int-to-byte p2, p2

    const/4 v0, 0x1

    .line 266
    aput-byte p2, p1, v0

    return-void
.end method

.method private readEntries()Ljava/util/List;
    .locals 35
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lcra/fork/Rar5Reader$Entry;",
            ">;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p0

    .line 87
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    const/16 v2, 0x8

    new-array v2, v2, [B

    .line 89
    iget-object v3, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    const-wide/16 v4, 0x0

    invoke-virtual {v3, v4, v5}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 90
    iget-object v3, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v3, v2}, Ljava/io/RandomAccessFile;->readFully([B)V

    .line 91
    invoke-static {v2}, Lcra/fork/Rar5Reader;->isSignature([B)Z

    move-result v2

    if-eqz v2, :cond_13

    .line 95
    iget-object v2, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v2}, Ljava/io/RandomAccessFile;->length()J

    move-result-wide v2

    const-wide/16 v8, 0x8

    :goto_0
    const-wide/16 v10, 0x7

    add-long v12, v8, v10

    cmp-long v14, v12, v2

    if-gtz v14, :cond_12

    .line 97
    iget-object v12, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v12, v8, v9}, Ljava/io/RandomAccessFile;->seek(J)V

    const/4 v12, 0x7

    new-array v13, v12, [B

    .line 99
    iget-object v14, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v14, v13}, Ljava/io/RandomAccessFile;->read([B)I

    move-result v14

    const/4 v15, 0x6

    if-ge v14, v15, :cond_0

    goto/16 :goto_9

    :cond_0
    const/4 v14, 0x4

    .line 104
    filled-new-array {v14}, [I

    move-result-object v15

    const/16 v17, 0x0

    .line 107
    :try_start_0
    invoke-direct {v0, v13, v15}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v18
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    move-wide/from16 v10, v18

    goto :goto_1

    :catch_0
    const/16 v13, 0xe

    new-array v13, v13, [B

    .line 111
    iget-object v10, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v10, v8, v9}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 112
    iget-object v10, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v10, v13}, Ljava/io/RandomAccessFile;->read([B)I

    .line 113
    aput v14, v15, v17

    .line 114
    invoke-direct {v0, v13, v15}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v10

    .line 116
    :goto_1
    aget v13, v15, v17

    int-to-long v12, v13

    add-long/2addr v8, v12

    cmp-long v12, v10, v4

    if-lez v12, :cond_11

    const-wide/32 v12, 0x100000

    cmp-long v20, v10, v12

    if-gtz v20, :cond_11

    add-long v12, v8, v10

    cmp-long v20, v12, v2

    if-gtz v20, :cond_11

    long-to-int v11, v10

    .line 120
    new-array v10, v11, [B

    .line 121
    iget-object v15, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v15, v8, v9}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 122
    iget-object v8, v0, Lcra/fork/Rar5Reader;->in:Ljava/io/RandomAccessFile;

    invoke-virtual {v8, v10}, Ljava/io/RandomAccessFile;->readFully([B)V

    .line 123
    filled-new-array/range {v17 .. v17}, [I

    move-result-object v8

    .line 124
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v21

    .line 125
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v23

    const-wide/16 v25, 0x1

    and-long v27, v23, v25

    cmp-long v9, v27, v4

    if-eqz v9, :cond_1

    .line 128
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v27

    move-wide/from16 v29, v27

    goto :goto_2

    :cond_1
    move-wide/from16 v29, v4

    :goto_2
    const-wide/16 v27, 0x2

    and-long v31, v23, v27

    cmp-long v9, v31, v4

    if-eqz v9, :cond_2

    .line 131
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v31

    move-wide/from16 v33, v31

    goto :goto_3

    :cond_2
    move-wide/from16 v33, v4

    :goto_3
    const-wide/16 v31, 0x5

    cmp-long v9, v21, v31

    if-nez v9, :cond_3

    goto/16 :goto_9

    :cond_3
    const-wide/16 v31, 0x4

    cmp-long v9, v21, v31

    if-eqz v9, :cond_10

    cmp-long v9, v21, v27

    if-nez v9, :cond_f

    const-wide/16 v21, 0x18

    and-long v21, v23, v21

    cmp-long v9, v21, v4

    if-nez v9, :cond_e

    .line 144
    new-instance v9, Lcra/fork/Rar5Reader$Entry;

    const/4 v15, 0x0

    invoke-direct {v9, v15}, Lcra/fork/Rar5Reader$Entry;-><init>(Lcra/fork/Rar5Reader$1;)V

    .line 145
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v21

    .line 146
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v6

    iput-wide v6, v9, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    .line 147
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    and-long v6, v21, v27

    cmp-long v15, v6, v4

    if-eqz v15, :cond_4

    .line 149
    aget v6, v8, v17

    add-int/2addr v6, v14

    aput v6, v8, v17

    :cond_4
    and-long v6, v21, v31

    cmp-long v15, v6, v4

    if-eqz v15, :cond_5

    .line 152
    aget v6, v8, v17

    invoke-static {v10, v6}, Lcra/fork/Rar5Reader;->u32([BI)J

    move-result-wide v6

    iput-wide v6, v9, Lcra/fork/Rar5Reader$Entry;->crc:J

    .line 153
    aget v6, v8, v17

    add-int/2addr v6, v14

    aput v6, v8, v17

    .line 155
    :cond_5
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v6

    .line 156
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    .line 157
    invoke-direct {v0, v10, v8}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v14

    long-to-int v15, v14

    .line 158
    aget v14, v8, v17

    add-int v4, v14, v15

    if-gt v4, v11, :cond_d

    .line 161
    new-instance v4, Ljava/lang/String;

    const-string v5, "UTF-8"

    invoke-direct {v4, v10, v14, v15, v5}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V

    iput-object v4, v9, Lcra/fork/Rar5Reader$Entry;->name:Ljava/lang/String;

    .line 162
    aget v4, v8, v17

    add-int/2addr v4, v15

    aput v4, v8, v17

    and-long v4, v21, v25

    const/4 v8, 0x1

    const-wide/16 v14, 0x0

    cmp-long v27, v4, v14

    if-eqz v27, :cond_6

    const/4 v4, 0x1

    goto :goto_4

    :cond_6
    const/4 v4, 0x0

    .line 163
    :goto_4
    iput-boolean v4, v9, Lcra/fork/Rar5Reader$Entry;->dir:Z

    const-wide/16 v4, 0x8

    and-long v21, v21, v4

    cmp-long v23, v21, v14

    if-nez v23, :cond_c

    const/16 v20, 0x7

    shr-long v20, v6, v20

    const-wide/16 v18, 0x7

    and-long v4, v20, v18

    long-to-int v5, v4

    .line 167
    iput v5, v9, Lcra/fork/Rar5Reader$Entry;->method:I

    const/4 v4, 0x6

    shr-long v4, v6, v4

    and-long v4, v4, v25

    cmp-long v16, v4, v14

    if-eqz v16, :cond_7

    const/4 v4, 0x1

    goto :goto_5

    :cond_7
    const/4 v4, 0x0

    .line 168
    :goto_5
    iput-boolean v4, v9, Lcra/fork/Rar5Reader$Entry;->solid:Z

    const-wide/16 v4, 0x3f

    and-long/2addr v4, v6

    long-to-int v5, v4

    const/16 v4, 0xa

    shr-long v18, v6, v4

    const-wide/16 v20, 0xf

    and-long v14, v18, v20

    long-to-int v4, v14

    const-wide/32 v14, 0x20000

    shl-long/2addr v14, v4

    .line 171
    iput-wide v14, v9, Lcra/fork/Rar5Reader$Entry;->dict:J

    if-ne v5, v8, :cond_8

    .line 173
    iget-wide v4, v9, Lcra/fork/Rar5Reader$Entry;->dict:J

    const-wide/16 v18, 0x20

    div-long v14, v14, v18

    const/16 v8, 0xf

    shr-long/2addr v6, v8

    const-wide/16 v18, 0x1f

    and-long v6, v6, v18

    mul-long v14, v14, v6

    add-long/2addr v4, v14

    iput-wide v4, v9, Lcra/fork/Rar5Reader$Entry;->dict:J

    goto :goto_6

    :cond_8
    if-nez v5, :cond_b

    :goto_6
    move-wide/from16 v4, v29

    long-to-int v5, v4

    sub-int v4, v11, v5

    .line 179
    filled-new-array {v4}, [I

    move-result-object v4

    .line 180
    :goto_7
    aget v5, v4, v17

    if-ge v5, v11, :cond_a

    .line 181
    invoke-direct {v0, v10, v4}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v5

    .line 182
    aget v7, v4, v17

    long-to-int v6, v5

    add-int/2addr v7, v6

    .line 183
    invoke-direct {v0, v10, v4}, Lcra/fork/Rar5Reader;->vint([B[I)J

    move-result-wide v5

    cmp-long v8, v5, v25

    if-eqz v8, :cond_9

    .line 187
    aput v7, v4, v17

    goto :goto_7

    .line 185
    :cond_9
    new-instance v1, Ljava/io/IOException;

    const-string v2, "encrypted files are not supported"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 189
    :cond_a
    iput-wide v12, v9, Lcra/fork/Rar5Reader$Entry;->dataPos:J

    move-wide/from16 v6, v33

    .line 190
    iput-wide v6, v9, Lcra/fork/Rar5Reader$Entry;->dataSize:J

    .line 191
    invoke-interface {v1, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_8

    .line 175
    :cond_b
    new-instance v1, Ljava/io/IOException;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "unsupported compression version "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 165
    :cond_c
    new-instance v1, Ljava/io/IOException;

    const-string v2, "unknown unpacked size"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 159
    :cond_d
    new-instance v1, Ljava/io/IOException;

    const-string v2, "bad name"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 142
    :cond_e
    new-instance v1, Ljava/io/IOException;

    const-string v2, "multi-volume archives are not supported"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    :cond_f
    move-wide/from16 v6, v33

    :goto_8
    add-long v8, v12, v6

    const-wide/16 v4, 0x0

    goto/16 :goto_0

    .line 138
    :cond_10
    new-instance v1, Ljava/io/IOException;

    const-string v2, "encrypted headers"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 118
    :cond_11
    new-instance v1, Ljava/io/IOException;

    const-string v2, "bad header size"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1

    :cond_12
    :goto_9
    return-object v1

    .line 92
    :cond_13
    new-instance v1, Ljava/io/IOException;

    const-string v2, "not RAR5"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private run()V
    .locals 25
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v8, p0

    .line 199
    invoke-direct/range {p0 .. p0}, Lcra/fork/Rar5Reader;->readEntries()Ljava/util/List;

    move-result-object v0

    .line 201
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    const-wide/16 v9, 0x0

    move-wide v11, v9

    move-wide v13, v11

    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcra/fork/Rar5Reader$Entry;

    .line 202
    iget-boolean v3, v2, Lcra/fork/Rar5Reader$Entry;->dir:Z

    if-nez v3, :cond_0

    .line 203
    iget-wide v3, v2, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    add-long/2addr v11, v3

    .line 204
    iget v3, v2, Lcra/fork/Rar5Reader$Entry;->method:I

    if-eqz v3, :cond_0

    iget-wide v3, v2, Lcra/fork/Rar5Reader$Entry;->dict:J

    cmp-long v5, v3, v13

    if-lez v5, :cond_0

    .line 205
    iget-wide v13, v2, Lcra/fork/Rar5Reader$Entry;->dict:J

    goto :goto_0

    .line 209
    :cond_1
    iget-object v1, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    const/4 v15, 0x7

    new-array v2, v15, [B

    fill-array-data v2, :array_0

    invoke-virtual {v1, v2}, Ljava/io/RandomAccessFile;->write([B)V

    const/16 v1, 0xd

    new-array v2, v1, [B

    const/4 v3, 0x2

    const/16 v4, 0x73

    aput-byte v4, v2, v3

    const/4 v3, 0x5

    aput-byte v1, v2, v3

    .line 214
    invoke-direct {v8, v2, v1}, Lcra/fork/Rar5Reader;->putCrc16([BI)V

    .line 215
    iget-object v1, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {v1, v2}, Ljava/io/RandomAccessFile;->write([B)V

    .line 218
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v16

    const/4 v0, 0x0

    move-object/from16 v17, v0

    :goto_1
    invoke-interface/range {v16 .. v16}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_9

    invoke-interface/range {v16 .. v16}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    move-object v6, v0

    check-cast v6, Lcra/fork/Rar5Reader$Entry;

    .line 219
    iget-boolean v0, v6, Lcra/fork/Rar5Reader$Entry;->dir:Z

    if-eqz v0, :cond_2

    goto :goto_1

    .line 222
    :cond_2
    iget-wide v0, v6, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    const-wide v2, 0xffffffffL

    cmp-long v4, v0, v2

    if-gez v4, :cond_8

    iget-wide v0, v6, Lcra/fork/Rar5Reader$Entry;->dataSize:J

    cmp-long v4, v0, v2

    if-gez v4, :cond_8

    .line 225
    iget-object v0, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {v0}, Ljava/io/RandomAccessFile;->getFilePointer()J

    move-result-wide v4

    .line 226
    iget-object v0, v6, Lcra/fork/Rar5Reader$Entry;->name:Ljava/lang/String;

    const-string v1, "UTF-8"

    invoke-virtual {v0, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v18

    .line 227
    iget-wide v1, v6, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    const-wide/16 v19, 0x0

    move-object/from16 v0, p0

    move-wide/from16 v21, v1

    move-wide v1, v4

    move-object/from16 v3, v18

    move-wide/from16 v23, v4

    move-wide/from16 v4, v21

    move-object v15, v6

    move-wide/from16 v6, v19

    invoke-direct/range {v0 .. v7}, Lcra/fork/Rar5Reader;->writeFileHeader(J[BJJ)V

    .line 228
    iget-object v0, v8, Lcra/fork/Rar5Reader;->crc:Ljava/util/zip/CRC32;

    invoke-virtual {v0}, Ljava/util/zip/CRC32;->reset()V

    .line 229
    iget v0, v15, Lcra/fork/Rar5Reader$Entry;->method:I

    if-nez v0, :cond_3

    .line 230
    invoke-direct {v8, v15}, Lcra/fork/Rar5Reader;->copyStored(Lcra/fork/Rar5Reader$Entry;)V

    goto :goto_3

    :cond_3
    if-nez v17, :cond_4

    const-wide/16 v0, 0x1

    .line 233
    invoke-static {v11, v12, v0, v1}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcra/fork/Rar5Reader;->nextPow2(J)J

    move-result-wide v0

    invoke-static {v13, v14, v0, v1}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v0

    const-wide/32 v2, 0x10000

    invoke-static {v2, v3, v0, v1}, Ljava/lang/Math;->max(JJ)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcra/fork/Rar5Reader;->nextPow2(J)J

    move-result-wide v0

    .line 234
    new-instance v2, Lcra/fork/Rar5Reader$Lz;

    const-wide/32 v3, 0x40000000

    invoke-static {v0, v1, v3, v4}, Ljava/lang/Math;->min(JJ)J

    move-result-wide v0

    long-to-int v1, v0

    invoke-direct {v2, v8, v1}, Lcra/fork/Rar5Reader$Lz;-><init>(Lcra/fork/Rar5Reader;I)V

    goto :goto_2

    :cond_4
    move-object/from16 v2, v17

    .line 236
    :goto_2
    iget-boolean v0, v15, Lcra/fork/Rar5Reader$Entry;->solid:Z

    if-nez v0, :cond_5

    .line 237
    invoke-virtual {v2}, Lcra/fork/Rar5Reader$Lz;->reset()V

    .line 239
    :cond_5
    invoke-virtual {v2, v15}, Lcra/fork/Rar5Reader$Lz;->decode(Lcra/fork/Rar5Reader$Entry;)V

    move-object/from16 v17, v2

    .line 241
    :goto_3
    iget-object v0, v8, Lcra/fork/Rar5Reader;->crc:Ljava/util/zip/CRC32;

    invoke-virtual {v0}, Ljava/util/zip/CRC32;->getValue()J

    move-result-wide v6

    .line 242
    iget-wide v0, v15, Lcra/fork/Rar5Reader$Entry;->crc:J

    cmp-long v2, v0, v9

    if-ltz v2, :cond_7

    iget-wide v0, v15, Lcra/fork/Rar5Reader$Entry;->crc:J

    cmp-long v2, v0, v6

    if-nez v2, :cond_6

    goto :goto_4

    .line 243
    :cond_6
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "CRC error in "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v2, v15, Lcra/fork/Rar5Reader$Entry;->name:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 245
    :cond_7
    :goto_4
    iget-object v0, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {v0}, Ljava/io/RandomAccessFile;->getFilePointer()J

    move-result-wide v4

    .line 246
    iget-object v0, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    move-wide/from16 v1, v23

    invoke-virtual {v0, v1, v2}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 247
    iget-wide v9, v15, Lcra/fork/Rar5Reader$Entry;->unpackedSize:J

    move-object/from16 v0, p0

    move-object/from16 v3, v18

    move-wide/from16 v22, v11

    move-wide v11, v4

    move-wide v4, v9

    invoke-direct/range {v0 .. v7}, Lcra/fork/Rar5Reader;->writeFileHeader(J[BJJ)V

    .line 248
    iget-object v0, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {v0, v11, v12}, Ljava/io/RandomAccessFile;->seek(J)V

    move-wide/from16 v11, v22

    const-wide/16 v9, 0x0

    const/4 v15, 0x7

    goto/16 :goto_1

    .line 223
    :cond_8
    new-instance v0, Ljava/io/IOException;

    const-string v1, "file too large"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 250
    :cond_9
    iget-object v0, v8, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    const/4 v1, 0x7

    new-array v1, v1, [B

    fill-array-data v1, :array_1

    invoke-virtual {v0, v1}, Ljava/io/RandomAccessFile;->write([B)V

    return-void

    nop

    :array_0
    .array-data 1
        0x52t
        0x61t
        0x72t
        0x21t
        0x1at
        0x7t
        0x0t
    .end array-data

    :array_1
    .array-data 1
        -0x3ct
        0x3dt
        0x7bt
        0x0t
        0x40t
        0x7t
        0x0t
    .end array-data
.end method

.method private static u32([BI)J
    .locals 7

    .line 83
    aget-byte v0, p0, p1

    int-to-long v0, v0

    const-wide/16 v2, 0xff

    and-long/2addr v0, v2

    add-int/lit8 v4, p1, 0x1

    aget-byte v4, p0, v4

    int-to-long v4, v4

    and-long/2addr v4, v2

    const/16 v6, 0x8

    shl-long/2addr v4, v6

    or-long/2addr v0, v4

    add-int/lit8 v4, p1, 0x2

    aget-byte v4, p0, v4

    int-to-long v4, v4

    and-long/2addr v4, v2

    const/16 v6, 0x10

    shl-long/2addr v4, v6

    or-long/2addr v0, v4

    add-int/lit8 p1, p1, 0x3

    aget-byte p0, p0, p1

    int-to-long p0, p0

    and-long/2addr p0, v2

    const/16 v2, 0x18

    shl-long/2addr p0, v2

    or-long/2addr p0, v0

    return-wide p0
.end method

.method private vint([B[I)J
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const-wide/16 v0, 0x0

    const/4 v2, 0x0

    const/4 v3, 0x0

    :goto_0
    const/16 v4, 0x46

    if-ge v3, v4, :cond_2

    .line 70
    aget v4, p2, v2

    array-length v5, p1

    if-ge v4, v5, :cond_1

    add-int/lit8 v5, v4, 0x1

    .line 73
    aput v5, p2, v2

    aget-byte v4, p1, v4

    and-int/lit16 v4, v4, 0xff

    and-int/lit8 v5, v4, 0x7f

    int-to-long v5, v5

    shl-long/2addr v5, v3

    or-long/2addr v0, v5

    and-int/lit16 v4, v4, 0x80

    if-nez v4, :cond_0

    return-wide v0

    :cond_0
    add-int/lit8 v3, v3, 0x7

    goto :goto_0

    .line 71
    :cond_1
    new-instance p1, Ljava/io/IOException;

    const-string p2, "truncated header"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 79
    :cond_2
    new-instance p1, Ljava/io/IOException;

    const-string p2, "bad vint"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private writeFileHeader(J[BJJ)V
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 277
    array-length v0, p3

    const/16 v1, 0x20

    add-int/2addr v0, v1

    .line 278
    new-array v2, v0, [B

    const/4 v3, 0x2

    const/16 v4, 0x74

    .line 279
    aput-byte v4, v2, v3

    const/4 v3, 0x3

    const/4 v4, 0x0

    .line 280
    aput-byte v4, v2, v3

    const/4 v5, 0x4

    const/16 v6, -0x80

    .line 281
    aput-byte v6, v2, v5

    const/4 v5, 0x5

    int-to-byte v6, v0

    .line 282
    aput-byte v6, v2, v5

    shr-int/lit8 v5, v0, 0x8

    int-to-byte v5, v5

    const/4 v6, 0x6

    .line 283
    aput-byte v5, v2, v6

    const/4 v5, 0x7

    .line 284
    invoke-static {v2, v5, p4, p5}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    const/16 v5, 0xb

    .line 285
    invoke-static {v2, v5, p4, p5}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    const/16 p4, 0xf

    .line 286
    aput-byte v3, v2, p4

    const/16 p4, 0x10

    .line 287
    invoke-static {v2, p4, p6, p7}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    const/16 p4, 0x14

    const-wide/32 p5, 0x210000

    .line 288
    invoke-static {v2, p4, p5, p6}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    const/16 p4, 0x18

    const/16 p5, 0x1d

    .line 289
    aput-byte p5, v2, p4

    const/16 p4, 0x19

    const/16 p5, 0x30

    .line 290
    aput-byte p5, v2, p4

    .line 291
    array-length p4, p3

    int-to-byte p4, p4

    const/16 p5, 0x1a

    aput-byte p4, v2, p5

    .line 292
    array-length p4, p3

    shr-int/lit8 p4, p4, 0x8

    int-to-byte p4, p4

    const/16 p5, 0x1b

    aput-byte p4, v2, p5

    const/16 p4, 0x1c

    const-wide/32 p5, 0x81a4

    .line 293
    invoke-static {v2, p4, p5, p6}, Lcra/fork/Rar5Reader;->put32([BIJ)V

    .line 294
    array-length p4, p3

    invoke-static {p3, v4, v2, v1, p4}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 295
    invoke-direct {p0, v2, v0}, Lcra/fork/Rar5Reader;->putCrc16([BI)V

    .line 296
    iget-object p3, p0, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {p3, p1, p2}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 297
    iget-object p1, p0, Lcra/fork/Rar5Reader;->out:Ljava/io/RandomAccessFile;

    invoke-virtual {p1, v2}, Ljava/io/RandomAccessFile;->write([B)V

    return-void
.end method
