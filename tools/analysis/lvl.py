import sys
from loguru import logger
logger.remove()
from androguard.core.dex import DEX
def load(p): return DEX(open(p,'rb').read())
o = load(sys.argv[1]); c = load(sys.argv[2])
def cls(d,n): return next(x for x in d.get_classes() if x.get_name()==n)
for n in ["Lcom/a/b/b/a/i;","Lcom/a/b/b/a/l;","Lcom/a/b/b/a/t;"]:
    print("=====", n)
    co, cc = cls(o,n), cls(c,n)
    mo = {(m.get_name(), str(m.get_descriptor())): m for m in co.get_methods()}
    mc = {(m.get_name(), str(m.get_descriptor())): m for m in cc.get_methods()}
    for k in mo:
        a = mo[k].get_code().get_raw() if mo[k].get_code() else b''
        b = mc[k].get_code().get_raw() if mc[k].get_code() else b''
        if a != b:
            print("-- method", k, "len", len(a), "->", len(b))
            for tag, m in (("ORIG", mo[k]), ("CRACK", mc[k])):
                print(tag)
                for ins in m.get_instructions(): print("   ", ins.get_name(), ins.get_output())
    print("strings:", [s for s in (sorted({str(x) for m in co.get_methods() for ins in m.get_instructions() if ins.get_name().startswith('const-string') for x in [ins.get_output().split(',',1)[-1]]})) ][:15])
