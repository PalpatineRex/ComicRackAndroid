.class Lcra/fork/ContReader$4;
.super Ljava/lang/Object;
.source "ContReader.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcra/fork/ContReader;->load(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcra/fork/ContReader;

.field final synthetic val$i:I


# direct methods
.method constructor <init>(Lcra/fork/ContReader;I)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 186
    iput-object p1, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    iput p2, p0, Lcra/fork/ContReader$4;->val$i:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .line 190
    :try_start_0
    iget-object v0, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$600(Lcra/fork/ContReader;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v1, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$400(Lcra/fork/ContReader;)Ljava/lang/Object;

    move-result-object v1

    const/4 v2, 0x2

    new-array v2, v2, [Ljava/lang/Object;

    iget v3, p0, Lcra/fork/ContReader$4;->val$i:I

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    const/4 v4, 0x0

    aput-object v3, v2, v4

    iget-object v3, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v3}, Lcra/fork/ContReader;->access$500(Lcra/fork/ContReader;)I

    move-result v3

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    const/4 v4, 0x1

    aput-object v3, v2, v4

    invoke-virtual {v0, v1, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/Bitmap;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    const/4 v0, 0x0

    .line 195
    :goto_0
    iget-object v1, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$700(Lcra/fork/ContReader;)Ljava/util/Set;

    move-result-object v1

    monitor-enter v1

    .line 196
    :try_start_1
    iget-object v2, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v2}, Lcra/fork/ContReader;->access$700(Lcra/fork/ContReader;)Ljava/util/Set;

    move-result-object v2

    iget v3, p0, Lcra/fork/ContReader$4;->val$i:I

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v2, v3}, Ljava/util/Set;->remove(Ljava/lang/Object;)Z

    .line 197
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    if-eqz v0, :cond_0

    .line 198
    iget-object v1, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$800(Lcra/fork/ContReader;)Landroid/util/LruCache;

    move-result-object v1

    iget v2, p0, Lcra/fork/ContReader$4;->val$i:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Landroid/util/LruCache;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 199
    :cond_0
    iget-object v1, p0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$1200(Lcra/fork/ContReader;)Landroid/os/Handler;

    move-result-object v1

    new-instance v2, Lcra/fork/ContReader$4$1;

    invoke-direct {v2, p0, v0}, Lcra/fork/ContReader$4$1;-><init>(Lcra/fork/ContReader$4;Landroid/graphics/Bitmap;)V

    invoke-virtual {v1, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void

    :catchall_1
    move-exception v0

    .line 197
    :try_start_2
    monitor-exit v1
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    throw v0
.end method
