import sys, re, collections
from loguru import logger
logger.remove()
from androguard.core.dex import DEX
d = DEX(open(sys.argv[1],'rb').read())
names = [c.get_name() for c in d.get_classes()]
v = [n for n in names if n.startswith("Lcom/cyo/comicrack/viewer/")]
short = [n for n in v if re.fullmatch(r"L.*/[a-z]{1,2}(\$.*)?;", n)]
print("viewer classes:", len(v), "| names 1-2 letters:", len(short))
print("readable sample:", [n.split('/')[-1] for n in v if n not in short][:40])
print("obfuscated sample:", [n.split('/')[-1] for n in short][:15])
print("methods per cls sample:")
for c in d.get_classes():
    if c.get_name().endswith("WifiSyncService;"):
        print(" ", c.get_name(), [m.get_name() for m in c.get_methods()][:25])
strs = [s for s in d.get_strings()]
urls = sorted({str(s) for s in strs if re.search(r"https?://|\.com|\.net", str(s))})
print("url-like strings:", len(urls)); [print("  ", u[:110]) for u in urls[:40]]
