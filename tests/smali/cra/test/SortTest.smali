.class public Lcra/test/SortTest;
.super Ljava/lang/Object;
.source "SortTest.smali"

# On-device test of the library series sort, run with app_process against a test
# build (never shipped): prints "a | b | compare" for each pair of the expected
# order using com.cyo.common.bi.d, the comparator behind "Sort by series"
# (article stripping, then bi.c -> cra.fork.Natural). Every compare must be < 0.
#   CLASSPATH=/data/local/tmp/cra_sorttest.apk app_process /system/bin cra.test.SortTest

.method public static main([Ljava/lang/String;)V
    .locals 8

    const/16 v0, 0x9

    new-array p0, v0, [Ljava/lang/String;

    const/4 v0, 0x0

    const-string v1, "Alpha"

    aput-object v1, p0, v0

    const/4 v0, 0x1

    const-string v1, "L\'Arbre"

    aput-object v1, p0, v0

    const/4 v0, 0x2

    const-string v1, "Les Bateaux"

    aput-object v1, p0, v0

    const/4 v0, 0x3

    const-string v1, "Écureuil"

    aput-object v1, p0, v0

    const/4 v0, 0x4

    const-string v1, "La Montagne"

    aput-object v1, p0, v0

    const/4 v0, 0x5

    const-string v1, "Série 2"

    aput-object v1, p0, v0

    const/4 v0, 0x6

    const-string v1, "Serie 10"

    aput-object v1, p0, v0

    const/4 v0, 0x7

    const-string v1, "The Yeti"

    aput-object v1, p0, v0

    const/16 v0, 0x8

    const-string v1, "Le Zebre"

    aput-object v1, p0, v0

    const/4 v0, 0x0

    array-length v1, p0

    add-int/lit8 v1, v1, -0x1

    :loop
    if-ge v0, v1, :done

    aget-object v2, p0, v0

    add-int/lit8 v3, v0, 0x1

    aget-object v3, p0, v3

    invoke-static {v2, v3}, Lcom/cyo/common/bi;->d(Ljava/lang/String;Ljava/lang/String;)I

    move-result v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, " | "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    sget-object v7, Ljava/lang/System;->out:Ljava/io/PrintStream;

    invoke-virtual {v7, v6}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    add-int/lit8 v0, v0, 0x1

    goto :loop

    :done
    return-void
.end method
