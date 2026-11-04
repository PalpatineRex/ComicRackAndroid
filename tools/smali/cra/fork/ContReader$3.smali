.class Lcra/fork/ContReader$3;
.super Ljava/lang/Object;
.source "ContReader.java"

# interfaces
.implements Landroid/widget/AbsListView$OnScrollListener;


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


# direct methods
.method constructor <init>(Lcra/fork/ContReader;)V
    .locals 0

    .line 98
    iput-object p1, p0, Lcra/fork/ContReader$3;->this$0:Lcra/fork/ContReader;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onScroll(Landroid/widget/AbsListView;III)V
    .locals 0

    const/4 p3, 0x0

    .line 102
    invoke-virtual {p1, p3}, Landroid/widget/AbsListView;->getChildAt(I)Landroid/view/View;

    move-result-object p3

    if-eqz p3, :cond_0

    .line 104
    invoke-virtual {p3}, Landroid/view/View;->getBottom()I

    move-result p3

    invoke-virtual {p1}, Landroid/widget/AbsListView;->getHeight()I

    move-result p1

    div-int/lit8 p1, p1, 0x2

    if-ge p3, p1, :cond_0

    add-int/lit8 p1, p2, 0x1

    if-ge p1, p4, :cond_0

    move p2, p1

    .line 105
    :cond_0
    iget-object p1, p0, Lcra/fork/ContReader$3;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$100(Lcra/fork/ContReader;)I

    move-result p1

    add-int/lit8 p1, p1, -0x1

    if-le p2, p1, :cond_1

    iget-object p1, p0, Lcra/fork/ContReader$3;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$100(Lcra/fork/ContReader;)I

    move-result p1

    add-int/lit8 p2, p1, -0x1

    .line 106
    :cond_1
    iget-object p1, p0, Lcra/fork/ContReader$3;->this$0:Lcra/fork/ContReader;

    invoke-static {p1, p2}, Lcra/fork/ContReader;->access$200(Lcra/fork/ContReader;I)V

    return-void
.end method

.method public onScrollStateChanged(Landroid/widget/AbsListView;I)V
    .locals 0

    return-void
.end method
