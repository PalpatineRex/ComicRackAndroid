.class Lcra/fork/ContReader$Zoom$2;
.super Landroid/view/GestureDetector$SimpleOnGestureListener;
.source "ContReader.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcra/fork/ContReader$Zoom;-><init>(Lcra/fork/ContReader;Landroid/app/Activity;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcra/fork/ContReader$Zoom;

.field final synthetic val$this$0:Lcra/fork/ContReader;


# direct methods
.method constructor <init>(Lcra/fork/ContReader$Zoom;Lcra/fork/ContReader;)V
    .locals 0

    .line 235
    iput-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    iput-object p2, p0, Lcra/fork/ContReader$Zoom$2;->val$this$0:Lcra/fork/ContReader;

    invoke-direct {p0}, Landroid/view/GestureDetector$SimpleOnGestureListener;-><init>()V

    return-void
.end method


# virtual methods
.method public onDoubleTap(Landroid/view/MotionEvent;)Z
    .locals 2

    .line 238
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {p1}, Lcra/fork/ContReader$Zoom;->access$1300(Lcra/fork/ContReader$Zoom;)F

    move-result v0

    const v1, 0x3f866666    # 1.05f

    cmpl-float v0, v0, v1

    if-lez v0, :cond_0

    const/high16 v0, 0x3f800000    # 1.0f

    goto :goto_0

    :cond_0
    const/high16 v0, 0x40000000    # 2.0f

    :goto_0
    invoke-virtual {p1, v0}, Lcra/fork/ContReader$Zoom;->apply(F)V

    const/4 p1, 0x1

    return p1
.end method

.method public onScroll(Landroid/view/MotionEvent;Landroid/view/MotionEvent;FF)Z
    .locals 0

    .line 252
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {p1}, Lcra/fork/ContReader$Zoom;->access$1300(Lcra/fork/ContReader$Zoom;)F

    move-result p1

    const/high16 p2, 0x3f800000    # 1.0f

    cmpl-float p1, p1, p2

    if-lez p1, :cond_0

    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {p1}, Lcra/fork/ContReader$Zoom;->access$1400(Lcra/fork/ContReader$Zoom;)Z

    move-result p1

    if-nez p1, :cond_0

    .line 253
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {p1, p3}, Lcra/fork/ContReader$Zoom;->access$1524(Lcra/fork/ContReader$Zoom;F)F

    .line 254
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {p1}, Lcra/fork/ContReader$Zoom;->access$1300(Lcra/fork/ContReader$Zoom;)F

    move-result p2

    invoke-virtual {p1, p2}, Lcra/fork/ContReader$Zoom;->apply(F)V

    :cond_0
    const/4 p1, 0x0

    return p1
.end method

.method public onSingleTapConfirmed(Landroid/view/MotionEvent;)Z
    .locals 2

    .line 244
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getY()F

    move-result p1

    iget-object v0, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-virtual {v0}, Lcra/fork/ContReader$Zoom;->getHeight()I

    move-result v0

    const/4 v1, 0x1

    invoke-static {v1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    int-to-float v0, v0

    div-float/2addr p1, v0

    const v0, 0x3e99999a    # 0.3f

    cmpg-float v0, p1, v0

    if-gez v0, :cond_0

    .line 245
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    iget-object p1, p1, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    const/4 v0, -0x1

    invoke-static {p1, v0}, Lcra/fork/ContReader;->access$000(Lcra/fork/ContReader;I)V

    goto :goto_0

    :cond_0
    const v0, 0x3f333333    # 0.7f

    cmpl-float p1, p1, v0

    if-lez p1, :cond_1

    .line 246
    iget-object p1, p0, Lcra/fork/ContReader$Zoom$2;->this$1:Lcra/fork/ContReader$Zoom;

    iget-object p1, p1, Lcra/fork/ContReader$Zoom;->this$0:Lcra/fork/ContReader;

    invoke-static {p1, v1}, Lcra/fork/ContReader;->access$000(Lcra/fork/ContReader;I)V

    :cond_1
    :goto_0
    return v1
.end method
