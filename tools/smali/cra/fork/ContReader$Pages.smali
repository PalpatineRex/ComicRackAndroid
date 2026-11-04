.class Lcra/fork/ContReader$Pages;
.super Landroid/widget/BaseAdapter;
.source "ContReader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcra/fork/ContReader;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "Pages"
.end annotation


# instance fields
.field final synthetic this$0:Lcra/fork/ContReader;


# direct methods
.method private constructor <init>(Lcra/fork/ContReader;)V
    .locals 0

    .line 206
    iput-object p1, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-direct {p0}, Landroid/widget/BaseAdapter;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcra/fork/ContReader;Lcra/fork/ContReader$1;)V
    .locals 0

    .line 206
    invoke-direct {p0, p1}, Lcra/fork/ContReader$Pages;-><init>(Lcra/fork/ContReader;)V

    return-void
.end method


# virtual methods
.method public getCount()I
    .locals 1

    .line 208
    iget-object v0, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$100(Lcra/fork/ContReader;)I

    move-result v0

    return v0
.end method

.method public getItem(I)Ljava/lang/Object;
    .locals 0

    const/4 p1, 0x0

    return-object p1
.end method

.method public getItemId(I)J
    .locals 2

    int-to-long v0, p1

    return-wide v0
.end method

.method public getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
    .locals 3

    .line 220
    instance-of p3, p2, Landroid/widget/ImageView;

    if-eqz p3, :cond_0

    check-cast p2, Landroid/widget/ImageView;

    goto :goto_0

    :cond_0
    new-instance p2, Landroid/widget/ImageView;

    iget-object p3, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {p3}, Lcra/fork/ContReader;->access$1200(Lcra/fork/ContReader;)Landroid/app/Activity;

    move-result-object p3

    invoke-direct {p2, p3}, Landroid/widget/ImageView;-><init>(Landroid/content/Context;)V

    :goto_0
    const/4 p3, 0x1

    .line 221
    invoke-virtual {p2, p3}, Landroid/widget/ImageView;->setAdjustViewBounds(Z)V

    .line 222
    sget-object v0, Landroid/widget/ImageView$ScaleType;->FIT_CENTER:Landroid/widget/ImageView$ScaleType;

    invoke-virtual {p2, v0}, Landroid/widget/ImageView;->setScaleType(Landroid/widget/ImageView$ScaleType;)V

    .line 223
    new-instance v0, Landroid/widget/AbsListView$LayoutParams;

    const/4 v1, -0x1

    const/4 v2, -0x2

    invoke-direct {v0, v1, v2}, Landroid/widget/AbsListView$LayoutParams;-><init>(II)V

    invoke-virtual {p2, v0}, Landroid/widget/ImageView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 224
    iget-object v0, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$700(Lcra/fork/ContReader;)Landroid/util/LruCache;

    move-result-object v0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/util/LruCache;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/graphics/Bitmap;

    if-eqz v0, :cond_1

    const/4 v1, 0x0

    .line 226
    invoke-virtual {p2, v1}, Landroid/widget/ImageView;->setMinimumHeight(I)V

    .line 227
    invoke-virtual {p2, v0}, Landroid/widget/ImageView;->setImageBitmap(Landroid/graphics/Bitmap;)V

    goto :goto_1

    :cond_1
    const/4 v0, 0x0

    .line 229
    invoke-virtual {p2, v0}, Landroid/widget/ImageView;->setImageBitmap(Landroid/graphics/Bitmap;)V

    .line 230
    iget-object v0, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {v0}, Lcra/fork/ContReader;->access$1300(Lcra/fork/ContReader;)I

    move-result v0

    invoke-virtual {p2, v0}, Landroid/widget/ImageView;->setMinimumHeight(I)V

    .line 231
    iget-object v0, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {v0, p1}, Lcra/fork/ContReader;->access$1400(Lcra/fork/ContReader;I)V

    :goto_1
    add-int/2addr p1, p3

    .line 233
    iget-object p3, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {p3}, Lcra/fork/ContReader;->access$100(Lcra/fork/ContReader;)I

    move-result p3

    if-ge p1, p3, :cond_2

    iget-object p3, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {p3}, Lcra/fork/ContReader;->access$700(Lcra/fork/ContReader;)Landroid/util/LruCache;

    move-result-object p3

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {p3, v0}, Landroid/util/LruCache;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    if-nez p3, :cond_2

    iget-object p3, p0, Lcra/fork/ContReader$Pages;->this$0:Lcra/fork/ContReader;

    invoke-static {p3, p1}, Lcra/fork/ContReader;->access$1400(Lcra/fork/ContReader;I)V

    :cond_2
    return-object p2
.end method
