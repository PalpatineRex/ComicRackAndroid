.class Lcra/fork/ContReader$2;
.super Landroid/widget/ListView;
.source "ContReader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcra/fork/ContReader;-><init>(Landroid/app/Activity;Ljava/lang/Object;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcra/fork/ContReader;

.field final synthetic val$act:Landroid/app/Activity;


# direct methods
.method constructor <init>(Lcra/fork/ContReader;Landroid/content/Context;Landroid/app/Activity;)V
    .locals 0

    .line 84
    iput-object p1, p0, Lcra/fork/ContReader$2;->this$0:Lcra/fork/ContReader;

    iput-object p3, p0, Lcra/fork/ContReader$2;->val$act:Landroid/app/Activity;

    invoke-direct {p0, p2}, Landroid/widget/ListView;-><init>(Landroid/content/Context;)V

    return-void
.end method


# virtual methods
.method public dispatchKeyEvent(Landroid/view/KeyEvent;)Z
    .locals 4

    .line 87
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v0

    const/4 v1, 0x4

    const/4 v2, 0x1

    if-ne v0, v1, :cond_1

    .line 88
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result p1

    if-ne p1, v2, :cond_0

    iget-object p1, p0, Lcra/fork/ContReader$2;->val$act:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->finish()V

    :cond_0
    return v2

    .line 91
    :cond_1
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v0

    const/16 v1, 0x19

    if-eq v0, v1, :cond_3

    const/16 v3, 0x18

    if-ne v0, v3, :cond_2

    goto :goto_0

    .line 96
    :cond_2
    invoke-super {p0, p1}, Landroid/widget/ListView;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    move-result p1

    return p1

    .line 93
    :cond_3
    :goto_0
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result p1

    if-nez p1, :cond_5

    iget-object p1, p0, Lcra/fork/ContReader$2;->this$0:Lcra/fork/ContReader;

    if-ne v0, v1, :cond_4

    const/4 v0, 0x1

    goto :goto_1

    :cond_4
    const/4 v0, -0x1

    :goto_1
    invoke-static {p1, v0}, Lcra/fork/ContReader;->access$000(Lcra/fork/ContReader;I)V

    :cond_5
    return v2
.end method
