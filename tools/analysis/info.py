import sys
from loguru import logger
logger.remove()
import sys
from androguard.core.apk import APK
a = APK(sys.argv[1])
print("package:", a.get_package())
print("versionName:", a.get_androidversion_name(), "versionCode:", a.get_androidversion_code())
print("minSdk:", a.get_min_sdk_version(), "targetSdk:", a.get_target_sdk_version(), "maxSdk:", a.get_max_sdk_version())
print("main activity:", a.get_main_activity())
print("permissions:", *sorted(a.get_permissions()), sep="\n  ")
print("activities:", len(a.get_activities()), "services:", a.get_services(), "receivers:", a.get_receivers())
print("signed v1/v2/v3:", a.is_signed_v1(), a.is_signed_v2(), a.is_signed_v3())
for c in a.get_certificates_der_v3() or a.get_certificates_der_v2() or []:
    pass
try:
    for c in a.get_signature_names(): print("sig file:", c)
    for c in a.get_certificates(): print("cert subject:", c.subject.human_friendly, "| issuer:", c.issuer.human_friendly, "| sha256:", c.sha256_fingerprint)
except Exception as e: print("cert err", e)
