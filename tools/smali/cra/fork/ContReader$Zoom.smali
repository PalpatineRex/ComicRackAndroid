.class final Lcra/fork/ContReader$Zoom;
.super Landroid/widget/FrameLayout;
.source "ContReader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcra/fork/ContReader;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "Zoom"
.end annotation


# instance fields
.field private final pinch:Landroid/view/ScaleGestureDetector;

.field private scale:F

.field private scaling:Z

.field private final taps:Landroid/view/GestureDetector;

.field final synthetic this$0:Lcra/fork/ContReader;

.field private tx:F


# direct methods
.method constructor <init>(Lcra/fork/ContReader;Landroid/app/Activity;)V
    .locals 2

    .line 226
    iput-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    .line 227
    invoke-direct {p0, p2}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    const/high16 v0, 0x3f800000    # 1.0f

    .line 220
    iput v0, p0, Lcra/fork/ContReader$Zoom;->scale:F

    .line 228
    new-instance v0, Landroid/view/ScaleGestureDetector;

    new-instance v1, Lcra/fork/ContReader$Zoom$1;

    invoke-direct {v1, p0, p1}, Lcra/fork/ContReader$Zoom$1;-><init>(Lcra/fork/ContReader$Zoom;Lcra/fork/ContReader;)V

    invoke-direct {v0, p2, v1}, Landroid/view/ScaleGestureDetector;-><init>(Landroid/content/Context;Landroid/view/ScaleGestureDetector$OnScaleGestureListener;)V

    iput-object v0, p0, Lcra/fork/ContReader$Zoom;->pinch:Landroid/view/ScaleGestureDetector;

    .line 235
    new-instance v0, Landroid/view/GestureDetector;

    new-instance v1, Lcra/fork/ContReader$Zoom$2;

    invoke-direct {v1, p0, p1}, Lcra/fork/ContReader$Zoom$2;-><init>(Lcra/fork/ContReader$Zoom;Lcra/fork/ContReader;)V

    invoke-direct {v0, p2, v1}, Landroid/view/GestureDetector;-><init>(Landroid/content/Context;Landroid/view/GestureDetector$OnGestureListener;)V

    iput-object v0, p0, Lcra/fork/ContReader$Zoom;->taps:Landroid/view/GestureDetector;

    return-void
.end method

.method static synthetic access$1300(Lcra/fork/ContReader$Zoom;)F
    .locals 0

    .line 219
    iget p0, p0, Lcra/fork/ContReader$Zoom;->scale:F

    return p0
.end method

.method static synthetic access$1400(Lcra/fork/ContReader$Zoom;)Z
    .locals 0

    .line 219
    iget-boolean p0, p0, Lcra/fork/ContReader$Zoom;->scaling:Z

    return p0
.end method

.method static synthetic access$1524(Lcra/fork/ContReader$Zoom;F)F
    .locals 1

    .line 219
    iget v0, p0, Lcra/fork/ContReader$Zoom;->tx:F

    sub-float/2addr v0, p1

    iput v0, p0, Lcra/fork/ContReader$Zoom;->tx:F

    return v0
.end method


