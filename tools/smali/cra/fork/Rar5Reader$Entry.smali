.class final Lcra/fork/Rar5Reader$Entry;
.super Ljava/lang/Object;
.source "Rar5Reader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcra/fork/Rar5Reader;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "Entry"
.end annotation


# instance fields
.field crc:J

.field dataPos:J

.field dataSize:J

.field dict:J

.field dir:Z

.field method:I

.field name:Ljava/lang/String;

.field solid:Z

.field unpackedSize:J


# direct methods
.method private constructor <init>()V
    .locals 2

    .line 31
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-wide/16 v0, -0x1

    .line 36
    iput-wide v0, p0, Lcra/fork/Rar5Reader$Entry;->crc:J

    return-void
.end method

.method synthetic constructor <init>(Lcra/fork/Rar5Reader$1;)V
    .locals 0

    .line 31
    invoke-direct {p0}, Lcra/fork/Rar5Reader$Entry;-><init>()V

    return-void
.end method
