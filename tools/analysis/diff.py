import sys, hashlib
from loguru import logger
logger.remove()
from androguard.core.dex import DEX
def load(p):
    d = DEX(open(p,'rb').read())
    out = {}
    for c in d.get_classes():
        name = c.get_name()
        h = hashlib.sha1()
        for m in c.get_methods():
            h.update(m.get_name().encode()); h.update(str(m.get_descriptor()).encode())
            code = m.get_code()
            if code: h.update(code.get_raw())
        out[name] = h.hexdigest()
    return out
a = load(sys.argv[1]); b = load(sys.argv[2])
print("classes orig/crack:", len(a), len(b))
print("only in orig:", sorted(set(a)-set(b)))
print("only in crack:", sorted(set(b)-set(a)))
diff = sorted(k for k in a if k in b and a[k]!=b[k])
print("modified:", len(diff)); [print("  ", k) for k in diff]
app = [k for k in a if k.startswith("Lcom/cyo")]
print("com.cyo classes:", len(app))
import collections
pk = collections.Counter(k.rsplit('/',1)[0] for k in a)
for k,v in pk.most_common(15): print(v, k)
