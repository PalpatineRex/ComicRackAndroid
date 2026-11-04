.class Lcra/fork/ContReader$4$1;
.super Ljava/lang/Object;
.source "ContReader.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcra/fork/ContReader$4;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcra/fork/ContReader$4;

.field final synthetic val$res:Landroid/graphics/Bitmap;


# direct methods
.method constructor <init>(Lcra/fork/ContReader$4;Landroid/graphics/Bitmap;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 199
    iput-object p1, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iput-object p2, p0, Lcra/fork/ContReader$4$1;->val$res:Landroid/graphics/Bitmap;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 201
    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v0, v0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$900(Lcra/fork/ContReader;)Z

    move-result v0

    if-nez v0, :cond_1

    iget-object v0, p0, Lcra/fork/ContReader$4$1;->val$res:Landroid/graphics/Bitmap;

    if-nez v0, :cond_0

    goto :goto_0

    .line 202
    :cond_0
    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v0, v0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/ListView;->invalidateViews()V

    .line 203
    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v0, v0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$1100(Lcra/fork/ContReader;)I

    move-result v0

    if-ltz v0, :cond_1

    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget v0, v0, Lcra/fork/ContReader$4;->val$i:I

    iget-object v1, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v1, v1, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$1100(Lcra/fork/ContReader;)I

    move-result v1

    if-lt v0, v1, :cond_1

    .line 205
    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v0, v0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object v0

    iget-object v1, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v1, v1, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    invoke-static {v1}, Lcra/fork/ContReader;->access$1100(Lcra/fork/ContReader;)I

    move-result v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/widget/ListView;->setSelectionFromTop(II)V

    .line 206
    iget-object v0, p0, Lcra/fork/ContReader$4$1;->this$1:Lcra/fork/ContReader$4;

    iget-object v0, v0, Lcra/fork/ContReader$4;->this$0:Lcra/fork/ContReader;

    const/4 v1, -0x1

    invoke-static {v0, v1}, Lcra/fork/ContReader;->access$1102(Lcra/fork/ContReader;I)I

    :cond_1
    :goto_0
    return-void
.end method
