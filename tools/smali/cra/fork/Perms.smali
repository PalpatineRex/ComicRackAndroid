.class public final Lcra/fork/Perms;
.super Ljava/lang/Object;
.source "Perms.smali"

# Storage access for fresh installs. With targetSdk >= 23 storage is a runtime
# permission: an upgraded 1.80 install keeps it, a fresh install does not, and the
# library stays empty. LibraryActivity calls ensure() at start; when the user
# grants access, onResult() restarts the app so the library is scanned.
#
# Java equivalent:
#   static void ensure(Activity a) {
#     if (SDK_INT >= 23 && a.checkSelfPermission(READ_EXTERNAL_STORAGE) != GRANTED)
#       a.requestPermissions(new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE}, 0x4352);
#   }
#   static void onResult(Activity a, int code, int[] results) {
#     if (code == 0x4352 && results != null && results.length > 0 && results[0] == GRANTED) restart the app (launch intent + killProcess);
#   }

.method public static ensure(Landroid/app/Activity;)V
    .locals 4

    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x17

    if-lt v0, v1, :done

    const-string v0, "android.permission.READ_EXTERNAL_STORAGE"

    invoke-virtual {p0, v0}, Landroid/app/Activity;->checkSelfPermission(Ljava/lang/String;)I

    move-result v1

    if-eqz v1, :done

    const/4 v1, 0x2

    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0

    aput-object v0, v1, v2

    const/4 v2, 0x1

    const-string v3, "android.permission.WRITE_EXTERNAL_STORAGE"

    aput-object v3, v1, v2

    const/16 v2, 0x4352

    invoke-virtual {p0, v1, v2}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :caught_0

    :done
    return-void

    :caught_0
    return-void
.end method

.method public static onResult(Landroid/app/Activity;I[I)V
    .locals 2

    :try_start_0
    const/16 v0, 0x4352

    if-ne p1, v0, :done

    if-eqz p2, :done

    array-length v0, p2

    if-eqz v0, :done

    const/4 v0, 0x0

    aget v0, p2, v0

    if-nez v0, :done

    # Restart the whole process: a new storage grant only applies to new processes
    # (checked on Android 13: recreate() kept "Empty comics folder", a restart loads
    # the library). Relaunch the app in a fresh task, then end this process.
    invoke-virtual {p0}, Landroid/app/Activity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {p0}, Landroid/app/Activity;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    if-eqz v0, :done

    const v1, 0x10008000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    invoke-virtual {p0, v0}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v0

    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :caught_0

    :done
    return-void

    :caught_0
    return-void
.end method
