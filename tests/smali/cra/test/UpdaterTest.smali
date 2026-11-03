.class public Lcra/test/UpdaterTest;
.super Ljava/lang/Object;
.source "UpdaterTest.smali"

# On-device test of cra.fork.Updater.code (tag -> versionCode), run with app_process:
#   CLASSPATH=/data/local/tmp/cra_test.apk app_process /system/bin cra.test.UpdaterTest
# Expected output:
#   2.9.186 -> 918600
#   v2.9.187 -> 918700
#   2.9.187.1 -> 918701
#   3.0.0 -> 10000000
#   nightly -> 0

.method public static main([Ljava/lang/String;)V
    .locals 6

    const/4 v0, 0x5

    new-array v1, v0, [Ljava/lang/String;

    const/4 v0, 0x0

    const-string v2, "2.9.186"

    aput-object v2, v1, v0

    const/4 v0, 0x1

    const-string v2, "v2.9.187"

    aput-object v2, v1, v0

    const/4 v0, 0x2

    const-string v2, "2.9.187.1"

    aput-object v2, v1, v0

    const/4 v0, 0x3

    const-string v2, "3.0.0"

    aput-object v2, v1, v0

    const/4 v0, 0x4

    const-string v2, "nightly"

    aput-object v2, v1, v0

    const/4 v0, 0x0

    :loop
    array-length v2, v1

    if-ge v0, v2, :done

    aget-object v2, v1, v0

    invoke-static {v2}, Lcra/fork/Updater;->code(Ljava/lang/String;)I

    move-result v3

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const-string v5, " -> "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    sget-object v5, Ljava/lang/System;->out:Ljava/io/PrintStream;

    invoke-virtual {v5, v4}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    add-int/lit8 v0, v0, 0x1

    goto :loop

    :done
    return-void
.end method
