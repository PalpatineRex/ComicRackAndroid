.class public final Lcra/fork/Updater;
.super Ljava/lang/Object;
.source "Updater.smali"

# interfaces
.implements Ljava/lang/Runnable;

# Update check against this fork's GitHub Releases.
# start(activity) is called from LibraryActivity; at most once a day it starts a
# background thread (run) that reads releases/latest, turns tag_name ("2.9.187",
# "v2.9.187.1") into a versionCode with the build's formula (code), and when it is
# newer than the installed versionCode posts UpdatePrompt on the UI thread with the
# release's .apk asset URL (fallback: the release page). Any error = silently
# nothing (no network, no release yet, rate limit...).
#
# Java equivalent:
#   static void start(Activity a) {
#     SharedPreferences p = a.getSharedPreferences("cra_fork", 0);
#     long now = System.currentTimeMillis();
#     if (now - p.getLong("update_check", 0) < 86400000L) return;
#     p.edit().putLong("update_check", now).apply();
#     new Thread(new Updater(a)).start();
#   }

.field private final a:Landroid/app/Activity;

.method private constructor <init>(Landroid/app/Activity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcra/fork/Updater;->a:Landroid/app/Activity;

    return-void
.end method

.method public static start(Landroid/app/Activity;)V
    .locals 8

    :try_start_0
    const-string v0, "cra_fork"

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Landroid/app/Activity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v1, "update_check"

    const-wide/16 v2, 0x0

    invoke-interface {v0, v1, v2, v3}, Landroid/content/SharedPreferences;->getLong(Ljava/lang/String;J)J

    move-result-wide v2

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v4

    sub-long v6, v4, v2

    const-wide/32 v2, 0x5265c00

    cmp-long v6, v6, v2

    if-ltz v6, :not_due

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0, v1, v4, v5}, Landroid/content/SharedPreferences$Editor;->putLong(Ljava/lang/String;J)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V

    new-instance v0, Ljava/lang/Thread;

    new-instance v1, Lcra/fork/Updater;

    invoke-direct {v1, p0}, Lcra/fork/Updater;-><init>(Landroid/app/Activity;)V

    invoke-direct {v0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :caught_0

    :not_due
    return-void

    :caught_0
    return-void
.end method

# "2.9.186" -> 918600, "v2.9.187.1" -> 918701, anything else -> 0.
# Same formula as tools/patch_manifest.py fork_version():
#   (X - 2) * 10^7 + Y * 10^5 + Z * 100 + rev
.method public static code(Ljava/lang/String;)I
    .locals 4

    :try_start_0
    const-string v0, "v"

    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :no_v

    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p0

    :no_v
    const-string v0, "\\."

    invoke-virtual {p0, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x3

    if-lt v1, v2, :fail

    const/4 v1, 0x0

    aget-object v1, v0, v1

    invoke-static {v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v1

    add-int/lit8 v1, v1, -0x2

    const v2, 0x989680

    mul-int/2addr v1, v2

    const/4 v2, 0x1

    aget-object v2, v0, v2

    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v2

    const v3, 0x186a0

    mul-int/2addr v2, v3

    add-int/2addr v1, v2

    const/4 v2, 0x2

    aget-object v2, v0, v2

    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v2

    mul-int/lit8 v2, v2, 0x64

    add-int/2addr v1, v2

    array-length v2, v0

    const/4 v3, 0x4

    if-lt v2, v3, :done

    const/4 v2, 0x3

    aget-object v2, v0, v2

    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v2

    add-int/2addr v1, v2
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :caught_0

    :done
    return v1

    :fail
    const/4 v0, 0x0

    return v0

    :caught_0
    const/4 v0, 0x0

    return v0
.end method

.method public run()V
    .locals 10

    :try_start_0
    new-instance v0, Ljava/net/URL;

    const-string v1, "https://api.github.com/repos/PalpatineRex/ComicRackAndroid/releases/latest"

    invoke-direct {v0, v1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v0

    check-cast v0, Ljava/net/HttpURLConnection;

    const/16 v1, 0x2710

    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    const-string v1, "User-Agent"

    const-string v2, "ComicRackAndroid"

    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "Accept"

    const-string v2, "application/vnd.github+json"

    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v1

    const/16 v2, 0xc8

    if-ne v1, v2, :quit

    # body = new Scanner(in, "UTF-8").useDelimiter("\\A").next()
    new-instance v1, Ljava/util/Scanner;

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v2

    const-string v3, "UTF-8"

    invoke-direct {v1, v2, v3}, Ljava/util/Scanner;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    const-string v2, "\\A"

    invoke-virtual {v1, v2}, Ljava/util/Scanner;->useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;

    move-result-object v1

    invoke-virtual {v1}, Ljava/util/Scanner;->next()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V

    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0, v1}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    # v1 = tag_name, v2 = its versionCode
    const-string v1, "tag_name"

    invoke-virtual {v0, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcra/fork/Updater;->code(Ljava/lang/String;)I

    move-result v2

    # v3 = activity, v4 = installed versionCode
    iget-object v3, p0, Lcra/fork/Updater;->a:Landroid/app/Activity;

    invoke-virtual {v3}, Landroid/app/Activity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v4

    invoke-virtual {v3}, Landroid/app/Activity;->getPackageName()Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x0

    invoke-virtual {v4, v5, v6}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v4

    iget v4, v4, Landroid/content/pm/PackageInfo;->versionCode:I

    if-le v2, v4, :quit

    # v4 = URL to open: first asset ending in .apk, else the release page
    const-string v4, "html_url"

    invoke-virtual {v0, v4}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    const-string v5, "assets"

    invoke-virtual {v0, v5}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v5

    if-eqz v5, :prompt

    const-string v9, ".apk"

    const/4 v6, 0x0

    :asset_loop
    invoke-virtual {v5}, Lorg/json/JSONArray;->length()I

    move-result v7

    if-ge v6, v7, :prompt

    invoke-virtual {v5, v6}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v7

    const-string v8, "name"

    invoke-virtual {v7, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v8, v9}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v8

    if-eqz v8, :asset_next

    const-string v8, "browser_download_url"

    invoke-virtual {v7, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    goto :prompt

    :asset_next
    add-int/lit8 v6, v6, 0x1

    goto :asset_loop

    :prompt
    new-instance v5, Lcra/fork/UpdatePrompt;

    invoke-direct {v5, v3, v1, v4}, Lcra/fork/UpdatePrompt;-><init>(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v3, v5}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :caught_0

    :quit
    return-void

    :caught_0
    return-void
.end method
