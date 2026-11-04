.class Lcra/fork/ContReader$Zoom$1;
.super Landroid/view/ScaleGestureDetector$SimpleOnScaleGestureListener;
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

    .line 228
    iput-object p1, p0, Lcra/fork/ContReader$Zoom$1;->this$1:Lcra/fork/ContReader$Zoom;

    iput-object p2, p0, Lcra/fork/ContReader$Zoom$1;->val$this$0:Lcra/fork/ContReader;

    invoke-direct {p0}, Landroid/view/ScaleGestureDetector$SimpleOnScaleGestureListener;-><init>()V

    return-void
.end method


# virtual methods
.method public onScale(Landroid/view/ScaleGestureDetector;)Z
    .locals 2

    .line 231
    iget-object v0, p0, Lcra/fork/ContReader$Zoom$1;->this$1:Lcra/fork/ContReader$Zoom;

    invoke-static {v0}, Lcra/fork/ContReader$Zoom;->access$1300(Lcra/fork/ContReader$Zoom;)F

    move-result v1

    invoke-virtual {p1}, Landroid/view/ScaleGestureDetector;->getScaleFactor()F

    move-result p1

    mul-float v1, v1, p1

    invoke-virtual {v0, v1}, Lcra/fork/ContReader$Zoom;->apply(F)V

    const/4 p1, 0x1

    return p1
.end method