# virtual methods
.method apply(F)V
    .locals 3

    const/high16 v0, 0x40800000    # 4.0f

    .line 262
    invoke-static {v0, p1}, Ljava/lang/Math;->min(FF)F

    move-result p1

    const/high16 v0, 0x3f800000    # 1.0f

    invoke-static {v0, p1}, Ljava/lang/Math;->max(FF)F

    move-result p1

    iput p1, p0, Lcra/fork/ContReader$Zoom;->scale:F

    .line 263
    invoke-virtual {p0}, Lcra/fork/ContReader$Zoom;->getWidth()I

    move-result p1

    int-to-float p1, p1

    iget v1, p0, Lcra/fork/ContReader$Zoom;->scale:F

    sub-float v2, v1, v0

    mul-float p1, p1, v2

    const/high16 v2, 0x40000000    # 2.0f

    div-float/2addr p1, v2

    cmpg-float v0, v1, v0

    if-gtz v0, :cond_0

    const/4 p1, 0x0

    goto :goto_0

    :cond_0
    neg-float v0, p1

    .line 264
    iget v1, p0, Lcra/fork/ContReader$Zoom;->tx:F

    invoke-static {p1, v1}, Ljava/lang/Math;->min(FF)F

    move-result p1

    invoke-static {v0, p1}, Ljava/lang/Math;->max(FF)F

    move-result p1

    :goto_0
    iput p1, p0, Lcra/fork/ContReader$Zoom;->tx:F

    .line 265
    iget-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object p1

    invoke-virtual {p0}, Lcra/fork/ContReader$Zoom;->getWidth()I

    move-result v0

    int-to-float v0, v0

    div-float/2addr v0, v2

    invoke-virtual {p1, v0}, Landroid/widget/ListView;->setPivotX(F)V

    .line 266
    iget-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object p1

    invoke-virtual {p0}, Lcra/fork/ContReader$Zoom;->getHeight()I

    move-result v0

    int-to-float v0, v0

    div-float/2addr v0, v2

    invoke-virtual {p1, v0}, Landroid/widget/ListView;->setPivotY(F)V

    .line 267
    iget-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object p1

    iget v0, p0, Lcra/fork/ContReader$Zoom;->scale:F

    invoke-virtual {p1, v0}, Landroid/widget/ListView;->setScaleX(F)V

    .line 268
    iget-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object p1

    iget v0, p0, Lcra/fork/ContReader$Zoom;->scale:F

    invoke-virtual {p1, v0}, Landroid/widget/ListView;->setScaleY(F)V

    .line 269
    iget-object p1, p0, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1}, Lcra/fork/ContReader;->access$1000(Lcra/fork/ContReader;)Landroid/widget/ListView;

    move-result-object p1

    iget v0, p0, Lcra/fork/ContReader$Zoom;->tx:F

    invoke-virtual {p1, v0}, Landroid/widget/ListView;->setTranslationX(F)V

    return-void
.end method

.method public dispatchTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 2

    .line 274
    iget-object v0, p0, Lcra/fork/ContReader$Zoom;->pinch:Landroid/view/ScaleGestureDetector;

    invoke-virtual {v0, p1}, Landroid/view/ScaleGestureDetector;->onTouchEvent(Landroid/view/MotionEvent;)Z

    .line 275
    iget-object v0, p0, Lcra/fork/ContReader$Zoom;->pinch:Landroid/view/ScaleGestureDetector;

    invoke-virtual {v0}, Landroid/view/ScaleGestureDetector;->isInProgress()Z

    move-result v0

    iput-boolean v0, p0, Lcra/fork/ContReader$Zoom;->scaling:Z

    .line 276
    iget-object v0, p0, Lcra/fork/ContReader$Zoom;->taps:Landroid/view/GestureDetector;

    invoke-virtual {v0, p1}, Landroid/view/GestureDetector;->onTouchEvent(Landroid/view/MotionEvent;)Z

    .line 277
    iget-boolean v0, p0, Lcra/fork/ContReader$Zoom;->scaling:Z

    if-eqz v0, :cond_1

    .line 278
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getActionMasked()I

    move-result v0

    const/4 v1, 0x5

    if-ne v0, v1, :cond_0

    .line 279
    invoke-static {p1}, Landroid/view/MotionEvent;->obtain(Landroid/view/MotionEvent;)Landroid/view/MotionEvent;

    move-result-object p1

    const/4 v0, 0x3

    .line 280
    invoke-virtual {p1, v0}, Landroid/view/MotionEvent;->setAction(I)V

    .line 281
    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->dispatchTouchEvent(Landroid/view/MotionEvent;)Z

    .line 282
    invoke-virtual {p1}, Landroid/view/MotionEvent;->recycle()V

    :cond_0
    const/4 p1, 0x1

    return p1

    .line 286
    :cond_1
    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->dispatchTouchEvent(Landroid/view/MotionEvent;)Z

    move-result p1

    return p1
.end method
